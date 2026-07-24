# 🌾 Agrolith-AI Backend & WhatsApp AI Assistant

**Agrolith-AI** is an intelligent FastAPI-based backend and WhatsApp AI Assistant that empowers Indian farmers with:

- 📱 **WhatsApp AI Assistant** — Complete Meta WhatsApp Cloud API integration (Text, Crop Images, Voice Notes, Documents)
- 🤖 **Gemini AI Advisory** — Multilingual farmer Q&A with contextual, organic-farming guidance
- 🔬 **Crop Disease Detection** — AI Vision analysis of plant images (Gemini Vision)
- 🌦️ **Live Weather Advisory** — GPS-based weather data via Open-Meteo API
- 💰 **Mandi Market Prices** — Real-time crop price data with selling advisory
- 🏛️ **Government Scheme Advisor** — Matches PM-KISAN, PMFBY, KCC, PKVY and more
- 🌱 **Soil Health Analysis** — pH interpretation, deficiency detection, organic amendments
- 🧬 **Bio-Input Recommendations** — Trichoderma, Azospirillum, Neem Oil, and more
- 🗣️ **Voice TTS/STT** — Multi-language speech synthesis (gTTS) and Gemini-based transcription
- 🌐 **5 Languages** — English, Hindi, Telugu, Tamil, Marathi with auto-detection

---

## Project Structure

```
d:\Hackthon\
├── app/
│   ├── api/
│   │   ├── endpoints/
│   │   │   ├── auth.py          # Registration, Login, Firebase Auth, /me
│   │   │   ├── health.py        # Health check
│   │   │   ├── ai.py            # AI query, TTS, STT, Weather, Bio recs, Chat history
│   │   │   ├── agri.py          # Disease detection, Market prices, Schemes, Soil health
│   │   │   └── whatsapp.py      # WhatsApp Cloud API Webhook Verification & Receiver
│   │   ├── deps.py              # JWT dependency injection
│   │   └── router.py            # Root API router
│   ├── core/
│   │   ├── config.py            # Pydantic settings (env-driven)
│   │   ├── exceptions.py        # Custom exception hierarchy + handlers
│   │   ├── firebase.py          # Firebase Admin SDK init + token verification
│   │   ├── logger.py            # Structured logging setup
│   │   └── security.py          # JWT creation/decoding, bcrypt hashing
│   ├── middleware/
│   │   └── logging_middleware.py  # Request/response timing logger
│   ├── models/
│   │   └── user.py              # UserModel + in-memory UserStore
│   ├── schemas/
│   │   ├── auth.py              # Token, UserCreate, UserResponse, HealthCheck
│   │   ├── ai.py                # FarmerQuery, WeatherInfo, BioProduct, Chat schemas
│   │   └── agri.py              # Disease, MarketPrice, Scheme, SoilHealth schemas
│   ├── services/
│   │   ├── whatsapp_service.py  # Meta Graph API client, Media downloader, Intent router
│   │   ├── auth_service.py      # Registration, Login, Firebase token provisioning
│   │   ├── gemini_service.py    # Gemini AI advisory generation
│   │   ├── weather_service.py   # Open-Meteo weather API client
│   │   ├── speech_service.py    # gTTS (TTS) + Gemini Audio (STT)
│   │   ├── language_service.py  # Unicode language detection + Google Translate
│   │   ├── chat_memory_service.py  # Multi-turn memory (in-memory + Firestore)
│   │   ├── bio_recommendation_service.py  # Bio-input product catalog matching
│   │   ├── crop_disease_service.py       # Gemini Vision disease analysis
│   │   ├── market_price_service.py       # Mandi price data + selling advisory
│   │   ├── government_scheme_service.py  # Gov. scheme keyword matching
│   │   └── soil_health_service.py        # pH + deficiency + amendment advisory
│   └── main.py                  # FastAPI app factory with lifespan
├── alembic/                     # Database migration scripts
├── frontend/                    # Production Flutter Frontend App
├── tests/                       # Automated pytest suite (agri, ai, auth, health, whatsapp)
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── requirements.txt
└── README.md
```

---

## 📱 Meta WhatsApp Cloud API Setup Guide

### Step 1: Create Meta Developer App
1. Go to [Meta for Developers](https://developers.facebook.com/) and log in.
2. Click **My Apps** → **Create App**.
3. Select **Other** → **Business** as app type.
4. Add **WhatsApp** product to your app.

### Step 2: Obtain API Credentials
1. Under **WhatsApp** → **API Setup**:
   - Copy **Temporary Access Token** (or create a permanent System User Token under Business Settings).
   - Copy **Phone Number ID**.
2. Add test recipient phone numbers to your WhatsApp sandbox.

### Step 3: Configure Environment Variables
Add the following credentials to your `.env` file:
```ini
WHATSAPP_TOKEN="your-meta-access-token"
PHONE_NUMBER_ID="your-whatsapp-phone-number-id"
VERIFY_TOKEN="agrolith_whatsapp_verify_token_2026"
```

### Step 4: Expose Local Backend to Internet (Development)
Use ngrok or localtunnel to expose port 8000:
```bash
ngrok http 8000
```
Copy your HTTPS forwarding URL (e.g. `https://abc1234.ngrok-free.app`).

### Step 5: Configure Meta Webhook
1. In Meta Developer Console → **WhatsApp** → **Configuration**:
   - Click **Edit Webhook**.
   - **Callback URL**: `https://abc1234.ngrok-free.app/api/v1/whatsapp/webhook`
   - **Verify Token**: `agrolith_whatsapp_verify_token_2026` (matches `VERIFY_TOKEN` in `.env`).
2. Click **Verify and Save**. FastAPI will automatically verify Meta's challenge string.
3. Under **Webhook Fields**, subscribe to `messages`.

---

## 📲 How WhatsApp AI Features Work

| Farmer Message Type | Processing Logic & AI Services Used |
|---------------------|-------------------------------------|
| **💬 Text Query** | Auto-detects language (`language_service`), routes by intent (Weather, Mandi Prices, Schemes, Soil, or Gemini Advisory), translates response to native language, saves turn in `chat_memory_service`. |
| **📷 Crop Photo** | Downloads photo from Meta Graph API, converts to base64, passes to Gemini Vision (`crop_disease_service`), generates diagnosis (disease name, severity, organic & chemical treatments), sends formatted report. |
| **🎙️ Voice Note** | Downloads audio, converts to transcript text using Gemini STT (`speech_service`), processes query, generates AI reply, synthesizes audio MP3 (`gTTS`), sends transcript + audio reply back. |
| **📄 Document / Report** | Downloads PDF/Image report, analyzes soil pH and nutrient deficiencies (`soil_health_service`), sends structured amendment advisory. |

---

## API Endpoints Reference

### 🏥 Health & Webhooks
| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/v1/health` | Service health check & metadata |
| GET | `/api/v1/whatsapp/webhook` | Automatic GET webhook verification for Meta Cloud API |
| POST | `/api/v1/whatsapp/webhook` | Meta Cloud API webhook event receiver (background task dispatch) |

### 🔐 Authentication (`/api/v1/auth`)
| Method | URL | Description |
|--------|-----|-------------|
| POST | `/api/v1/auth/register` | Register new user (email + password) |
| POST | `/api/v1/auth/login` | Login → JWT access token |
| GET | `/api/v1/auth/me` | Get authenticated user profile |

### 🤖 AI Advisory (`/api/v1/ai`)
| Method | URL | Description |
|--------|-----|-------------|
| POST | `/api/v1/ai/query` | Unified farmer advisory (text/voice, multilingual) |
| POST | `/api/v1/ai/tts` | Text → base64 MP3 audio (gTTS) |
| POST | `/api/v1/ai/stt` | Base64 audio → transcript (Gemini Audio) |
| GET | `/api/v1/ai/weather` | Live weather + farming advice (`?lat=...&lon=...`) |

### 🌾 Agriculture Intelligence (`/api/v1/agri`)
| Method | URL | Description |
|--------|-----|-------------|
| POST | `/api/v1/agri/disease-detection` | Crop disease detection from base64 image (Gemini Vision) |
| POST | `/api/v1/agri/market-price` | Mandi market price + selling advisory |
| POST | `/api/v1/agri/schemes` | Government scheme matching (PM-KISAN, PMFBY, etc.) |
| POST | `/api/v1/agri/soil-health` | Soil pH + deficiency + organic amendment advisory |

---

## Testing
```bash
# Run complete backend test suite (includes WhatsApp tests)
python -m pytest tests/ -v
```
