#!/bin/bash

# Frontend startup script for Blitzit Flutter App
echo "Starting Blitzit Flutter Desktop Application..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Navigate to frontend directory
cd "$(dirname "$0")"

# Clean build
echo "Cleaning previous build..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Run the app
echo "Starting Flutter app..."
flutter run -d windows
