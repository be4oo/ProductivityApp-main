@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Blitzit App - Complete Windows Setup
echo ========================================
echo.
echo This script will set up everything needed to run the Blitzit app on Windows:
echo - Check and install Visual Studio Build Tools
echo - Enable Windows Developer Mode
echo - Install Flutter dependencies
echo - Test the setup
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause

echo.
echo ==================================================
echo Step 1: Checking Visual Studio Build Tools
echo ==================================================

:: Check if Visual Studio is installed
set "VS_INSTALLED=false"
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC" (
    set "VS_INSTALLED=true"
    echo ✅ Visual Studio Community 2022 is installed
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC" (
    set "VS_INSTALLED=true"
    echo ✅ Visual Studio Build Tools 2022 are installed
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC" (
    set "VS_INSTALLED=true"
    echo ✅ Visual Studio Community 2019 is installed
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC" (
    set "VS_INSTALLED=true"
    echo ✅ Visual Studio Build Tools 2019 are installed
)

if "!VS_INSTALLED!"=="false" (
    echo ❌ Visual Studio Build Tools not found
    echo.
    echo Installing Visual Studio Community 2022...
    echo This may take 15-30 minutes.
    echo.
    
    :: Check if winget is available
    winget --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: winget is not available.
        echo Please install Visual Studio manually from:
        echo https://visualstudio.microsoft.com/downloads/
        echo.
        echo Select "Desktop development with C++" workload during installation.
        pause
        exit /b 1
    )
    
    :: Install Visual Studio Community
    echo Running: winget install Microsoft.VisualStudio.2022.Community
    winget install Microsoft.VisualStudio.2022.Community --accept-package-agreements --accept-source-agreements
    
    if !errorlevel! neq 0 (
        echo ERROR: Failed to install Visual Studio Community
        echo Please install manually from:
        echo https://visualstudio.microsoft.com/downloads/
        pause
        exit /b 1
    )
    
    echo.
    echo ✅ Visual Studio Community 2022 installed successfully
    echo.
    echo IMPORTANT: You may need to restart your computer after installation.
    echo After restart, run this script again to continue setup.
    echo.
    choice /M "Do you want to restart now? (Recommended)"
    if !errorlevel!==1 (
        echo Restarting computer...
        shutdown /r /t 10 /c "Restarting to complete Visual Studio installation"
        exit /b 0
    )
)

echo.
echo ==================================================
echo Step 2: Checking Windows Developer Mode
echo ==================================================

:: Check if Developer Mode is enabled
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense >nul 2>&1
if !errorlevel!==0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense 2^>nul') do set "DEV_MODE=%%a"
    if "!DEV_MODE!"=="0x1" (
        echo ✅ Windows Developer Mode is enabled
    ) else (
        echo ❌ Windows Developer Mode is disabled
        goto :enable_dev_mode
    )
) else (
    echo ❌ Windows Developer Mode is not configured
    :enable_dev_mode
    echo.
    echo Enabling Windows Developer Mode...
    echo This requires administrator privileges.
    echo.
    
    :: Try to enable Developer Mode
    powershell -Command "Start-Process powershell -ArgumentList '-Command', 'reg add \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f' -Verb RunAs"
    
    if !errorlevel!==0 (
        echo ✅ Windows Developer Mode enabled successfully
    ) else (
        echo ❌ Failed to enable Developer Mode automatically
        echo.
        echo Please enable manually:
        echo 1. Open Settings (Win + I)
        echo 2. Go to Update & Security ^> For developers
        echo 3. Turn on "Developer mode"
        echo.
        pause
    )
)

echo.
echo ==================================================
echo Step 3: Installing Flutter Dependencies
echo ==================================================

cd /d "d:\AI Project\ProductivityApp-main\frontend"

echo Running: flutter pub get
flutter pub get

if !errorlevel! neq 0 (
    echo ERROR: Failed to get Flutter dependencies
    echo Trying to fix dependencies...
    
    :: Try to fix dependencies
    flutter clean
    flutter pub get
    
    if !errorlevel! neq 0 (
        echo ERROR: Still failing to get dependencies
        echo Please check your internet connection and try again
        pause
        exit /b 1
    )
)

echo ✅ Flutter dependencies installed successfully

echo.
echo ==================================================
echo Step 4: Testing Setup
echo ==================================================

echo Running: flutter doctor
flutter doctor

echo.
echo ==================================================
echo Step 5: Starting the Application
echo ==================================================

echo Choose how to run the app:
echo 1. Windows Desktop (requires Visual Studio)
echo 2. Web Browser (Chrome)
echo 3. Skip for now
echo.
choice /C 123 /M "Select option"

if !errorlevel!==1 (
    echo Starting Windows desktop app...
    flutter run -d windows
) else if !errorlevel!==2 (
    echo Starting web app...
    flutter run -d chrome
) else (
    echo Setup complete! You can now run the app manually.
    echo.
    echo To run on Windows: flutter run -d windows
    echo To run on Web: flutter run -d chrome
)

echo.
echo ==================================================
echo Setup Complete!
echo ==================================================
echo.
echo The Blitzit app is now ready to use.
echo.
echo Available commands:
echo - run_windows.bat    : Run Windows desktop app
echo - run_web.bat        : Run web app
echo - quick_start.bat    : Quick start with automatic platform detection
echo.
pause
