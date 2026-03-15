# 🛒 Erode Super App (நம்ம குரு AI)

**Multi-vendor Commerce Platform - Food · Grocery · Tech · Bike Taxi**

[![Tests](https://img.shields.io/badge/tests-303%20cases-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-~75%25-brightgreen)]()
[![Flutter](https://img.shields.io/badge/flutter-3.3%2B-blue)]()
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web-lightgrey)]()

**Powered by NJ TECH · Erode**

---

## 🌟 Features

### 🎯 Core Services
- **🍔 Food Delivery** - 16th Road Specials, local restaurants
- **🍅 Grocery** - Erode Fresh, vegetables & essentials
- **📱 Tech Accessories** - NJ TECH store, mobile accessories
- **🚕 Bike Taxi** - Local Erode rides, quick booking

### 🤖 AI-Powered Features
- **Voice Chat** - Tamil/English bilingual support
- **Sales Assistant** - Smart order recommendations
- **Market Rates** - Live turmeric, coconut, coriander prices
- **WhatsApp Integration** - Share orders instantly

### 🎨 User Experience
- **Dark Theme** - Premium gradient design
- **Voice-First** - Hands-free ordering
- **PWA Support** - Install on any device
- **Offline Capable** - Works without internet (coming soon)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.3+
- Android Studio / VS Code
- Firebase account (for analytics)

### Installation

```bash
# Clone repository
git clone <your-repo-url>
cd "all in one"

# Install dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point
├── config/
│   └── api_config.dart              # API configuration
├── models/
│   └── api_models.dart              # Request/response models
└── services/
    ├── api_service.dart             # HTTP client (Dio)
    └── analytics_service.dart       # Firebase Analytics

test/
├── models/                          # Model tests
├── widgets/                         # Widget tests
├── screens/                         # Screen tests
├── services/                        # Service tests
└── integration/                     # Integration tests
```

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run by Category
```bash
# Model tests
flutter test test/models/

# Widget tests
flutter test test/widgets/

# Screen tests
flutter test test/screens/

# Integration tests
flutter test test/integration/
```

### Generate Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Test Coverage:** ~75% (303 test cases)

---

## 🔧 Backend Services

### API Service (Dio)
- ✅ Exponential backoff retry
- ✅ Circuit breaker pattern
- ✅ Response caching
- ✅ Rate limiting
- ✅ Failover support
- ✅ Request deduplication

### Analytics Service (Firebase)
- ✅ 30+ event types tracked
- ✅ E-commerce tracking
- ✅ Crash reporting
- ✅ Performance monitoring

See [`MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md) for integration details.

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [`PROJECT_STATUS.md`](PROJECT_STATUS.md) | Current status & roadmap |
| [`SWARM_REPORT.md`](SWARM_REPORT.md) | Agent swarm analysis |
| [`MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md) | Backend migration guide |
| [`test/README.md`](test/README.md) | Test suite documentation |

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.3+ - Cross-platform UI
- **Material 3** - Modern design system
- **Google Fonts** - Tamil typography

### Backend Services
- **Dio** - Advanced HTTP client
- **Firebase** - Analytics, Crashlytics, Performance
- **Hive** - Local storage & caching

### APIs
- **Chat API** - Hugging Face Spaces
- **Voice** - speech_to_text package
- **WhatsApp** - URL launcher

---

## 📊 Key Metrics

| Metric | Value |
|--------|-------|
| Test Cases | 303 |
| Coverage | ~75% |
| Source Files | 22 |
| API Retry Attempts | 3 |
| Rate Limit | 30 req/min |
| Cache TTL | 5-30 min |

---

## 🎯 Roadmap

### Q1 2026 (Completed)
- ✅ Test suite creation
- ✅ Backend services implementation
- ✅ API resilience features
- ✅ Analytics integration

### Q2 2026 (Planned)
- [ ] Refactor main.dart into modules
- [ ] Implement Riverpod state management
- [ ] Fix accessibility (WCAG AA)
- [ ] PWA offline mode
- [ ] Payment integration (UPI)

### Q3 2026 (Planned)
- [ ] Order management system
- [ ] Vendor dashboard
- [ ] Real-time order tracking
- [ ] Push notifications
- [ ] Loyalty program

---

## 🤝 Contributing

### Development Workflow

1. **Create branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make changes**

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Commit**
   ```bash
   git add .
   git commit -m "feat: add your feature"
   ```

5. **Push & PR**

### Code Review Checklist
- [ ] Tests added/updated
- [ ] Coverage maintained (>75%)
- [ ] Documentation updated
- [ ] Linting passes (`flutter analyze`)
- [ ] Error handling implemented

---

## 📞 Support

**Team:** NJ TECH  
**Location:** Erode, India  

For questions:
- Backend: See [`MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md)
- Testing: See [`test/README.md`](test/README.md)
- Architecture: See [`SWARM_REPORT.md`](SWARM_REPORT.md)

---

## 📄 License

This project is proprietary software developed by NJ TECH.

---

## 🙏 Acknowledgments

- **BAPX** - Platform support
- **Hugging Face Spaces** - Backend hosting
- **Firebase** - Analytics & monitoring
- **Flutter Team** - Amazing framework

---

*Built with ❤️ in Erode, Tamil Nadu, India*  
*நம்ம ஊரு சூப்பர் ஆப்!*
