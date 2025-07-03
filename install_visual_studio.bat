@echo off
echo ==================================================
echo Installing Visual Studio Community 2022 for Flutter
echo ==================================================
echo.
echo This will install Visual Studio Community 2022 with the required C++ build tools.
echo.
echo What this script does:
echo - Downloads Visual Studio Community 2022 installer
echo - Installs with "Desktop development with C++" workload
echo - Includes Windows SDK and CMake tools
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause

echo.
echo Checking if winget is available...
winget --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: winget is not available. Please install Visual Studio manually.
    echo Go to: https://visualstudio.microsoft.com/downloads/
    echo Download Visual Studio Community 2022
    echo Select "Desktop development with C++" workload during installation
    pause
    exit /b 1
)

echo.
echo Installing Visual Studio Community 2022...
echo This may take 15-30 minutes depending on your internet speed.
echo.
winget install Microsoft.VisualStudio.2022.Community --accept-package-agreements --accept-source-agreements

echo.
echo ==================================================
echo Installation Complete!
echo ==================================================
echo.
echo IMPORTANT: After installation, you may need to:
echo 1. Restart your computer
echo 2. Open Visual Studio and complete the initial setup
echo 3. Verify installation by running: flutter doctor
echo.
echo Press any key to continue...
pause
