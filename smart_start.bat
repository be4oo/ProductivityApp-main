@echo off
echo ===============================================
echo Blitzit App - Smart Launcher
echo ===============================================
echo.

cd /d "d:\AI Project\ProductivityApp-main\frontend"

echo Checking Flutter setup...
flutter doctor --android-licenses >nul 2>&1

echo.
echo Attempting to run Windows desktop version...
flutter run -d windows

if %errorlevel% neq 0 (
    echo.
    echo ❌ Windows desktop build failed
    echo.
    echo This is likely because Visual Studio Build Tools are not installed.
    echo.
    echo 🌐 Falling back to web version...
    echo.
    timeout /t 3 /nobreak >nul
    
    echo Starting web version in Chrome...
    flutter run -d chrome
    
    if %errorlevel% neq 0 (
        echo.
        echo ❌ Web version also failed
        echo.
        echo Please run the complete setup:
        echo   complete_setup.bat
        echo.
        echo Or install Visual Studio manually:
        echo   install_visual_studio.bat
        echo.
        pause
        exit /b 1
    )
    
    echo.
    echo ✅ Web version started successfully!
    echo.
    echo To enable Windows desktop version:
    echo 1. Install Visual Studio Build Tools
    echo 2. Run: complete_setup.bat
    echo.
) else (
    echo.
    echo ✅ Windows desktop version started successfully!
)

echo.
echo App is now running. Press Ctrl+C to stop.
pause
