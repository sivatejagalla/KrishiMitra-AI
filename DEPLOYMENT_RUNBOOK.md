# 🚀 Agrolith-AI — Production Deployment Runbook & Commands

This runbook contains complete execution commands, production configuration specifications, and verification URLs for deploying **Agrolith-AI** to **Railway**, **Render**, **Flutter Web**, **Flutter Android APK**, **Meta WhatsApp Cloud API**, and **ngrok**.

---

## 1. ⚙️ Production Environment Variables Reference

Configure the following environment variables in your cloud deployment platform (Railway / Render / Docker):

```ini
# ─── System Metadata ───────────────────────────────────────────────────────────
PROJECT_NAME="Agrolith-AI Production Backend"
VERSION="1.0.0"
API_V1_STR="/api/v1"
ENVIRONMENT="production"

# ─── Security & Authentication ────────────────────────────────────────────────
SECRET_KEY="PROD_SECRET_KEY_PLACEHOLDER_32_CHARS_MINIMUM"
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# ─── Firebase Admin Credentials ───────────────────────────────────────────────
FIREBASE_CREDENTIALS="serviceAccountKey.json"

# ─── AI & External Data Services ──────────────────────────────────────────────
GEMINI_API_KEY="AIzaSy...your-production-gemini-key"
OPENWEATHER_API_KEY="your-openweather-api-key"
DEFAULT_LANGUAGE="en"
SUPPORTED_LANGUAGES=["en","hi","te","ta","mr"]

# ─── Meta WhatsApp Cloud API ───────────────────────────────────────────────────
WHATSAPP_TOKEN="EAAG...your-meta-system-user-access-token"
PHONE_NUMBER_ID="10987654321"
VERIFY_TOKEN="agrolith_whatsapp_verify_token_2026"

# ─── CORS Security Settings ───────────────────────────────────────────────────
BACKEND_CORS_ORIGINS=["https://agrolith.web.app","https://agrolith-backend.up.railway.app","*"]

# ─── Database Connection ───────────────────────────────────────────────────────
DATABASE_URL="sqlite:///./agrolith_prod.db"
```

---

## 2. 🚂 Railway Deployment Guide

Railway uses [`railway.json`](file:///d:/Hackthon/railway.json) and Nixpacks to build and run the Python container.

### Step-by-step Railway Deployment:
```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Authenticate Railway CLI
railway login

# 3. Link or create project
railway link

# 4. Set production environment variables
railway variables set GEMINI_API_KEY="AIzaSy..."
railway variables set WHATSAPP_TOKEN="EAAG..."
railway variables set PHONE_NUMBER_ID="10987654321"
railway variables set VERIFY_TOKEN="agrolith_whatsapp_verify_token_2026"
railway variables set SECRET_KEY="PROD_SECRET_KEY_SUPER_SECURE_32_CHAR_MIN"

# 5. Deploy to Railway Production
railway up
```

- **Production Startup Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 4`
- **Healthcheck Path**: `/api/v1/health`

---

## 3. ☁️ Render Deployment Guide

Render uses [`render.yaml`](file:///d:/Hackthon/render.yaml) Blueprint configuration.

```bash
# Render CLI / Git Push Deployment
git add .
git commit -m "deploy: prepare release"
git push origin main
```
1. Open [Render Dashboard](https://dashboard.render.com/).
2. Select **New +** → **Blueprint**.
3. Choose repository and select `render.yaml`.
4. Render provisions the service and exposes `https://agrolith-backend.onrender.com`.

---

## 4. 📱 Flutter Production Builds (APK & Web)

### Flutter Android Release APK
```bash
cd frontend

# 1. Install dependencies
flutter pub get

# 2. Build Release APK with Production API URL
flutter build apk --release \
  --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1

# 3. Build Play Store App Bundle (AAB)
flutter build appbundle --release \
  --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1
```
*Output APK path*: `frontend/build/app/outputs/flutter-apk/app-release.apk`

### Flutter Web Release Bundle
```bash
cd frontend

# Build Web Bundle
flutter build web --release \
  --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1
```
*Output Web path*: `frontend/build/web/`

---

## 5. 💬 Meta WhatsApp Cloud API & ngrok Tunnel Setup

### Localhost ngrok Tunnel
```bash
# 1. Start backend server locally
uvicorn app.main:app --reload --port 8000

# 2. Start ngrok tunnel
ngrok http 8000
```

### Meta Developer Console Setup
1. Webhook Callback URL: `https://<your-subdomain>.ngrok-free.app/api/v1/whatsapp/webhook`
   *(Production URL: `https://agrolith-backend.up.railway.app/api/v1/whatsapp/webhook`)*
2. Verify Token: `agrolith_whatsapp_verify_token_2026`
3. Subscribe to webhook fields: `messages`

---

## 6. ✅ Final Deployment Verification Checklist

- [x] Backend service returns HTTP 200 OK on `/api/v1/health`.
- [x] Meta WhatsApp Webhook GET challenge returns HTTP 200 OK.
- [x] Meta WhatsApp Webhook POST receivers respond in `< 3 seconds`.
- [x] Flutter DioApiClient connects with 15s timeouts & 3x exponential backoff retries.
- [x] CORS headers allow requests from Flutter Web and cloud domains.
- [x] JWT authentication works for registration and login.
- [x] Disease detection Vision API, Voice STT/TTS, and Mandi price lookup succeed.

---

## 🔗 Production URLs to Test After Deployment

Replace `<YOUR_PRODUCTION_DOMAIN>` with your live domain (e.g., `agrolith-backend.up.railway.app`):

| Test Purpose | Method | Target URL | Expected Response |
|--------------|--------|------------|-------------------|
| **System Health Check** | `GET` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/health` | `{"status": "ok", "project_name": "Agrolith-AI Backend", ...}` |
| **Interactive API Documentation** | `GET` | `https://<YOUR_PRODUCTION_DOMAIN>/docs` | Swagger UI Interface |
| **WhatsApp Webhook Verification** | `GET` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/whatsapp/webhook?hub.mode=subscribe&hub.verify_token=agrolith_whatsapp_verify_token_2026&hub.challenge=test_123` | `test_123` (text/plain) |
| **User Registration** | `POST` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/auth/register` | `{"id": "...", "email": "...", ...}` |
| **User Login (JWT Token)** | `POST` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/auth/login` | `{"access_token": "...", "token_type": "bearer"}` |
| **AI Farmer Advisory** | `POST` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/ai/query` | `{"response_text": "...", "detected_language": "en"}` |
| **Live Weather Advisory** | `GET` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/ai/weather?lat=17.3850&lon=78.4867` | `{"temperature_c": 28.5, "condition": "...", ...}` |
| **Mandi Market Prices** | `POST` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/agri/market-price` | `{"crop_name": "Rice", "prices": [...], ...}` |
| **Government Schemes** | `POST` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/agri/schemes` | `{"matched_schemes": [...], "summary": "..."}` |
| **Soil Health Advisory** | `POST` | `https://<YOUR_PRODUCTION_DOMAIN>/api/v1/agri/soil-health` | `{"ph_interpretation": "...", "organic_amendments": [...]}` |
