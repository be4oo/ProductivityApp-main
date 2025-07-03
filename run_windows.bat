@echo off
REM Blitzit Windows Setup and Run Script
echo 🚀 Blitzit Windows Desktop Setup
echo ================================

echo Step 1: Checking Windows Developer Mode...
echo.
echo ⚠️  IMPORTANT: This app requires Windows Developer Mode
echo.
echo Opening Windows Developer Mode settings...
start ms-settings:developers
echo.
echo In the settings window that opened:
echo 1. Find "Developer Mode" 
echo 2. Toggle it to "ON"
echo 3. Click "Yes" when prompted
echo 4. Wait for any downloads to complete
echo.
echo After enabling Developer Mode, press any key to continue...
pause >nul

echo.
echo Step 2: Setting up Flutter project...
cd /d "%~dp0\frontend"

echo Enabling Windows desktop support...
flutter config --enable-windows-desktop

echo Adding Windows platform files...
flutter create --platforms=windows .

echo Cleaning previous builds...
flutter clean

echo Installing dependencies...
flutter pub get

echo.
echo Step 3: Starting the app...
echo.
echo Building and running Blitzit...
flutter run -d windows

echo.
if %errorlevel% neq 0 (
    echo ❌ App failed to start
    echo.
    echo Common solutions:
    echo 1. Ensure Developer Mode is enabled
    echo 2. Restart this script after enabling Developer Mode
    echo 3. Run as Administrator if needed
    echo.
    pause
) else (
    echo ✅ App should be running now!
    echo.
    echo The Blitzit desktop application window should have opened.
    echo If not, check for any error messages above.
    echo.
)

echo Press any key to exit...
pause >nul
