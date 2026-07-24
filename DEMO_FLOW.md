# 🎯 Agrolith-AI — Judge Demonstration Flow

This step-by-step guide walks judges and evaluators through a full live demonstration of **Agrolith-AI** across the **Flutter Mobile App** and the **WhatsApp Cloud API Assistant**.

---

## 🎬 Act 1: Multilingual Onboarding & Authentication (1 Minute)

### 1. Splash Screen & Language Selection
- Launch the Flutter App on device or emulator.
- Observe the animated green Wheat/Leaf logo entrance and smooth transition.
- Tap the **Language Dropdown** at the top right of the Login Screen.
- Select **తెలుగు (Telugu)** or **हिंदी (Hindi)** to demonstrate instant UI localization.

### 2. Farmer Registration & Login
- Tap **Register New Account**.
- Fill in:
  - Name: `Ramesh Farmer`
  - Email: `ramesh@agrolith.ai`
  - Password: `Password123`
- Tap **Register Account**. The app authenticates via FastAPI `/api/v1/auth/register` and redirects to the **Smart Farming Dashboard**.

---

## 🎬 Act 2: Smart Farming Dashboard & Live Weather (45 Seconds)

### 1. Dashboard Overview
- Observe the time-based greeting (*"Good Afternoon, Ramesh!"*) and user profile avatar.
- Point out the **Live Weather Card**:
  - Displays live temperature (°C), weather condition, humidity %, wind speed (km/h).
  - Highlights Gemini AI Agricultural Advisory (*"Ideal conditions for crop spraying"*).
- Demonstrate pull-to-refresh pulling live data from Open-Meteo API.

---

## 🎬 Act 3: Crop Disease Scanner (AI Vision) (1 Minute)

### 1. Leaf Disease Diagnosis
- Tap **Disease Scan** on the dashboard or Agri Tools menu.
- Tap **Choose Photo** / **Take Photo** and select a leaf image showing yellow spots or blast lesions.
- Enter optional crop name: `Paddy`.
- Tap **Analyze Crop Image**.
- Observe the loading overlay (*"Analyzing plant with Gemini AI Vision..."*).
- Review the AI Diagnosis Card:
  - **Disease Name**: *Rice Blast (Magnaporthe oryzae)*
  - **Severity Badge**: *Moderate* (Yellow/Orange chip)
  - **Confidence Meter**: *78.5%*
  - **Tabs**: View *Symptoms*, *Organic Treatments* (Trichoderma viride spray), *Chemical Treatments*, and *Prevention*.

---

## 🎬 Act 4: WhatsApp AI Assistant Dual-Channel Demo (1 Minute)

### 1. Text Query via WhatsApp
- Send a WhatsApp message to the Agrolith bot number:
  > *"What is the current mandi price of wheat in Telangana?"*
- Observe the instant reply (< 2 seconds):
  > 💰 *Mandi Market Rates (Wheat)*
  > • Karimnagar Mandi: ₹2,250/Quintal
  > 📈 Trend: Stable | 💡 Selling Advice: Hold for 2 weeks for optimal rates.

### 2. Voice Note Query via WhatsApp
- Record a voice note in Hindi or English:
  > *"धान की पत्तियां पीली पड़ रही हैं, क्या उपाय करें?"*
- The WhatsApp assistant transcribes the audio, analyzes the crop problem, and replies with both a **Text Summary** and a **Voice Note Response**.

---

## 🎬 Act 5: Soil Health & Mandi Prices (45 Seconds)

### 1. Soil Health Slider & pH Scale
- Open **Soil Health** in the app.
- Slide the interactive pH scale to **5.2** (Acidic).
- Tap **Analyze Soil Health**.
- Review the output:
  - **pH Diagnosis**: *Acidic Soil* (Red indicator)
  - **Deficiency Identified**: *Nitrogen*, *Zinc* (Red chips)
  - **Organic Amendments**: *Apply agricultural lime at 1 ton/acre*.

---

## 🏆 Key Highlights to Point Out to Judges
1. **True Multilingual Intelligence**: Automatically detects 5 Indian languages and responds in the exact same script.
2. **Dual Access Channels**: Works as a native Flutter App for smartphones AND a WhatsApp Assistant for feature phone access.
3. **Organic-First Focus**: Prioritizes bio-fertilizers, neem oil, and eco-friendly soil amendments.
