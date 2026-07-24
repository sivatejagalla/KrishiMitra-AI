# 🚀 Agrolith-AI — Production Deployment Guide

This guide details how to deploy the **Agrolith-AI** FastAPI Backend, Meta WhatsApp Cloud API Assistant, and Flutter Mobile Application across **Localhost**, **ngrok**, **Render**, **Railway**, and **Docker**.

---

## 📋 Environment Configuration Matrix

| Environment | Host/Port | Base API URL | Webhook URL |
|-------------|-----------|--------------|-------------|
| **Localhost (Dev)** | `127.0.0.1:8000` | `http://127.0.0.1:8000/api/v1` | `http://127.0.0.1:8000/api/v1/whatsapp/webhook` |
| **Android Emulator** | `10.0.2.2:8000` | `http://10.0.2.2:8000/api/v1` | N/A |
| **ngrok (Dev Tunnel)** | `*.ngrok-free.app` | `https://*.ngrok-free.app/api/v1` | `https://*.ngrok-free.app/api/v1/whatsapp/webhook` |
| **Render (Cloud)** | `*.onrender.com` | `https://*.onrender.com/api/v1` | `https://*.onrender.com/api/v1/whatsapp/webhook` |
| **Railway (Cloud)** | `*.up.railway.app` | `https://*.up.railway.app/api/v1` | `https://*.up.railway.app/api/v1/whatsapp/webhook` |

---

## 1. 💻 Localhost & Development Setup

### Backend Setup
```bash
# 1. Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment variables
cp .env.example .env

# 4. Start backend server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- API Docs: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/api/v1/health`

---

## 2. 🌐 ngrok Setup for Meta WhatsApp Webhook

To connect Meta's WhatsApp Cloud API to your local development backend:

```bash
# Start ngrok tunnel on port 8000
ngrok http 8000
```

1. Copy the HTTPS URL from ngrok output (e.g. `https://a1b2c3.ngrok-free.app`).
2. Go to **Meta Developer Portal** → **WhatsApp** → **Configuration** → **Edit Webhook**.
3. **Callback URL**: `https://a1b2c3.ngrok-free.app/api/v1/whatsapp/webhook`
4. **Verify Token**: `agrolith_whatsapp_verify_token_2026`
5. Click **Verify and Save**.
6. Subscribe to the `messages` event.

---

## 3. ☁️ Render Cloud Deployment

### Automated Blueprint Deployment
1. Connect your GitHub repository to [Render](https://render.com/).
2. Click **New +** → **Blueprint**.
3. Select `render.yaml` from the root directory.
4. Set Environment Variables in Render Dashboard:
   - `GEMINI_API_KEY`: Your Google Gemini API Key
   - `WHATSAPP_TOKEN`: Meta WhatsApp System User Access Token
   - `PHONE_NUMBER_ID`: Meta WhatsApp Phone Number ID
   - `VERIFY_TOKEN`: `agrolith_whatsapp_verify_token_2026`
5. Click **Apply**. Render will automatically build and deploy the container.

---

## 4. 🚂 Railway Deployment

1. Connect your repository to [Railway](https://railway.app/).
2. Select **Deploy from GitHub Repo**.
3. Railway automatically detects `railway.json` and uses Nixpacks build system.
4. Add Environment Variables under **Variables**:
   - `GEMINI_API_KEY`
   - `WHATSAPP_TOKEN`
   - `PHONE_NUMBER_ID`
   - `VERIFY_TOKEN`
5. Enable **Generate Domain** under Settings to expose your production URL.

---

## 5. 🐳 Docker & Docker Compose Deployment

```bash
# Build and start container background service
docker-compose up -d --build

# View container logs
docker-compose logs -f backend

# Stop container
docker-compose down
```

---

## 6. 📱 Flutter App Production Build

```bash
cd frontend

# 1. Get dependencies
flutter pub get

# 2. Build Android APK (Release)
flutter build apk --release

# 3. Build Android App Bundle (Play Store)
flutter build appbundle --release
```
Output APK location: `frontend/build/app/outputs/flutter-apk/app-release.apk`
