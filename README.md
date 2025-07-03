# Blitzit - Modern Productivity Hub

A complete modernization of the Blitzit productivity application, featuring a Flutter frontend with Material 3 design and a FastAPI backend with JWT authentication.

## 🚀 Quick Start (Windows)

### Method 1: Automatic Setup (Recommended)
```powershell
# Navigate to project directory
cd "d:\AI Project\ProductivityApp-main"

# Run complete setup script
complete_setup.bat
```

This script will:
- Install Visual Studio Build Tools (required for Windows builds)
- Enable Windows Developer Mode
- Install Flutter dependencies
- Test the setup
- Start the application

### Method 2: Manual Steps
1. **Install Visual Studio**: Run `install_visual_studio.bat` or install manually from [Visual Studio Downloads](https://visualstudio.microsoft.com/downloads/)
2. **Enable Developer Mode**: Settings → Update & Security → For developers → Developer mode
3. **Install Dependencies**: Run `fix_dependencies.bat`
4. **Start App**: Run `run_windows.bat` (desktop) or `run_web.bat` (browser)

### Method 3: Web Version (No Setup Required)
```powershell
cd "d:\AI Project\ProductivityApp-main"
run_web.bat
```

## 🚀 Project Overview

This project represents a complete architectural transformation from PyQt6 to a modern tech stack:

- **Frontend**: Flutter with Material 3 design system
- **Backend**: FastAPI with SQLAlchemy ORM
- **Database**: SQLite (easily upgradeable to PostgreSQL)
- **Authentication**: JWT-based secure authentication
- **UI/UX**: Modern Material Design with animations and responsive layouts

## 📋 Features

### ✨ Modern UI/UX
- Material 3 design system with dynamic colors
- Smooth animations and micro-interactions
- Responsive design for different screen sizes
- Dark/Light theme support with system preference detection
- Glassmorphism effects and modern visual hierarchy

### 🔐 Secure Authentication
- JWT-based authentication system
- User registration and login
- Secure password hashing with bcrypt
- Token refresh capabilities

### 📊 Task Management
- Kanban-style board view (Backlog → This Week → Today → Done)
- Eisenhower Matrix for priority management
- Project-based task organization
- Due dates and reminders
- Time tracking (estimated vs actual)
- Task completion celebrations

### 📈 Analytics & Reporting
- Productivity dashboard with statistics
- Completion rate tracking
- Overdue task monitoring
- Trend analysis

### 🎯 Focus Features
- Pomodoro timer integration
- Focus mode for distraction-free work
- Task prioritization and scheduling

## ✨ Additional Features Implemented

### 🎨 Enhanced UI Components
- **Task Dialog**: Full-featured task creation/editing with priority, status, due dates, and tags
- **Project Dialog**: Project creation with color selection and description
- **Task Item Widget**: Interactive task cards with hover effects, priority indicators, and quick actions
- **Focus Mode**: Pomodoro timer with animations, break management, and progress tracking
- **Analytics Screen**: Comprehensive analytics with charts, completion rates, and activity tracking
- **Settings Screen**: Theme preferences, notification settings, and account management

### 🔧 Advanced Functionality
- **Smart Navigation**: GoRouter-based routing with focus mode deep linking
- **Context Menus**: Right-click task actions including edit, focus mode, and delete
- **Drag & Drop**: Task status updates via intuitive drag-and-drop interface
- **Real-time Updates**: Live task updates across all views
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Accessibility**: Screen reader support and keyboard navigation

### 🎯 Productivity Features
- **Pomodoro Integration**: Built-in focus timer with customizable intervals
- **Priority Management**: Visual priority indicators and filtering
- **Due Date Tracking**: Overdue task highlighting and smart date display
- **Tag System**: Flexible task categorization with visual tags
- **Quick Actions**: Fast task completion and status changes
- **Bulk Operations**: Multi-select task management (planned)

### 📊 Analytics & Insights
- **Productivity Charts**: Visual progress tracking with fl_chart integration
- **Completion Statistics**: Success rates and task completion metrics
- **Time Tracking**: Estimated vs actual time analysis
- **Priority Distribution**: Task priority breakdown with pie charts
- **Activity Timeline**: Recent task activity and updates
- **Custom Reports**: Exportable productivity reports (planned)

### 🔧 Technical Enhancements
- **Provider State Management**: Efficient state management across the app
- **Dynamic Theming**: Material 3 with system color integration
- **Animation Framework**: Smooth transitions and micro-interactions
- **Error Handling**: Comprehensive error management and user feedback
- **Offline Support**: Local data persistence with Hive
- **Performance Optimization**: Lazy loading and efficient rendering

## 🏗️ Architecture

### Backend Structure
```
backend/
├── main.py              # FastAPI application entry point
├── config.py            # Application configuration
├── database.py          # Database connection and session management
├── models.py            # SQLAlchemy database models
├── schemas.py           # Pydantic data models
├── crud.py              # Database operations
├── auth.py              # Authentication utilities
├── requirements.txt     # Python dependencies
└── routers/            # API route modules
    ├── auth.py         # Authentication endpoints
    ├── projects.py     # Project management endpoints
    ├── tasks.py        # Task management endpoints
    ├── subtasks.py     # Subtask endpoints
    └── dashboard.py    # Analytics endpoints
```

### Frontend Structure
```
frontend/
├── lib/
│   ├── main.dart           # Application entry point
│   ├── models/             # Data models
│   ├── services/           # API service layer
│   ├── providers/          # State management
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable UI components
│   └── utils/              # Utilities and themes
├── pubspec.yaml            # Flutter dependencies
└── assets/                 # Static assets
```

## 🛠️ Installation & Setup

### Prerequisites
- Python 3.8+ (for backend)
- Flutter SDK 3.0+ (for frontend)
- Git
- VS Code or preferred IDE

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create and activate virtual environment:**
   ```bash
   # Windows
   python -m venv venv
   venv\Scripts\activate

   # macOS/Linux
   python -m venv venv
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   ```bash
   # Copy .env file and modify as needed
   cp .env.example .env
   ```

5. **Start the backend server:**
   ```bash
   # Windows
   start.bat

   # macOS/Linux
   chmod +x start.sh
   ./start.sh

   # Or manually:
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run -d windows  # For Windows desktop
   flutter run -d macos    # For macOS desktop
   flutter run -d linux    # For Linux desktop
   ```

### Data Migration (Optional)

If you have existing data from the PyQt6 version:

```bash
cd scripts
python migrate_data.py
```

## 🎨 UI/UX Improvements

### Design System
- **Material 3**: Latest Material Design specifications
- **Dynamic Colors**: Adapts to system colors on supported platforms
- **Typography**: Inter font family for modern readability
- **Spacing**: Consistent 8px grid system
- **Border Radius**: 12-16px for modern rounded corners

### Animations
- **Page Transitions**: Smooth route transitions
- **Micro-interactions**: Button press feedback
- **Task Completion**: Celebration animations
- **Loading States**: Skeleton loaders and progress indicators

### Responsive Design
- **Adaptive Layouts**: Optimized for different screen sizes
- **Breakpoints**: Mobile, tablet, and desktop layouts
- **Touch Support**: Optimized for touch input

## 🔧 Development

### Backend API Endpoints

#### Authentication
- `POST /auth/register` - User registration
- `POST /auth/token` - User login
- `GET /auth/me` - Get current user

#### Projects
- `GET /projects/` - List projects
- `POST /projects/` - Create project
- `PUT /projects/{id}` - Update project
- `DELETE /projects/{id}` - Delete project

#### Tasks
- `GET /tasks/` - List tasks
- `POST /tasks/` - Create task
- `PUT /tasks/{id}` - Update task
- `DELETE /tasks/{id}` - Delete task
- `PUT /tasks/{id}/move` - Move task between columns
- `PUT /tasks/{id}/matrix` - Update Eisenhower Matrix position

#### Dashboard
- `GET /dashboard/stats` - Get productivity statistics

### State Management
The Flutter app uses Provider for state management with separate providers for:
- `AuthProvider` - User authentication state
- `ProjectProvider` - Project management
- `TaskProvider` - Task operations
- `ThemeProvider` - Theme and appearance settings

### Testing
```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
flutter test
```

## 🚀 Deployment

### Backend Deployment
1. **Docker** (recommended):
   ```dockerfile
   FROM python:3.9-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   COPY . .
   CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```

2. **Direct deployment** to platforms like Heroku, DigitalOcean, or AWS

### Frontend Deployment
1. **Desktop**: Build for Windows, macOS, or Linux
   ```bash
   flutter build windows --release
   flutter build macos --release
   flutter build linux --release
   ```

2. **Web**: Deploy as web application
   ```bash
   flutter build web --release
   ```

## 🎯 Future Enhancements

### Phase 1 Completed ✅
- FastAPI backend with authentication
- Flutter frontend with Material 3
- Basic CRUD operations
- Modern UI/UX design

### Phase 2 (Upcoming)
- [ ] Real-time synchronization with WebSocket
- [ ] Cloud storage integration
- [ ] Mobile app versions (iOS/Android)
- [ ] Advanced analytics and reporting
- [ ] Team collaboration features
- [ ] Plugin system for extensions

### Phase 3 (Future)
- [ ] AI-powered task suggestions
- [ ] Voice commands and speech-to-text
- [ ] Integration with external services (Google Calendar, Slack, etc.)
- [ ] Advanced data visualization
- [ ] Custom workflows and automation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Material Design team for the design system
- Flutter team for the amazing framework
- FastAPI team for the high-performance API framework
- The open-source community for countless libraries and tools

## 🔥 Quick Start - How to Run the App

### ⚠️ **Windows Users: Enable Developer Mode First**
**REQUIRED**: Before running the app, enable Windows Developer Mode:
1. Press `Windows + I` to open Settings
2. Go to "Privacy & Security" → "For developers" (Windows 11) or "Update & Security" → "For developers" (Windows 10)
3. Toggle "Developer Mode" to **ON**
4. Click "Yes" when prompted and wait for setup to complete

Or run this command to open the settings directly:
```bash
start ms-settings:developers
```

### 🚀 One-Click Setup (Windows)
```bash
# Run the Windows setup script (handles Developer Mode)
run_windows.bat

# Or use the general quick start
quick_start.bat
```

### 📝 Manual Setup

#### Step 1: Prerequisites
- Install **Python 3.8+**: https://www.python.org/downloads/
- Install **Flutter SDK**: https://flutter.dev/docs/get-started/install
- Install **Git**: https://git-scm.com/downloads/

#### Step 2: Backend Setup
```bash
# Navigate to backend directory
cd backend

# Create and activate virtual environment
python -m venv venv
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the backend server
uvicorn main:app --reload
```

#### Step 3: Frontend Setup (New Terminal)
```bash
# Navigate to frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Run the Flutter app
flutter run -d windows
```

### 🧪 Test Your Setup
```bash
# Test backend
cd backend
python test_setup.py

# Test frontend
cd frontend
test_setup.bat
```

### 🌐 Access Points
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Frontend App**: Desktop application window

### 🔧 Configuration

#### Backend Configuration (.env file)
The backend requires a `.env` file in the `backend/` directory:

```env
DATABASE_URL=sqlite:///./blitzit.db
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
API_V1_STR=/api/v1
PROJECT_NAME=Blitzit API
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:8080","http://localhost:4200","http://localhost:8000"]
DEBUG=True
```

#### Frontend Configuration
No additional configuration needed. The app will connect to `http://localhost:8000` by default.

### 🆘 Troubleshooting

**Backend won't start?**
- Check if Python 3.8+ is installed: `python --version`
- Verify virtual environment is activated
- Check if port 8000 is available: `netstat -ano | findstr :8000`

**Frontend won't start?**
- Check if Flutter is installed: `flutter --version`
- Run `flutter doctor` to check Flutter setup
- Ensure backend is running first

**Can't connect to backend?**
- Verify backend is running on http://localhost:8000
- Check Windows Firewall settings
- Ensure CORS is configured correctly

### 📋 First-Time Usage
1. **Start both backend and frontend**
2. **Register a new account** in the app
3. **Create your first project**
4. **Add some tasks** to get started
5. **Explore the features**: Focus mode, analytics, settings

---

## 🔥 Quick Start Commands

```bash
# Start backend
cd backend && python -m venv venv && venv\Scripts\activate && pip install -r requirements.txt && uvicorn main:app --reload

# Start frontend
cd frontend && flutter pub get && flutter run -d windows

# Access the application
# Backend API: http://localhost:8000
# API Documentation: http://localhost:8000/docs
# Frontend: Runs on desktop
```

**Happy productivity! 🚀**
