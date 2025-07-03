#!/usr/bin/env bash
# Flutter Setup Test Script

echo "🧪 Blitzit Frontend Setup Test"
echo "==============================="

# Test Flutter installation
echo "🔍 Testing Flutter installation..."
if command -v flutter &> /dev/null; then
    echo "✅ Flutter is installed"
    flutter --version
else
    echo "❌ Flutter is not installed"
    echo "Install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Test Flutter doctor
echo ""
echo "🩺 Running Flutter Doctor..."
flutter doctor

# Test dependencies
echo ""
echo "📦 Testing Flutter dependencies..."
if flutter pub get; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Test if backend is running
echo ""
echo "🌐 Testing backend connection..."
if curl -s "http://localhost:8000/" > /dev/null; then
    echo "✅ Backend is running"
else
    echo "❌ Backend is not running"
    echo "Start the backend first: cd ../backend && uvicorn main:app --reload"
fi

# Test build
echo ""
echo "🔨 Testing Flutter build..."
if flutter build windows --debug; then
    echo "✅ Flutter build successful"
else
    echo "❌ Flutter build failed"
    exit 1
fi

echo ""
echo "🎉 Frontend setup test completed!"
echo "Run the app with: flutter run -d windows"
