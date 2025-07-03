# Visual Studio Build Tools Setup Guide

## ⚠️ Required: Visual Studio Build Tools for Windows

Flutter Windows desktop apps require Visual Studio with C++ build tools to compile native Windows code.

## 🔧 Solution Options

### Option 1: Install Visual Studio Community (Recommended)

#### Download and Install:
1. **Download Visual Studio Community 2022 (FREE):**
   - Go to: https://visualstudio.microsoft.com/downloads/
   - Click "Download Visual Studio Community 2022"

2. **During Installation, Select Workloads:**
   - ✅ **"Desktop development with C++"** (REQUIRED)
   - ✅ **"Game development with C++"** (Optional but helpful)

3. **Individual Components (Auto-selected with workload):**
   - ✅ MSVC v143 - VS 2022 C++ x64/x86 build tools
   - ✅ Windows 10/11 SDK (latest version)
   - ✅ CMake tools for Visual Studio

#### Quick Install Command:
```powershell
# Download and run Visual Studio installer
winget install Microsoft.VisualStudio.2022.Community
```

### Option 2: Visual Studio Build Tools Only (Minimal)

If you only want the build tools without the full IDE:

1. **Download Build Tools:**
   - Go to: https://visualstudio.microsoft.com/downloads/
   - Scroll to "Tools for Visual Studio 2022"
   - Download "Build Tools for Visual Studio 2022"

2. **Select Components:**
   - ✅ **C++ build tools**
   - ✅ **Windows 10/11 SDK**
   - ✅ **CMake tools**

#### Quick Install Command:
```powershell
winget install Microsoft.VisualStudio.2022.BuildTools
```

### Option 3: Use Web Version (Temporary Solution)

While installing Visual Studio, you can run the web version:

```bash
flutter run -d chrome
```

## 🚀 After Installing Visual Studio

1. **Restart your computer** (important!)
2. **Verify installation:**
   ```bash
   flutter doctor
   ```
3. **Should show:** ✅ Visual Studio - develop Windows apps
4. **Run the app:**
   ```bash
   flutter run -d windows
   ```

## 🔍 Verify Installation

Run this command to check if Visual Studio is properly detected:
```bash
flutter doctor -v
```

You should see something like:
```
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.x.x)
    • Visual Studio at C:\Program Files\Microsoft Visual Studio\2022\Community
    • MSVC version 19.x.x
    • Windows 10/11 SDK version 10.0.x
```

## 🆘 Troubleshooting

### Visual Studio Installed but Not Detected?

1. **Restart terminal/VS Code** after installation
2. **Run as Administrator:**
   ```bash
   flutter doctor
   ```
3. **Check PATH environment variable**
4. **Reinstall Flutter if needed**

### Still Getting Errors?

1. **Verify C++ workload is installed:**
   - Open Visual Studio Installer
   - Click "Modify" on your installation
   - Ensure "Desktop development with C++" is checked

2. **Check Windows SDK:**
   - Should have Windows 10 or 11 SDK
   - Version 10.0.17763.0 or newer

3. **Update Visual Studio:**
   - Open Visual Studio
   - Help → Check for Updates

## 📋 Minimum Requirements

- **Visual Studio 2019 16.11 or later** (or Visual Studio 2022)
- **Windows 10 SDK** version 10.0.17763.0 or later
- **MSVC v142 or v143** C++ build tools
- **CMake** (included with C++ workload)

## 🎯 Quick Installation Steps

1. **Download Visual Studio Community 2022**
2. **Select "Desktop development with C++" workload**
3. **Install and restart computer**
4. **Run:** `flutter doctor`
5. **Run:** `flutter run -d windows`

## 💡 Alternative: Use Web Version

While setting up Visual Studio, you can test the app in a web browser:

```bash
# Run in Chrome
flutter run -d chrome

# Or run in Edge
flutter run -d edge
```

The web version will have the same UI and most functionality!

## 🔗 Direct Download Links

- **Visual Studio Community 2022:** https://aka.ms/vs/17/release/vs_community.exe
- **Build Tools Only:** https://aka.ms/vs/17/release/vs_buildtools.exe
- **Flutter Documentation:** https://docs.flutter.dev/desktop#windows

---

## ⏱️ Installation Time

- **Visual Studio Community:** ~3-5 GB download, 20-30 minutes install
- **Build Tools Only:** ~1-2 GB download, 10-15 minutes install

**After installation, Blitzit will run perfectly on Windows! 🚀**
