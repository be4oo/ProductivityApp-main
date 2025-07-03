# 🚀 Blitzit App - Complete Setup & Testing Guide

## 📋 Prerequisites

Before running the application, ensure you have the following installed:

### Required Software
- **Python 3.8+** (for backend)
- **Flutter SDK 3.0+** (for frontend)
- **Git** (for version control)
- **VS Code** (recommended IDE)

### Installation Links
- Python: https://www.python.org/downloads/
- Flutter: https://flutter.dev/docs/get-started/install
- Git: https://git-scm.com/downloads
- VS Code: https://code.visualstudio.com/

### Verify Installations
```bash
# Check Python version
python --version

# Check Flutter version
flutter --version

# Check Git version
git --version
```

## 🔧 Configuration Setup

### 1. Backend Configuration

#### Create Environment File
Navigate to the backend directory and create a `.env` file:

```bash
cd backend
```

Create `.env` file with the following content:
```env
# Database Configuration
DATABASE_URL=sqlite:///./blitzit.db

# JWT Configuration
SECRET_KEY=your-super-secret-key-here-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# API Configuration
API_V1_STR=/api/v1
PROJECT_NAME=Blitzit API

# CORS Configuration
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:8080","http://localhost:4200"]

# Development Settings
DEBUG=True
```

**Important**: Change the `SECRET_KEY` to a secure random string for production use.

#### Generate Secret Key (Optional)
```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 2. Frontend Configuration

The Flutter app should work with default configuration, but you can customize the API endpoint in `lib/services/api_service.dart` if needed.

Default API endpoint: `http://localhost:8000`

## 🏃‍♂️ Running the Application

### Method 1: Using Startup Scripts (Recommended)

#### For Windows:
```bash
# Start Backend
cd backend
start.bat

# Start Frontend (in a new terminal)
cd frontend
start_flutter.bat
```

#### For macOS/Linux:
```bash
# Start Backend
cd backend
chmod +x start.sh
./start.sh

# Start Frontend (in a new terminal)
cd frontend
chmod +x start_flutter.sh
./start_flutter.sh
```

### Method 2: Manual Setup

#### Step 1: Setup Backend
```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

#### Step 2: Setup Frontend
```bash
# Navigate to frontend directory (in a new terminal)
cd frontend

# Get Flutter dependencies
flutter pub get

# Run the app
flutter run -d windows
```

## 🧪 Testing the Application

### 1. Backend Testing

#### Test API Endpoints
Once the backend is running, visit:
- **API Documentation**: http://localhost:8000/docs
- **Alternative Docs**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/

#### Test Authentication
```bash
# Register a new user
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpassword123",
    "full_name": "Test User"
  }'

# Login
curl -X POST "http://localhost:8000/auth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testuser&password=testpassword123"
```

### 2. Frontend Testing

#### Run Tests
```bash
cd frontend
flutter test
```

#### Debug Mode
```bash
flutter run -d windows --debug
```

#### Performance Testing
```bash
flutter run -d windows --profile
```

## 🔍 Troubleshooting

### Common Issues & Solutions

#### Backend Issues

**1. Port Already in Use**
```bash
# Kill process on port 8000
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -ti:8000 | xargs kill -9
```

**2. Database Connection Issues**
```bash
# Reset database
rm blitzit.db
python -c "from database import engine; from models import Base; Base.metadata.create_all(bind=engine)"
```

**3. Missing Dependencies**
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### Frontend Issues

**1. Flutter Doctor Issues**
```bash
flutter doctor
flutter doctor --android-licenses
```

**2. Dependency Issues**
```bash
flutter clean
flutter pub get
```

**3. Build Issues**
```bash
flutter clean
flutter pub get
flutter pub deps
```

### Port Configuration

If you need to change ports:

**Backend** (in `main.py`):
```python
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)  # Change port here
```

**Frontend** (in `lib/services/api_service.dart`):
```dart
static const String baseUrl = 'http://localhost:8001';  // Match backend port
```

## 📊 Testing Checklist

### ✅ Backend Tests
- [ ] Server starts without errors
- [ ] API documentation accessible at `/docs`
- [ ] User registration works
- [ ] User login returns JWT token
- [ ] Protected endpoints require authentication
- [ ] Database operations complete successfully

### ✅ Frontend Tests
- [ ] App launches without errors
- [ ] Login screen appears
- [ ] Registration process works
- [ ] Main dashboard loads
- [ ] Task creation works
- [ ] Project creation works
- [ ] Theme switching works
- [ ] Navigation between screens works

### ✅ Integration Tests
- [ ] Frontend can connect to backend
- [ ] API calls return expected data
- [ ] Real-time updates work
- [ ] Error handling displays properly
- [ ] Authentication flow complete

## 🎯 Development Workflow

### 1. Daily Development
```bash
# Terminal 1: Backend
cd backend
venv\Scripts\activate
uvicorn main:app --reload

# Terminal 2: Frontend
cd frontend
flutter run -d windows
```

### 2. Hot Reload
- **Backend**: Automatically reloads on code changes
- **Frontend**: Press `r` to hot reload, `R` to hot restart

### 3. Debugging
- **Backend**: Use VS Code Python debugger
- **Frontend**: Use Flutter DevTools

## 🚀 Production Deployment

### Backend Production
```bash
# Install production dependencies
pip install gunicorn

# Run with gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Frontend Production
```bash
# Build for production
flutter build windows --release
flutter build web --release
```

## 📝 Environment Variables Reference

### Backend (.env)
```env
DATABASE_URL=sqlite:///./blitzit.db
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
API_V1_STR=/api/v1
PROJECT_NAME=Blitzit API
BACKEND_CORS_ORIGINS=["http://localhost:3000"]
DEBUG=True
```

### Frontend (Optional)
Create `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String appName = 'Blitzit';
  static const String version = '1.0.0';
}
```

## 🎉 Success Indicators

When everything is working correctly, you should see:

### Backend
- Server starts on `http://localhost:8000`
- API docs available at `http://localhost:8000/docs`
- No error messages in terminal

### Frontend
- App window opens
- Login screen displays
- No error messages in terminal
- Hot reload working

### Integration
- Can create account and login
- Dashboard loads with data
- Can create projects and tasks
- All features functional

## 🆘 Getting Help

If you encounter issues:

1. **Check the terminal output** for error messages
2. **Verify all prerequisites** are installed
3. **Check port availability** (8000 for backend)
4. **Review configuration files** for typos
5. **Consult the troubleshooting section** above

## 📞 Support Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **GitHub Issues**: Create an issue in the repository
- **Stack Overflow**: Tag questions with `flutter` and `fastapi`

---

**Happy Development! 🚀**
