# 🌾 Agrolith-AI — Production Ready System

**Agrolith-AI** is a production-grade, AI-powered agricultural advisory platform designed for Indian farmers. It seamlessly combines a **FastAPI Microservice**, a **Meta WhatsApp Cloud API Assistant**, and a **Flutter 3 (Material 3) Mobile Application**.

---

## 🌟 Production Capabilities

- 🤖 **Multilingual Gemini 2.5 AI Advisory**: Context-aware organic farming & pest control guidance in English, Hindi, Telugu, Tamil, and Marathi.
- 📱 **WhatsApp AI Assistant**: Dual-channel assistant capable of processing incoming Text, Plant Photos (AI Vision), Voice Notes (STT/TTS), and Soil Test Reports.
- 🔬 **AI Crop Disease Scanner**: Instant plant disease identification from leaf photos with severity ratings and organic/chemical treatments.
- 🌦️ **Agricultural Weather Intelligence**: Live Open-Meteo weather API integration providing tailored spray and harvest advisories.
- 💰 **Mandi Market Prices**: Real-time crop rate tracking with price trend indicators and selling window advice.
- 🏛️ **Government Schemes Engine**: Intelligently matches farmers to PM-KISAN, PMFBY, KCC, PKVY, and state subsidies.
- 🌱 **Soil Health & Fertilizer Advisor**: Interactive pH diagnosis, nutrient deficiency identification, and organic amendment plans.
- 🔒 **Enterprise Security**: OAuth2 JWT authentication, password hashing with bcrypt, Firebase Admin SDK integration, and CORS protection.

---

## 🏗️ System Architecture

```text
                                 ┌─────────────────────────────────┐
                                 │   Meta WhatsApp Cloud API       │
                                 └────────────────┬────────────────┘
                                                  │ Webhook (HTTPS)
                                                  ▼
┌────────────────────────┐       ┌─────────────────────────────────┐       ┌────────────────────────┐
│  Flutter Mobile App    ├──────►│      FastAPI Backend Engine     │◄──────┤  Open-Meteo Weather    │
│  (Material 3 / Riverpod)│ REST  │  (Uvicorn / Pydantic / Async)   │ REST  │        API             │
└────────────────────────┘       └────────────────┬────────────────┘       └────────────────────────┘
                                                  │
                                                  ▼
                                 ┌─────────────────────────────────┐
                                 │      Google Gemini 2.5 AI       │
                                 │   (Vision + Audio + Text)       │
                                 └─────────────────────────────────┘
```

---

## 📁 Repository Overview

- **`app/`**: FastAPI application core (endpoints, services, schemas, middleware, models).
- **`frontend/`**: Flutter mobile application (13 feature modules, Material 3 theme system).
- **`tests/`**: Automated pytest test suite (20/20 test coverage across all features).
- **`Dockerfile` & `docker-compose.yml`**: Containerization setup.
- **`Procfile`**, **`render.yaml`**, **`railway.json`**: Production Cloud platform deployment manifests.
- **`DEPLOYMENT.md`**: Step-by-step deployment guide.
- **`CHECKLIST.md`**: Pre-launch production verification checklist.
- **`DEMO_FLOW.md`**: Step-by-step judge demonstration guide.
- **`PRESENTATION.md`**: 3-minute pitch deck and presentation script.
