#!/bin/bash
# 🚀 Agrolith-AI — Production Deployment Automation Script

set -e

echo "===================================================="
echo "🌾 Agrolith-AI — Production Deployment Tool"
echo "===================================================="

# 1. Environment Check
if [ ! -f .env.production ]; then
    echo "⚠️ .env.production missing! Copying from .env.example..."
    cp .env.example .env.production
fi

echo "✅ Environment configured."

# 2. Build Docker Container
echo "🐳 Building Production Docker Image..."
docker build -t agrolith-backend:latest .

# 3. Build Flutter Web Production Bundle
echo "🌐 Building Flutter Web Production Application..."
cd frontend
flutter pub get
flutter build web --release --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1
cd ..

# 4. Build Flutter Android APK
echo "📱 Building Flutter Android Release APK..."
cd frontend
flutter build apk --release --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1
cd ..

echo "===================================================="
echo "🎉 Agrolith-AI Production Build Completed Successfully!"
echo "===================================================="
