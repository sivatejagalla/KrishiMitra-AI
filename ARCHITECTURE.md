# 🏗️ Agrolith-AI — System Architecture & Technical Specification

This document provides a comprehensive technical overview and architectural blueprint for **Agrolith-AI**.

---

## 🎨 System Architecture Diagram (SVG Visual)

![Agrolith-AI Architecture Diagram](architecture.svg)

---

## 📊 System Architecture Diagram (Mermaid Definition)

```mermaid
graph TD
    %% Client Layer
    subgraph CLIENTS ["📱 Client & Access Channels Layer"]
        FLUTTER["📱 Flutter 3 Mobile App<br/>(Material 3 / Riverpod / GoRouter / Hive)"]
        WHATSAPP["💬 WhatsApp AI Assistant<br/>(Meta WhatsApp Cloud API / Webhook)"]
    end

    %% FastAPI Backend Core
    subgraph BACKEND ["⚡ FastAPI Microservice Engine (Python 3.14 / Uvicorn Async)"]
        ROUTER["API Router & Middleware<br/>(/api/v1/auth, /ai, /agri, /whatsapp)"]
        AUTH_SEC["Security & Auth Service<br/>(OAuth2 JWT / bcrypt / Firebase Admin)"]
        LANG_ENG["Multilingual Engine<br/>(Auto-Detect & Translate 5 Locales)"]
        CHAT_MEM["Chat Memory Service<br/>(Multi-turn History Sync)"]
    end

    %% Agricultural Intelligence Services
    subgraph SERVICES ["🌾 Agricultural Intelligence & Speech Services Layer"]
        DISEASE["🔬 Crop Disease Scanner<br/>(Gemini Vision AI Analysis)"]
        WEATHER["🌦️ Weather Advisory<br/>(Open-Meteo GPS Forecasts)"]
        MARKET["💰 Market Prices Engine<br/>(Agmarknet Mandi Rates & Advice)"]
        SCHEMES["🏛️ Government Schemes Advisor<br/>(PM-KISAN / PMFBY / KCC Matcher)"]
        SOIL["🌱 Soil Health Advisor<br/>(pH Diagnosis & Bio Amendments)"]
        STT["🎙️ Speech-to-Text STT<br/>(Gemini Audio API Transcription)"]
        TTS["🔊 Text-to-Speech TTS<br/>(gTTS Audio Synthesis MP3)"]
    end

    %% External Infrastructure & Cloud Providers
    subgraph INFRA ["☁️ External AI Providers & Cloud Infrastructure"]
        GEMINI["🤖 Google Gemini 2.5 AI<br/>(Vision / Audio / Multilingual LLM)"]
        FIREBASE["🔥 Firebase Cloud<br/>(Auth & Firestore Memory)"]
        WEATHER_API["🌦️ Open-Meteo Weather API"]
        DATABASE["💾 SQLite / PostgreSQL DB<br/>(Alembic Migrations)"]
    end

    %% Connections
    CLIENTS -->|HTTPS / REST API| ROUTER
    CLIENTS -->|Webhook GET/POST| ROUTER
    
    ROUTER --> AUTH_SEC
    ROUTER --> LANG_ENG
    ROUTER --> CHAT_MEM

    ROUTER --> DISEASE
    ROUTER --> WEATHER
    ROUTER --> MARKET
    ROUTER --> SCHEMES
    ROUTER --> SOIL
    ROUTER --> STT
    ROUTER --> TTS

    DISEASE -->|Base64 Image| GEMINI
    STT -->|Audio Stream| GEMINI
    SCHEMES -->|Farmer Context| GEMINI
    SOIL -->|Agronomy Queries| GEMINI

    WEATHER -->|GPS Coordinates| WEATHER_API
    AUTH_SEC -->|Token Validation| FIREBASE
    CHAT_MEM -->|Session History| FIREBASE
    AUTH_SEC -->|User Store| DATABASE
```

---

## 🧱 Component Breakdown

### 1. 📱 Flutter 3 Mobile App
- **UI Framework**: Material 3 design system with dynamic light/dark green color palettes.
- **State Management**: `flutter_riverpod` for reactive, decoupled state injection.
- **Routing**: `go_router` with location-synced bottom navigation and authentication redirects.
- **Networking & Resilience**: `DioApiClient` with 15s connection timeouts and 3x exponential backoff retries.
- **Offline Caching**: `hive` for persistent offline storage of weather data, chat sessions, and user settings.

### 2. 💬 Meta WhatsApp Cloud API Bot
- **Webhook Receiver**: `GET /api/v1/whatsapp/webhook` handles automatic Meta challenge verification.
- **Async Event Handler**: `POST /api/v1/whatsapp/webhook` uses FastAPI `BackgroundTasks` to guarantee response times under **< 3 seconds**.
- **Multi-Modal Support**: Receives incoming Text queries, Crop Photos, Voice Notes, and Soil Test PDF documents.

### 3. ⚡ FastAPI Microservice Engine
- **Asynchronous Execution**: Powered by Uvicorn and Python 3.14 async event loops.
- **Structured Middleware**: Performance timing logger and Pydantic schema validation handlers.
- **Security**: OAuth2 Bearer JWT tokens, bcrypt password hashing, and Firebase Admin SDK credentials.

### 4. 🤖 Google Gemini 2.5 AI & Multilingual Engine
- **Gemini 2.5 Flash**: Multilingual LLM for organic agricultural advisory.
- **Gemini Vision**: High-accuracy plant pathology diagnosis from leaf images.
- **Gemini Audio STT**: Speech-to-text conversion for voice queries in Indian regional accents.

### 5. 🌦️ Weather, Market Prices, Schemes & Soil Services
- **Weather Advisory**: Queries Open-Meteo API using farmer GPS coordinates to generate spray and harvest advisories.
- **Mandi Market Prices**: Real-time mandi rates, price trend indicators (Rising/Falling/Stable), and selling window advice.
- **Government Schemes**: Matches farmers against PM-KISAN, PMFBY, KCC, PKVY, and state subsidies with direct website links.
- **Soil Health Advisor**: Interactive pH scale diagnosis (0–14), deficiency identification, and organic amendment plans.
