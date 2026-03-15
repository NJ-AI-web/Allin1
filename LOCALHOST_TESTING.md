# 🚀 Running Erode Super App on Localhost

## ✅ Development Server Started

Your Flutter web app is now running on **localhost:8080**!

---

## 🌐 Access Your App

### Primary URL
**http://localhost:8080**

### Alternative URLs
- http://127.0.0.1:8080
- http://[::]:8080

---

## 📱 Testing Checklist

### 1. **Dashboard Screen**
- [ ] Splash screen animation plays
- [ ] Navigates to dashboard after 3.2 seconds
- [ ] All 4 commerce cards visible:
  - 🍔 Food Delivery
  - 🍅 Grocery
  - 📱 Tech Accessories
  - 🚕 Bike Taxi
- [ ] Market ticker shows rates (மஞ்சள், தேங்காய், கொத்தமல்லி)
- [ ] Live Chat card visible
- [ ] Click on commerce cards → Opens chat with pre-filled message

### 2. **Chat Screen**
- [ ] Tap on Live Chat card → Opens chat
- [ ] Welcome view with quick chips visible
- [ ] Quick chips work (click to send):
  - 🍔 Food Delivery — 16th Road Specials
  - 🍅 Grocery — Erode Fresh order
  - 📱 Mobile Accessories — NJ TECH
  - 🚕 Bike Taxi — Quick ride booking
  - 🟡 மஞ்சள் விலை இன்னைக்கு எவ்வளவு?
- [ ] Type message → Send button works
- [ ] Bot response appears (may fail if backend is down)
- [ ] Voice button (mic) visible
- [ ] Copy button on messages works
- [ ] WhatsApp share button works

### 3. **Voice Features**
- [ ] Click mic button
- [ ] Browser asks for microphone permission
- [ ] Speak → Text appears in input field
- [ ] Voice input stops when you stop speaking

### 4. **PWA Features**
- [ ] Open DevTools (F12)
- [ ] Go to Application tab
- [ ] Check manifest is loaded
- [ ] Check service worker registered
- [ ] Try installing app (install icon in address bar)

### 5. **Responsive Design**
- [ ] Resize browser window
- [ ] Test mobile width (375px)
- [ ] Test tablet width (768px)
- [ ] Test desktop width (1440px)
- [ ] Test landscape mode

### 6. **Accessibility**
- [ ] Open DevTools → Lighthouse
- [ ] Run accessibility audit
- [ ] Check score (target: 85+)
- [ ] Test keyboard navigation (Tab, Enter, Esc)
- [ ] Test screen reader (ChromeVox or NVDA)

---

## 🧪 Testing Backend Integration

### Test Chat Flow

1. **Open Chat**
   - Click on "Live Chat" card or any commerce card

2. **Send Message**
   ```
   Hello, I want to order food
   ```

3. **Expected Behavior**
   - Loading indicator appears
   - If backend is UP: Response appears
   - If backend is DOWN: Error message appears

4. **Check Network Tab**
   - Open DevTools → Network tab
   - Look for POST request to: `https://nijamdeen-kutty-guru-api.hf.space/chat`
   - Check status code (200 = success, 500/503 = backend error)

### Test with New API Service (If Migrated)

If you've integrated the new `ApiService`:

1. Check browser console for API logs
2. Look for retry attempts if backend fails
3. Check if failover URL is used (if primary fails 3 times)
4. Verify caching works (identical requests should be faster)

---

## 🔧 Debugging

### Common Issues & Solutions

#### Issue 1: "Flutter not found" error
**Solution:** Install Flutter SDK or add to PATH
```bash
# Check Flutter installation
flutter doctor
```

#### Issue 2: Port 8080 already in use
**Solution:** Use different port
```bash
flutter run -d chrome --web-port=8081
```

#### Issue 3: Chrome doesn't open
**Solution:** Open manually
```
1. Run: flutter run -d chrome --web-port=8080 --no-launch-browser
2. Open Chrome manually
3. Go to: http://localhost:8080
```

#### Issue 4: Backend API not responding
**Solution:** Check backend status
```
1. Visit: https://nijamdeen-kutty-guru-api.hf.space/chat
2. If down, app should show error message
3. Check console for error details
```

#### Issue 5: Hot reload not working
**Solution:** Restart app
```
1. Press 'r' in terminal for hot reload
2. Press 'R' for hot restart
3. Or press 'q' to quit and run again
```

---

## 📊 Performance Testing

### DevTools Performance Tab

1. **Open DevTools** (F12)
2. **Go to Performance tab**
3. **Record while:**
   - Loading app
   - Navigating between screens
   - Sending messages
   - Scrolling through lists

4. **Check Metrics:**
   - First Contentful Paint (FCP): Target < 2s
   - Time to Interactive (TTI): Target < 3s
   - Total Blocking Time (TBT): Target < 300ms
   - Cumulative Layout Shift (CLS): Target < 0.1

### Lighthouse Audit

1. **Open DevTools** (F12)
2. **Go to Lighthouse tab**
3. **Select:** Progressive Web App
4. **Run Audit**

**Target Scores:**
- Performance: 85+
- Accessibility: 90+
- Best Practices: 90+
- SEO: 90+
- PWA: 80+

---

## 🎨 Visual Testing

### Check These Elements

1. **Colors**
   - Background: #08080F (dark)
   - Surface: #111118
   - Purple: #7B6FE0
   - Orange: #E07C6F
   - Green: #3DBA6F
   - Gold: #F5C542

2. **Typography**
   - Font: Noto Sans Tamil
   - Titles: Bold, gradient effect
   - Body: Regular weight

3. **Animations**
   - Splash screen fade + scale
   - Screen transitions (fade)
   - Typing indicator (dots)
   - Button ripples

4. **Spacing**
   - Consistent padding (16dp)
   - Card margins (10dp)
   - Gaps (4/8/16/24dp)

---

## 📱 Mobile Testing

### Chrome DevTools Device Mode

1. **Open DevTools** (F12)
2. **Click Toggle Device Toolbar** (Ctrl+Shift+M)
3. **Select Device:**
   - iPhone 12 Pro (390x844)
   - Pixel 5 (393x851)
   - Samsung Galaxy S20 (360x800)
   - iPad Pro (1024x1366)

4. **Test:**
   - Touch interactions
   - Swipe gestures
   - Safe areas (notch, home indicator)
   - Orientation changes

---

## 🧪 Automated Testing

### Run Tests While Server is Running

```bash
# In a new terminal
cd "C:\Projects\all in one"

# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| **Local App** | http://localhost:8080 |
| **Backend API** | https://nijamdeen-kutty-guru-api.hf.space/chat |
| **DevTools** | F12 in browser |
| **Flutter DevTools** | http://localhost:9100 |

---

## 🛑 Stopping the Server

### Method 1: Terminal
Press `Ctrl+C` in the terminal running Flutter

### Method 2: Command
```bash
# Find process
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /F /PID <PID>
```

### Method 3: Flutter Command
```bash
flutter kill
```

---

## 📝 Test Report Template

Use this template to document your testing:

```markdown
## Test Session - [DATE]

### Environment
- Browser: Chrome/Edge/Firefox
- Device: Desktop/Mobile/Tablet
- Network: WiFi/Ethernet

### Tests Run
- [ ] Dashboard loads
- [ ] All 4 commerce cards visible
- [ ] Market ticker displays
- [ ] Chat opens
- [ ] Messages send/receive
- [ ] Voice input works
- [ ] WhatsApp share works
- [ ] PWA installable
- [ ] Responsive on resize
- [ ] Accessibility score 90+

### Issues Found
1. [Issue description]
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Severity (Critical/High/Medium/Low)

### Backend Status
- API Response: ✅ Working / ❌ Down
- Response Time: ~[X] seconds
- Error Messages: [If any]

### Next Steps
- [ ] Fix critical issues
- [ ] Integrate new ApiService
- [ ] Add Semantics widgets
- [ ] Improve PWA score
```

---

## 🎯 Success Criteria

Your app is working correctly if:

✅ Splash screen shows "Erode Super App" with purple gradient  
✅ Dashboard displays all 4 commerce cards  
✅ Market ticker shows 3 rates (Turmeric, Coconut, Coriander)  
✅ Clicking commerce card opens chat with pre-filled message  
✅ Sending messages works (if backend is up)  
✅ Voice button requests microphone permission  
✅ App is responsive when resizing browser  
✅ No console errors (except expected backend errors)  
✅ PWA manifest loads (check DevTools → Application)  

---

## 📞 Support

**Issues?** Check these logs:

1. **Browser Console** (F12 → Console tab)
2. **Network Tab** (F12 → Network tab)
3. **Terminal Output** (Flutter run output)
4. **Flutter DevTools** (http://localhost:9100)

**Documentation:**
- Backend: `MIGRATION_GUIDE.md`
- Testing: `test/README.md`
- UI/UX: `ACCESSIBILITY_GUIDE.md`
- Security: `SECURITY_AUDIT.md`

---

*Happy Testing! 🎉*  
*Powered by NJ TECH · Erode*
