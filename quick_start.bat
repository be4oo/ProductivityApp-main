@echo off
REM Quick Start Script for Blitzit App
echo 🚀 Blitzit Quick Start
echo =====================

echo ⚠️  IMPORTANT: Windows Developer Mode Required
echo This app requires Windows Developer Mode to be enabled.
echo.
echo Opening Developer Mode settings...
start ms-settings:developers
echo.
echo Please enable Developer Mode in the settings window that opened.
echo After enabling, press any key to continue...
pause >nul

echo Step 1: Testing setup...
echo.

REM Check if Python is installed
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python is not installed
    echo Please install Python 3.8+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Prerequisites found
echo.

echo Step 2: Setting up backend...
cd backend

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install dependencies
echo Installing backend dependencies...
pip install -r requirements.txt

REM Check if .env file exists
if not exist ".env" (
    echo ❌ .env file not found
    echo Please create .env file with configuration
    pause
    exit /b 1
)

echo ✅ Backend setup complete
echo.

echo Step 3: Setting up frontend...
cd ..\frontend

REM Clean Flutter cache first
echo Cleaning Flutter cache...
flutter clean

REM Remove pubspec.lock to force fresh resolution
if exist pubspec.lock (
    del pubspec.lock
    echo Removed pubspec.lock
)

REM Get Flutter dependencies
echo Installing frontend dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Trying to fix dependencies...
    call fix_dependencies.bat
)

echo ✅ Frontend setup complete
echo.

echo Step 4: Starting applications...
echo.
echo Starting backend server...
cd ..\backend
start "Blitzit Backend" cmd /k "venv\Scripts\activate.bat && uvicorn main:app --reload"

echo Waiting for backend to start...
timeout /t 5 /nobreak >nul

echo Starting frontend...
cd ..\frontend
start "Blitzit Frontend" cmd /k "flutter run -d windows"

echo.
echo 🎉 Blitzit is starting!
echo.
echo Backend: http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo Frontend: Desktop application window
echo.
echo Press any key to exit...
pause >nul
