@echo off
REM Frontend startup script for Blitzit Flutter App
echo Starting Blitzit Flutter Desktop Application...

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Navigate to frontend directory
cd /d "%~dp0"

REM Clean build
echo Cleaning previous build...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Run the app
echo Starting Flutter app...
flutter run -d windows
