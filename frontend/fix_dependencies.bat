@echo off
REM Flutter Dependency Resolution Script
echo 🔧 Fixing Flutter Dependencies...
echo ==================================

REM Clean previous builds
echo Step 1: Cleaning Flutter cache...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Flutter clean failed
    pause
    exit /b 1
)

REM Remove pubspec.lock to force fresh resolution
echo Step 2: Removing pubspec.lock...
if exist pubspec.lock (
    del pubspec.lock
    echo ✅ Removed pubspec.lock
) else (
    echo ✅ pubspec.lock not found
)

REM Get dependencies
echo Step 3: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Flutter pub get failed
    echo.
    echo Trying alternative resolution...
    echo.
    
    REM Try with --no-precompile
    echo Trying with --no-precompile...
    flutter pub get --no-precompile
    if %errorlevel% neq 0 (
        echo ❌ Still failed. Trying dependency override...
        
        REM Try with dependency override
        echo Adding dependency override...
        echo. >> pubspec.yaml
        echo dependency_overrides: >> pubspec.yaml
        echo   material_color_utilities: ^0.11.1 >> pubspec.yaml
        
        flutter pub get
        if %errorlevel% neq 0 (
            echo ❌ All attempts failed
            echo.
            echo Please check:
            echo 1. Flutter SDK version: flutter --version
            echo 2. Dart SDK version: dart --version
            echo 3. Update Flutter: flutter upgrade
            pause
            exit /b 1
        )
    )
)

echo ✅ Dependencies resolved successfully!
echo.

REM Verify Flutter doctor
echo Step 4: Checking Flutter configuration...
flutter doctor --android-licenses >nul 2>&1
flutter doctor

echo.
echo 🎉 Flutter dependencies fixed!
echo Ready to run: flutter run -d windows
pause
