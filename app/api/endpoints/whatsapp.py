from typing import Any, Dict, Optional
from fastapi import APIRouter, BackgroundTasks, HTTPException, Query, Request, Response, status
from app.core.config import settings
from app.core.logger import logger
from app.services.whatsapp_service import whatsapp_service

router = APIRouter()


@router.get("/webhook", summary="Verify Meta WhatsApp Cloud API Webhook")
async def verify_whatsapp_webhook(
    hub_mode: Optional[str] = Query(None, alias="hub.mode"),
    hub_verify_token: Optional[str] = Query(None, alias="hub.verify_token"),
    hub_challenge: Optional[str] = Query(None, alias="hub.challenge"),
    mode: Optional[str] = Query(None),
    verify_token: Optional[str] = Query(None),
    challenge: Optional[str] = Query(None),
):
    """Automatic GET webhook verification endpoint for Meta WhatsApp Cloud API.

    Meta sends `hub.mode`, `hub.verify_token`, and `hub.challenge`.
    If the verify token matches `VERIFY_TOKEN`, return `hub.challenge` as plain text with HTTP 200 OK.
    """
    req_mode = hub_mode or mode
    req_token = hub_verify_token or verify_token
    req_challenge = hub_challenge or challenge

    logger.info(f"WhatsApp Webhook Verification Request: mode={req_mode}, verify_token={req_token}")

    if req_mode == "subscribe" and req_token == settings.VERIFY_TOKEN:
        logger.info("WhatsApp Webhook verified successfully!")
        return Response(content=req_challenge or "", media_type="text/plain", status_code=status.HTTP_200_OK)

    logger.warning(f"WhatsApp Webhook Verification Failed. Expected token '{settings.VERIFY_TOKEN}', got '{req_token}'")
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Verification token mismatch")



@router.post("/webhook", summary="Receive Meta WhatsApp Cloud API Events & Messages")
async def receive_whatsapp_webhook(
    payload: Dict[str, Any],
    background_tasks: BackgroundTasks,
):
    """Receive incoming WhatsApp messages (Text, Image, Voice, Document) and process asynchronously.

    Returns immediate HTTP 200 OK to satisfy Meta's 3-second delivery timeout constraint.
    """
    try:
        entries = payload.get("entry", [])
        for entry in entries:
            changes = entry.get("changes", [])
            for change in changes:
                value = change.get("value", {})
                messages = value.get("messages", [])

                for msg in messages:
                    sender_phone = msg.get("from")
                    if sender_phone:
                        # Offload message processing to background tasks
                        background_tasks.add_task(
                            whatsapp_service.process_incoming_message,
                            message=msg,
                            sender_phone=sender_phone,
                        )

        return {"status": "ok", "message": "Event received and queued for processing"}

    except Exception as e:
        logger.error(f"Error handling WhatsApp webhook payload: {e}")
        # Always return 200 OK to prevent Meta from retrying broken payloads endlessly
        return {"status": "ok", "error": str(e)}
