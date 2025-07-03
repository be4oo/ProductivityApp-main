# Windows Developer Mode Setup Guide

## ⚠️ Required: Enable Windows Developer Mode

Flutter on Windows requires Developer Mode to be enabled for building apps with plugins (which our app uses).

### 🔧 How to Enable Developer Mode

#### Method 1: Using Windows Settings (Recommended)
1. **Open Windows Settings:**
   - Press `Windows + I`
   - Or click Start → Settings

2. **Navigate to Developer Settings:**
   - Click on "Privacy & Security" (Windows 11)
   - Or click on "Update & Security" → "For developers" (Windows 10)

3. **Enable Developer Mode:**
   - Toggle "Developer Mode" to **ON**
   - Click "Yes" when prompted
   - Windows may download required packages

4. **Restart if required:**
   - Some systems may require a restart

#### Method 2: Using Command Line (Quick)
Run this command in an **Administrator** PowerShell:
```powershell
start ms-settings:developers
```

#### Method 3: Using Registry (Advanced)
```powershell
# Run as Administrator
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

### 🎯 Alternative Solution: Build Without Symlinks

If you can't enable Developer Mode, you can build without plugins:

1. **Remove problematic plugins temporarily:**
   ```yaml
   # Comment out in pubspec.yaml:
   # window_manager: ^0.3.8
   # hive_flutter: ^1.1.0
   # path_provider: ^2.1.1
   ```

2. **Run without plugins:**
   ```bash
   flutter run -d windows --no-enable-software-rendering
   ```

### 🔍 Verify Developer Mode

**Check if Developer Mode is enabled:**
1. Open PowerShell
2. Run: `Get-WindowsDeveloperLicense`
3. Should show license information if enabled

**Or check in Settings:**
- Windows 11: Settings → Privacy & Security → For developers
- Windows 10: Settings → Update & Security → For developers
- Should show "Developer Mode is on"

### 🚀 After Enabling Developer Mode

Once Developer Mode is enabled:

1. **Restart your terminal/VS Code**
2. **Navigate to project directory:**
   ```bash
   cd "d:\AI Project\ProductivityApp-main\frontend"
   ```
3. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d windows
   ```

### 📱 What Developer Mode Enables

Developer Mode allows:
- **Symlink creation** (required for Flutter plugins)
- **Sideloading apps** from outside the Microsoft Store
- **Advanced debugging features**
- **Package installation from any source**

### 🛡️ Security Considerations

Developer Mode is safe when used for development:
- ✅ **Safe for development machines**
- ✅ **Required for Flutter desktop development**
- ✅ **Can be disabled when not developing**
- ⚠️ **Only enable on trusted development machines**

### 🆘 Troubleshooting

**Still getting symlink errors?**
1. Restart Windows after enabling Developer Mode
2. Run PowerShell as Administrator
3. Check Windows version (requires Windows 10/11)

**Can't find Developer Mode setting?**
- Windows 10: Update & Security → For developers
- Windows 11: Privacy & Security → For developers
- Or run: `start ms-settings:developers`

**Permission denied errors?**
- Run terminal as Administrator
- Check User Account Control (UAC) settings
- Ensure you have administrative privileges

### 🎉 Success Indicators

When Developer Mode is properly enabled:
- ✅ `flutter run -d windows` works without symlink errors
- ✅ App builds and launches successfully
- ✅ All Flutter plugins function correctly
- ✅ Hot reload works properly

---

## 🔄 Quick Fix Commands

```bash
# 1. Enable Developer Mode (run this first)
start ms-settings:developers

# 2. After enabling, restart terminal and run:
cd "d:\AI Project\ProductivityApp-main\frontend"
flutter clean
flutter pub get
flutter run -d windows
```

**Once Developer Mode is enabled, the Blitzit app will run perfectly! 🚀**
