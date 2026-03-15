# 🚀 How to Run Erode Super App on Localhost

## ⚠️ Prerequisites Check

Before running the app, make sure you have Flutter installed.

### Step 1: Install Flutter (if not installed)

1. **Download Flutter SDK:**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Download the latest Flutter SDK

2. **Extract Flutter:**
   - Extract to: `C:\src\flutter` (recommended location)
   - Or any location without spaces in path

3. **Add Flutter to PATH:**
   - Open System Properties → Environment Variables
   - Under "User variables", select "Path" → Edit → New
   - Add: `C:\src\flutter\bin` (or your Flutter path)
   - Click OK to save

4. **Verify Installation:**
   ```bash
   flutter doctor
   ```

### Step 2: Install Chrome (if not installed)

Download Chrome: https://www.google.com/chrome/

---

## 🏃 Running the App

### Option 1: Using VS Code (Recommended)

1. **Open Project in VS Code:**
   ```
   File → Open Folder → Select "C:\Projects\all in one"
   ```

2. **Install VS Code Extensions:**
   - Dart (by Dart Code)
   - Flutter (by Dart Code)

3. **Run the App:**
   - Press `F5` to start debugging
   - OR press `Ctrl+F5` to run without debugging
   - Select "Chrome" as the device

4. **App will open in Chrome at:**
   ```
   http://localhost:8080
   ```

### Option 2: Using Command Line

1. **Open Terminal/PowerShell:**
   ```bash
   cd "C:\Projects\all in one"
   ```

2. **Run Flutter Web:**
   ```bash
   flutter run -d chrome
   ```

   **With custom port:**
   ```bash
   flutter run -d chrome --web-port=8080
   ```

   **Without auto-launching Chrome:**
   ```bash
   flutter run -d chrome --web-port=8080 --no-launch-browser
   ```
   Then manually open: http://localhost:8080

3. **Hot Reload:**
   - Press `r` in terminal for hot reload
   - Press `R` for hot restart
   - Press `q` to quit

### Option 3: Using Flutter Desktop (Alternative)

If you want to test as a desktop app:

```bash
flutter run -d windows
```

This will run as a Windows desktop app instead of web.

---

## 🌐 Accessing Your App

Once running, access your app at:

| URL | Description |
|-----|-------------|
| http://localhost:8080 | Primary URL |
| http://127.0.0.1:8080 | Alternative URL |
| http://[::]:8080 | IPv6 URL |

---

## 🔍 Troubleshooting

### Error: "flutter: command not found"

**Solution:** Add Flutter to PATH

1. Find Flutter installation (e.g., `C:\src\flutter\bin`)
2. Add to System PATH
3. Restart VS Code/Terminal
4. Run: `flutter doctor`

### Error: "No devices found"

**Solution:** Install Chrome or specify web

```bash
flutter devices
flutter run -d chrome
```

### Error: "Port 8080 already in use"

**Solution:** Use different port

```bash
flutter run -d chrome --web-port=8081
```

### Error: "Failed to establish connection with the application"

**Solution:** 
1. Stop the app (Ctrl+C in terminal)
2. Run: `flutter clean`
3. Run: `flutter pub get`
4. Run again: `flutter run -d chrome`

### Error: "Build failed" or "Compilation errors"

**Solution:** Check for code errors

1. Run: `flutter analyze`
2. Fix any errors shown
3. Run again

### Chrome doesn't open automatically

**Solution:** Open manually

1. Note the URL in terminal (usually http://localhost:8080)
2. Open Chrome
3. Navigate to the URL

---

## 📱 Testing Checklist

### Quick Test (5 minutes)

1. **Open http://localhost:8080**
   - [ ] Splash screen appears with purple gradient
   - [ ] "Erode Super App" text visible
   - [ ] Animation plays smoothly

2. **Dashboard (after 3.2 seconds)**
   - [ ] "வணக்கம்! 👋" greeting visible
   - [ ] 4 commerce cards visible (🍔🍅📱🚕)
   - [ ] Market ticker shows 3 rates
   - [ ] "Live Chat" card visible

3. **Chat Screen**
   - [ ] Click "Live Chat" → Opens chat
   - [ ] Quick chips visible at bottom
   - [ ] Click quick chip → Sends message
   - [ ] Type message → Send button works
   - [ ] Loading indicator appears
   - [ ] Response appears (or error if backend down)

4. **Voice Input**
   - [ ] Click mic button
   - [ ] Browser asks permission
   - [ ] Allow → Speak → Text appears

5. **Responsive**
   - [ ] Resize browser → Layout adjusts
   - [ ] Mobile width → Single column
   - [ ] Desktop width → Wider layout

---

## 🧪 Advanced Testing

### Run Tests

```bash
cd "C:\Projects\all in one"
flutter test
```

### Check Code Quality

```bash
flutter analyze
```

### Build for Production

```bash
# Build for web
flutter build web --release

# Output location:
# build/web/
```

### Test PWA Features

1. **Open DevTools** (F12)
2. **Go to Application tab**
3. **Check:**
   - [ ] Manifest loaded
   - [ ] Service worker registered
   - [ ] Cache storage working

### Test Performance

1. **Open DevTools** (F12)
2. **Go to Performance tab**
3. **Record while using app**
4. **Check:**
   - FCP < 2s
   - TTI < 3s
   - No layout shifts

---

## 📊 Expected Behavior

### Backend Connection

The app tries to connect to:
```
https://nijamdeen-kutty-guru-api.hf.space/chat
```

**If backend is UP:**
- ✅ Messages send successfully
- ✅ Bot responses appear
- ✅ No console errors

**If backend is DOWN:**
- ⚠️ Error message appears: "சர்வர் பிழை"
- ⚠️ Console shows network error
- ✅ App doesn't crash (graceful handling)

### Console Output (Expected)

When running, you should see:

```
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...
This app is linked to the debug service: ws://127.0.0.1:xxxxx
Debug service listening on ws://127.0.0.1:xxxxx/xxx
💪 Running with sound null safety
```

---

## 🛑 Stopping the App

### Method 1: VS Code
- Press `Shift+F5` to stop debugging
- OR click Stop button in debug toolbar

### Method 2: Terminal
- Press `Ctrl+C` in the terminal

### Method 3: Close Browser
- Simply close the Chrome window
- Flutter will detect and stop

---

## 📝 Development Workflow

### 1. Make Changes
Edit files in VS Code

### 2. Hot Reload
- Press `r` in terminal
- OR press Ctrl+S in VS Code (auto-save)

### 3. See Changes
- App updates instantly
- No need to restart

### 4. Full Restart (if needed)
- Press `R` in terminal
- OR restart debug (F5)

---

## 🔗 Useful Commands

```bash
# Check Flutter installation
flutter doctor

# Check for updates
flutter upgrade

# Get dependencies
flutter pub get

# Clean build
flutter clean

# Run tests
flutter test

# Analyze code
flutter analyze

# Run on Chrome
flutter run -d chrome

# Run on specific port
flutter run -d chrome --web-port=8080

# Build for production
flutter build web --release

# Show devices
flutter devices

# Show emulators
flutter emulators
```

---

## 📞 Quick Reference

| Task | Command/Action |
|------|----------------|
| **Start App** | `flutter run -d chrome` |
| **Open URL** | http://localhost:8080 |
| **Hot Reload** | Press `r` in terminal |
| **Hot Restart** | Press `R` in terminal |
| **Stop App** | Press `Ctrl+C` |
| **Run Tests** | `flutter test` |
| **Check Code** | `flutter analyze` |
| **Clean Build** | `flutter clean && flutter pub get` |

---

## 🎯 Success Indicators

Your app is running correctly if:

✅ Terminal shows "Running with sound null safety"  
✅ Chrome opens automatically  
✅ App loads at http://localhost:8080  
✅ Splash screen shows purple gradient  
✅ Dashboard displays after 3 seconds  
✅ No red errors in browser console  
✅ Hot reload works (press `r`)  

---

## 📚 Next Steps After Running

1. **Test all features** using the checklist above
2. **Read LOCALHOST_TESTING.md** for detailed testing guide
3. **Review PROJECT_STATUS.md** for known issues
4. **Check test/README.md** to run tests
5. **Read MIGRATION_GUIDE.md** to integrate new backend services

---

## 🆘 Need Help?

### Check These Logs:

1. **VS Code Terminal** - Flutter output
2. **Browser Console** (F12) - JavaScript errors
3. **Browser Network Tab** (F12) - API requests
4. **Flutter DevTools** - Performance metrics

### Documentation:

- **Getting Started:** README.md
- **Testing Guide:** LOCALHOST_TESTING.md
- **Project Status:** PROJECT_STATUS.md
- **Backend Migration:** MIGRATION_GUIDE.md
- **Test Suite:** test/README.md

---

*Ready to test! 🚀*  
*Powered by NJ TECH · Erode*
