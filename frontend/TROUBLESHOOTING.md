# Flutter Dependency Troubleshooting Guide

## 🔧 Common Flutter Issues & Solutions

### Issue 1: Material Color Utilities Version Conflict

**Error Message:**
```
Because every version of flutter_test from sdk depends on material_color_utilities 0.11.1 and
blitzit_flutter depends on material_color_utilities ^0.8.0, flutter_test from sdk is forbidden.
```

**Solution:**
1. **Run the fix script:**
   ```bash
   fix_dependencies.bat
   ```

2. **Or manually fix:**
   ```bash
   flutter clean
   del pubspec.lock
   flutter pub get
   ```

### Issue 2: Go Router Version Conflict

**Error Message:**
```
The current Dart SDK version is X.X.X
Because blitzit_flutter depends on go_router ^12.1.3 which requires SDK version >=3.0.0 <4.0.0
```

**Solution:**
Update Flutter SDK:
```bash
flutter upgrade
flutter --version
```

### Issue 3: General Dependency Resolution

**Steps to resolve:**
1. **Clean everything:**
   ```bash
   flutter clean
   flutter pub cache clean
   ```

2. **Remove lock file:**
   ```bash
   del pubspec.lock
   ```

3. **Get dependencies:**
   ```bash
   flutter pub get
   ```

4. **If still failing, try:**
   ```bash
   flutter pub get --no-precompile
   ```

### Issue 4: Flutter Doctor Issues

**Common problems:**
- Android toolchain not installed
- Visual Studio not found
- Chrome not found

**Solutions:**
```bash
flutter doctor --android-licenses
flutter doctor
```

### Issue 5: Windows Desktop Support

**Error Message:**
```
No supported devices found
```

**Solution:**
1. **Enable Windows desktop:**
   ```bash
   flutter config --enable-windows-desktop
   ```

2. **Check available devices:**
   ```bash
   flutter devices
   ```

### Issue 6: Build Issues

**Error Message:**
```
Failed to build for Windows
```

**Solution:**
1. **Install Visual Studio Build Tools**
2. **Run:**
   ```bash
   flutter doctor
   flutter build windows --debug
   ```

## 🚀 Quick Fix Commands

### Reset Everything
```bash
flutter clean
flutter pub cache clean
del pubspec.lock
flutter pub get
```

### Update Flutter
```bash
flutter upgrade
flutter doctor
```

### Enable Desktop Support
```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

### Check Dependencies
```bash
flutter pub deps
flutter pub outdated
```

## 📋 Troubleshooting Checklist

### ✅ Basic Setup
- [ ] Flutter SDK installed (3.10.0+)
- [ ] Dart SDK compatible
- [ ] PATH environment variable set
- [ ] Visual Studio Build Tools installed (Windows)

### ✅ Project Setup
- [ ] `flutter clean` executed
- [ ] `pubspec.lock` removed
- [ ] `flutter pub get` successful
- [ ] No dependency conflicts

### ✅ Desktop Support
- [ ] Windows desktop enabled
- [ ] Visual Studio Build Tools installed
- [ ] Windows SDK installed
- [ ] `flutter devices` shows Windows

### ✅ Build Test
- [ ] `flutter build windows --debug` successful
- [ ] No compilation errors
- [ ] All dependencies resolved

## 🆘 If All Else Fails

1. **Reinstall Flutter:**
   ```bash
   # Download fresh Flutter SDK
   # Extract to C:\flutter
   # Update PATH variable
   flutter doctor
   ```

2. **Use Flutter Beta/Master:**
   ```bash
   flutter channel beta
   flutter upgrade
   ```

3. **Check Flutter Issues:**
   - GitHub: https://github.com/flutter/flutter/issues
   - Stack Overflow: Tag `flutter`

4. **Contact Support:**
   - Create issue in project repository
   - Include flutter doctor output
   - Include error messages

## 📊 Version Compatibility Matrix

| Flutter Version | Dart Version | Material Color Utils | Go Router |
|----------------|--------------|---------------------|-----------|
| 3.10.0+        | 3.0.0+       | 0.11.1             | 13.2.0+   |
| 3.7.0+         | 2.19.0+      | 0.8.0              | 12.1.3    |
| 3.3.0+         | 2.18.0+      | 0.5.0              | 10.0.0    |

## 🎯 Recommended Setup

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  material_color_utilities: ^0.11.1
  go_router: ^13.2.0
  provider: ^6.1.2
  
dependency_overrides:
  material_color_utilities: ^0.11.1
  web: ^0.5.1
```

This configuration ensures maximum compatibility with the latest Flutter SDK.
