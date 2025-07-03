@echo off
REM Quick Web Runner for Blitzit (while installing Visual Studio)
echo 🌐 Running Blitzit in Web Browser
echo ================================

echo Current directory: %CD%
echo.

REM Verify we're in the right place
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found
    echo Navigating to frontend directory...
    cd /d "%~dp0"
    if not exist "pubspec.yaml" (
        echo ❌ Still can't find pubspec.yaml
        echo Please run this script from the frontend directory
        pause
        exit /b 1
    )
)

echo ✅ Found pubspec.yaml
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ❌ Flutter not found in PATH
    pause
    exit /b 1
)

echo.
echo Checking available devices...
flutter devices

echo.
echo Building and running in Chrome...
flutter run -d chrome

if %errorlevel% neq 0 (
    echo.
    echo ❌ Failed to run in Chrome
    echo Trying Edge...
    flutter run -d edge
    
    if %errorlevel% neq 0 (
        echo.
        echo ❌ Web version failed
        echo.
        echo This might be due to missing dependencies.
        echo Please install Visual Studio for Windows desktop support:
        echo https://visualstudio.microsoft.com/downloads/
        echo.
        echo Or check the VISUAL_STUDIO_SETUP.md guide.
        pause
    )
)

echo.
echo Press any key to exit...
pause >nul
