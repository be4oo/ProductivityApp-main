@echo off
REM Flutter Setup Test Script for Windows

echo 🧪 Blitzit Frontend Setup Test
echo ===============================

REM Test Flutter installation
echo 🔍 Testing Flutter installation...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed
    echo Install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
) else (
    echo ✅ Flutter is installed
    flutter --version
)

REM Test Flutter doctor
echo.
echo 🩺 Running Flutter Doctor...
flutter doctor

REM Test dependencies
echo.
echo 📦 Testing Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
) else (
    echo ✅ Dependencies installed successfully
)

REM Test if backend is running
echo.
echo 🌐 Testing backend connection...
curl -s "http://localhost:8000/" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Backend is not running
    echo Start the backend first: cd ../backend && uvicorn main:app --reload
) else (
    echo ✅ Backend is running
)

REM Test build
echo.
echo 🔨 Testing Flutter build...
flutter build windows --debug
if %errorlevel% neq 0 (
    echo ❌ Flutter build failed
    pause
    exit /b 1
) else (
    echo ✅ Flutter build successful
)

echo.
echo 🎉 Frontend setup test completed!
echo Run the app with: flutter run -d windows
pause
