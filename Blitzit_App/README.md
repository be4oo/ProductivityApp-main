# Blitzit - Advanced Productivity Hub

A powerful, feature-rich desktop productivity application built with PyQt6 that combines task management, time tracking, and focus techniques to boost your productivity.

## 🚀 Features

### 📋 Multi-Project Task Management
- **Project Organization**: Create and manage multiple projects with custom color coding
- **Task CRUD Operations**: Full create, read, update, delete functionality for tasks
- **Task Prioritization**: Set task priorities (Low, Medium, High, Critical)
- **Due Dates & Reminders**: Set due dates with customizable reminder notifications
- **Task Types**: Categorize tasks by type for better organization
- **Notes & Details**: Add detailed notes and estimated time for each task

### 🎯 Kanban Board System
- **Drag & Drop Interface**: Intuitive task movement between columns
- **Four-Column Layout**: Backlog → This Week → Today → Done
- **Visual Task Cards**: Rich task cards showing priority, due dates, and progress
- **Real-time Updates**: Instant UI updates when tasks are moved or modified

### 📊 Eisenhower Matrix
- **Priority Quadrants**: Organize tasks by urgency and importance
- **Visual Categorization**: 
  - Urgent & Important (Do First)
  - Not Urgent & Important (Schedule)
  - Urgent & Not Important (Delegate)
  - Not Urgent & Not Important (Eliminate)
- **Drag & Drop Support**: Move tasks between quadrants easily

### 🎯 Focus Mode
- **Distraction-Free Environment**: Minimalist floating widget for focused work
- **Task Timer**: Built-in timer for time tracking during focus sessions
- **Sequential Task Flow**: Automatically move to next task upon completion
- **Mini Mode**: Compact interface that stays on top while working

### ⏱️ Time Tracking
- **Estimated vs Actual Time**: Track both planned and actual time spent
- **Time Format Support**: Flexible time input (e.g., "2h 30m", "90m", "1.5h")
- **Progress Monitoring**: Visual indicators of time spent vs estimated
- **Productivity Insights**: Analyze your time estimation accuracy

### 📈 Reporting & Analytics
- **Completion Statistics**: Track total completed vs pending tasks
- **7-Day Trends**: Visual representation of daily task completions
- **Project-wise Reports**: Analyze productivity across different projects
- **Performance Metrics**: Understand your productivity patterns

### 🎉 Celebration System
- **Achievement Rewards**: Animated celebrations when completing tasks
- **Motivational GIFs**: Fun visual feedback to maintain motivation
- **Success Animations**: Lottie-based animations for task completion

### 🔔 Smart Notifications
- **System Tray Integration**: Unobtrusive notifications via system tray
- **Due Date Alerts**: Automatic reminders for upcoming deadlines
- **Customizable Timing**: Set reminder offsets (minutes before due date)
- **Background Monitoring**: Continuous monitoring even when app is minimized

### 🎨 Theming & Customization
- **Dark/Light Themes**: Toggle between dark and light interface themes
- **Custom Stylesheets**: QSS-based styling for consistent UI
- **Project Colors**: Assign custom colors to projects for visual organization
- **Custom Fonts**: Beautiful Inter font family for enhanced readability

## 📸 Screenshots

*Screenshots and demo GIFs will be added here to showcase the application's interface and features.*

## 🛠️ Installation

### Prerequisites
- Python 3.8 or higher
- PyQt6
- SQLite3 (included with Python)

### Dependencies
```bash
pip install PyQt6 qtawesome
```

### Setup
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Blitzit_App
   ```

2. **Install dependencies**:
   ```bash
   pip install PyQt6 qtawesome
   ```

3. **Run the application**:
   ```bash
   python main.py
   ```

The application will automatically:
- Create the SQLite database (`data/tasks.db`)
- Set up the default "Inbox" project
- Load the dark theme by default

## 🚀 Quick Start Guide

### 1. Creating Your First Project
1. Launch Blitzit
2. Click the "+" button in the project selector
3. Enter a project name
4. The system will automatically assign a color

### 2. Adding Tasks
1. Select a project from the dropdown
2. Click "Add Task" button
3. Fill in task details:
   - Title (required)
   - Notes (optional)
   - Estimated time (e.g., "2h 30m")
   - Priority level
   - Due date and reminders
4. Click "Add" to create the task

### 3. Managing Tasks
- **Move Tasks**: Drag tasks between Kanban columns
- **Edit Tasks**: Double-click any task to edit details
- **Complete Tasks**: Drag to "Done" column or use the complete button
- **Delete Tasks**: Right-click and select delete

### 4. Using Focus Mode
1. Click "Enter Focus Mode" on any task
2. Use the floating widget to:
   - Start/stop timer
   - Mark task complete
   - Skip to next task
   - Return to main window

### 5. Eisenhower Matrix
1. Switch to "Matrix" view
2. Drag tasks to appropriate quadrants
3. Use this view for strategic task prioritization

## 🏗️ Technical Architecture

### Core Components

#### Database Layer (`database.py`)
- **SQLite Integration**: Robust data persistence with migration support
- **Project Management**: CRUD operations for projects with color support
- **Task Management**: Comprehensive task operations with relationships
- **Reporting Queries**: Optimized queries for analytics and reporting

#### Main Application (`main.py`)
- **QMainWindow**: Primary application window with menu system
- **Theme Management**: Dynamic theme switching with config persistence
- **View Management**: Multiple view modes (Kanban, Matrix, Today List)
- **Event Handling**: Comprehensive event system for user interactions

#### Widget Architecture (`widgets/`)
- **Modular Design**: Separate widgets for different functionalities
- **Signal/Slot System**: PyQt6 signal system for component communication
- **Drag & Drop**: Custom drag and drop implementation for task movement
- **Custom Dialogs**: Specialized dialogs for task editing and settings

#### Notification System (`notifications.py`)
- **System Tray**: Cross-platform system tray integration
- **Background Monitoring**: Continuous task monitoring for due dates
- **User Preferences**: Configurable notification settings

### Data Models

#### Projects
- ID, Name, Color
- One-to-many relationship with tasks

#### Tasks
- Comprehensive task model with:
  - Basic info (title, notes, project_id)
  - Scheduling (due_date, column, priority)
  - Time tracking (estimated_time, actual_time)
  - Metadata (created_at, completed_at)
  - Reminders (reminder_enabled, reminder_offset)

## ⚙️ Configuration

### Theme Configuration (`config.json`)
```json
{
    "theme": "dark"  // or "light"
}
```

### Database Configuration
- **Location**: `data/tasks.db`
- **Auto-migration**: Automatic schema updates on startup
- **Backup**: Manual backup recommended for important data

### Asset Configuration
- **Icons**: `assets/icons/` - Theme-aware icons
- **Fonts**: `assets/fonts/` - Inter font family
- **Celebrations**: `assets/gifs/` - Celebration animations
- **Themes**: `ui/` - QSS stylesheet files

## 🔧 Development

### Project Structure
```
Blitzit_App/
├── main.py                 # Main application entry point
├── database.py            # Database operations and models
├── notifications.py       # System notification handling
├── config.json           # Application configuration
├── assets/               # Static assets
│   ├── fonts/           # Custom font files
│   ├── icons/           # UI icons (theme-aware)
│   ├── gifs/            # Celebration animations
│   └── icon.png         # Application icon
├── data/                # Application data
│   └── tasks.db         # SQLite database
├── ui/                  # User interface stylesheets
│   ├── dark_theme.qss   # Dark theme styles
│   └── light_theme.qss  # Light theme styles
└── widgets/             # UI component modules
    ├── task_widgets.py      # Task-related UI components
    ├── focus_widget.py      # Focus mode interface
    ├── eisenhower_widget.py # Eisenhower Matrix view
    ├── celebration_widget.py # Task completion celebrations
    ├── floating_widget.py   # Floating focus mode widget
    ├── timer_widget.py      # Time tracking components
    ├── reporting_dialog.py  # Analytics and reporting
    ├── settings_dialog.py   # Application settings
    └── ...                  # Additional specialized widgets
```

### Key Design Patterns
- **Model-View Architecture**: Clear separation between data and presentation
- **Signal-Slot Pattern**: Loose coupling between UI components
- **Factory Pattern**: Dynamic widget creation based on data
- **Observer Pattern**: Real-time UI updates on data changes

### Adding New Features
1. **Database Changes**: Update `database.py` with new schema/operations
2. **UI Components**: Create new widgets in `widgets/` directory
3. **Main Integration**: Connect new features in `main.py`
4. **Styling**: Add appropriate styles to theme files

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow the existing code style
4. **Test thoroughly**: Ensure all features work as expected
5. **Commit changes**: `git commit -m 'Add amazing feature'`
6. **Push to branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Code Style Guidelines
- Follow PEP 8 for Python code
- Use meaningful variable and function names
- Add docstrings for new functions and classes
- Maintain the existing architecture patterns

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **PyQt6**: For the excellent GUI framework
- **QtAwesome**: For beautiful icon integration
- **Inter Font**: For the clean, readable typography
- **SQLite**: For reliable data persistence

## 📞 Support

If you encounter any issues or have questions:
1. Check the existing issues in the repository
2. Create a new issue with detailed description
3. Include steps to reproduce any bugs
4. Provide system information (OS, Python version, etc.)

---

**Built with ❤️ for productivity enthusiasts**
