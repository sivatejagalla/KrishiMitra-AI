# ⏱️ Agrolith-AI — 3-Minute Judge Presentation Guide

Use this script and slide outline for your 3-minute hackathon pitch and live demonstration.

---

## 📊 Slide & Pitch Outline

```text
[0:00 - 0:30]  Problem Statement & The Challenge for Indian Farmers
[0:30 - 1:15]  Our Solution: Agrolith-AI (Multilingual Flutter App + WhatsApp AI)
[1:15 - 2:15]  Live Product Demo (Crop Disease Vision, Voice Assistant, Mandi Prices)
[2:15 - 2:45]  Technical Architecture & AI Capabilities (Gemini 2.5, FastAPI, Meta Cloud)
[2:45 - 3:00]  Impact, Scalability & Next Steps
```

---

## 🎙️ 3-Minute Presentation Script

### 🕒 [0:00 - 0:30] The Hook & Problem
> *"Judges, over 140 million farmers in India face three daily crises: undetected crop diseases, fluctuating mandi market prices, and complex government scheme eligibility. Language barriers and low digital literacy make existing apps unusable for the average farmer."*

### 🕒 [0:30 - 1:15] Introducing Agrolith-AI
> *"Meet **Agrolith-AI** — a smart, multilingual agricultural assistant powered by Google Gemini 2.5 and FastAPI. Agrolith works where farmers already are: as a premium **Material 3 Flutter Mobile App** AND directly on **WhatsApp** via Meta's Cloud API."*

> *"Whether a farmer types in English, speaks in Telugu, or sends a voice note in Hindi, Agrolith automatically detects the language and responds with tailored, organic-first advisory."*

### 🕒 [1:15 - 2:15] Live Demonstration
> *"Let us show you two powerful features live right now:"*

1. **Crop Disease Vision Scanner**:
   > *"First, leaf disease diagnosis. A farmer uploads a photo of a diseased paddy leaf. In under 2 seconds, Gemini Vision identifies **Rice Blast**, rates severity as **Moderate**, and provides step-by-step organic remedies like Trichoderma viride."*

2. **WhatsApp Voice Assistant**:
   > *"Second, zero-friction WhatsApp voice interaction. A farmer sends a 5-second voice note asking for Mandi wheat prices. Agrolith transcribes the audio, fetches live mandi rates, and replies with both text and a voice response!"*

### 🕒 [2:15 - 2:45] Technical Architecture & Innovation
> *"Under the hood, Agrolith is built with:"*
> - **FastAPI Microservices** with async background tasks and 20/20 test coverage.
> - **Google Gemini 2.5 Flash** for Vision, Audio STT, and Advisory generation.
> - **Flutter 3 with Riverpod & GoRouter** for a responsive, offline-cached mobile UX.
> - **Meta WhatsApp Cloud API Webhook** for instant messaging access.

### 🕒 [2:45 - 3:00] Impact & Conclusion
> *"Agrolith bridges the gap between state-of-the-art Generative AI and rural farmers, saving crops and boosting incomes across India. Thank you, and we welcome your questions!"*

---

## ❓ Anticipated Judge Q&A

**Q1: How do you handle poor internet connectivity in rural areas?**
> *Answer: The Flutter app uses Hive for offline local caching of weather, chat history, and bio-input catalogs. For non-smartphone users, the WhatsApp channel handles low-bandwidth text and audio messaging.*

**Q2: Is the advice safe and scientifically verified?**
> *Answer: Yes, Agrolith prioritizes ICAR-recommended organic amendments, bio-fertilizers (Azospirillum, Trichoderma), and standardized government mandi prices.*

**Q3: How fast does the WhatsApp webhook process messages?**
> *Answer: FastAPI offloads message dispatching to `BackgroundTasks`, returning HTTP 200 OK to Meta in under 3 milliseconds to guarantee zero timeouts.*
