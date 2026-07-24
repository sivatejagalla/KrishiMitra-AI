@echo off
echo ====================================================
echo 🌾 Agrolith-AI — Production Deployment Tool
echo ====================================================

REM 1. Environment Copy
if not exist .env.production (
    echo ⚠️ .env.production missing! Copying from .env.example...
    copy .env.example .env.production
)

echo ✅ Environment configured.

REM 2. Build Docker Container
echo 🐳 Building Production Docker Image...
docker build -t agrolith-backend:latest .

REM 3. Build Flutter Web Production Bundle
echo 🌐 Building Flutter Web Production Application...
cd frontend
call flutter pub get
call flutter build web --release --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1
cd ..

REM 4. Build Flutter Android APK
echo 📱 Building Flutter Android Release APK...
cd frontend
call flutter build apk --release --dart-define=API_URL=https://agrolith-backend.up.railway.app/api/v1
cd ..

echo ====================================================
echo 🎉 Agrolith-AI Production Build Completed Successfully!
echo ====================================================
