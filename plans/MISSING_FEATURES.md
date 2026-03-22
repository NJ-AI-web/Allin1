# Missing Features Analysis

## Executive Summary

The current codebase implements **5 screens** (Login, Dashboard, Bike Taxi, Captain, Ride History) but the **Dashboard advertises 8 services** that are NOT implemented. This creates a significant gap between UI promises and functionality.

---

## Implemented Screens ✅

| Screen | File | Status |
|--------|------|--------|
| Login | `login_screen.dart` | ✅ Complete |
| Dashboard | `dashboard_screen.dart` | ✅ New (partial) |
| Bike Taxi | `bike_taxi_screen.dart` | ✅ Complete |
| Captain/Driver | `captain_screen.dart` | ✅ Complete |
| Ride History | `ride_history_screen.dart` | ✅ Complete |
| Chat | `main.dart` (ChatScreen) | ⚠️ Embedded only |

---

## Missing Service Screens (From Dashboard) ❌

The [dashboard_screen.dart](lib/screens/dashboard_screen.dart:177) advertises these 8 services but NO screens exist for them:

| # | Service | Dashboard Icon | Status | Priority |
|---|---------|----------------|--------|----------|
| 1 | **Food Delivery** | `Icons.restaurant` | ❌ NOT IMPLEMENTED | HIGH |
| 2 | **Grocery** | `Icons.shopping_bag` | ❌ NOT IMPLEMENTED | HIGH |
| 3 | **Tech Accessories** | `Icons.devices` | ❌ NOT IMPLEMENTED | HIGH |
| 4 | **Auto/Car** | `Icons.local_taxi` | ❌ NOT IMPLEMENTED | HIGH |
| 5 | **Logistics/Parcel** | `Icons.local_shipping` | ⚠️ Referenced in Captain | MEDIUM |
| 6 | **Pharmacy** | `Icons.medical_services` | ❌ NOT IMPLEMENTED | MEDIUM |
| 7 | **Messaging** | `Icons.chat_bubble` | ⚠️ Chat exists in main.dart | LOW |
| 8 | **Dating** | `Icons.favorite` | ❌ NOT IMPLEMENTED | LOW |

---

## Missing Core Features ❌

### Navigation & Account
- [ ] **Profile/Account Screen** - No dedicated user profile page
- [ ] **Settings Screen** - No app settings
- [ ] **Notifications Screen** - No dedicated notification history
- [ ] **Onboarding Screen** - Analytics track it but no UI

### Commerce
- [ ] **Cart System** - Analytics exist but no cart UI
- [ ] **Checkout Flow** - Analytics track checkout but no flow
- [ ] **Payment Screen** - Dashboard has wallet but no payment UI
- [ ] **Order Tracking** - No active order tracking screen

### User Features
- [ ] **Wallet Management** - UI in dashboard but no functionality
- [ ] **Favorites/Bookmarks** - No saved places or items
- [ ] **Help/Support** - No help center or FAQ

### Captain/Driver Features
- [ ] **Earnings History** - Shows today's stats only
- [ ] **Vehicle Management** - No bike/car registration UI
- [ ] **Documents Upload** - No ID/license upload
- [ ] **Customer Support** - No driver support channel

---

## Analytics Events With No Implementation

From [analytics_service.dart](lib/services/analytics_service.dart):

| Event | Feature | Status |
|-------|---------|--------|
| `browseFood` | Food browsing | ❌ |
| `browseGrocery` | Grocery browsing | ❌ |
| `browseTech` | Tech browsing | ❌ |
| `requestBikeTaxi` | Bike taxi | ✅ Implemented |
| `viewMarketRates` | Market rates | ❌ |
| `orderInitiated` | Orders | ❌ |
| `orderPlaced` | Orders | ❌ |
| `purchase` | Checkout | ❌ |
| `refund` | Returns | ❌ |

---

## Recommended Development Order

```
Phase 1: Core Commerce (High Priority)
├── 1. Food Delivery Screen
├── 2. Grocery Screen  
└── 3. Tech Accessories Screen

Phase 2: Transport (High Priority)
├── 4. Auto/Car Booking Screen
└── 5. Improve Bike Taxi (already exists)

Phase 3: Account & Wallet (Medium Priority)
├── 6. Profile Screen
├── 7. Wallet Screen
├── 8. Payment Flow
└── 9. Order Tracking

Phase 4: Additional Services (Lower Priority)
├── 10. Pharmacy Screen
├── 11. Logistics Screen
├── 12. Messaging Screen
└── 13. Dating Screen
```

---

## Technical Gaps

1. **No Router/Navigation Library** - Uses manual Navigator.push
2. **No State Management** - Uses setState only (no Provider/Riverpod/Bloc)
3. **No Local Database** - Hive mentioned in API service but not used for user data
4. **No Authentication Flow** - Login exists but no auth state management

---

## Files to Create

| Screen | Path |
|--------|------|
| Food Delivery | `lib/screens/food_screen.dart` |
| Grocery | `lib/screens/grocery_screen.dart` |
| Tech | `lib/screens/tech_screen.dart` |
| Auto/Car | `lib/screens/auto_car_screen.dart` |
| Pharmacy | `lib/screens/pharmacy_screen.dart` |
| Profile | `lib/screens/profile_screen.dart` |
| Wallet | `lib/screens/wallet_screen.dart` |
| Settings | `lib/screens/settings_screen.dart` |

---

## HIGH PRIORITY MISSING FEATURES (User Emphasized)

### ❌ DIRECT GOOGLE PAY / UPI Payment
**Status:** PARTIALLY IMPLEMENTED in bike_taxi_screen.dart
- UPI deep linking exists (line 1421-1441)
- Uses `upi://pay?pa=njtech@upi` protocol
- Opens GPay, PhonePe, Paytm, BHIM directly

**What's Missing:**
- [ ] No dedicated Wallet screen
- [ ] No saved UPI IDs management
- [ ] No payment transaction history
- [ ] No cashback/rewards UI
- [ ] No wallet balance integration (dashboard shows ₹12,450 but no functionality)

### ❌ Profile/Account Screen
**Status:** NOT IMPLEMENTED
- [ ] No user profile page
- [ ] No edit profile functionality
- [ ] No profile picture upload
- [ ] No account settings

### ❌ Settings Screen
**Status:** NOT IMPLEMENTED
- [ ] No app settings page
- [ ] No language toggle (Tamil/English)
- [ ] No notification preferences
- [ ] No privacy settings
- [ ] No help & support

### ❌ Cart & Checkout Flow
**Status:** NOT IMPLEMENTED (Analytics exist but no UI)
- [ ] No shopping cart UI
- [ ] No add to cart functionality
- [ ] No checkout page
- [ ] No order summary
- [ ] No order confirmation

### ❌ Order Tracking
**Status:** NOT IMPLEMENTED
- [ ] No active order tracking screen
- [ ] No order status updates
- [ ] No estimated delivery time
- [ ] No driver location real-time

### ❌ Notifications Screen
**Status:** NOT IMPLEMENTED
- [ ] No notification history
- [ ] No notification preferences
- [ ] No promotional notifications management

### ❌ Captain Document Upload
**Status:** NOT IMPLEMENTED
- [ ] No driver license upload
- [ ] No vehicle registration upload
- [ ] No ID verification
- [ ] No document status tracking

---

*Generated: 2026-03-15*
