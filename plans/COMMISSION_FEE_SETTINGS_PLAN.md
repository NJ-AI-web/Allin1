# Commission & Platform Fees Management System

## Overview
A comprehensive system for admins to configure commissions, fees, and costs for the Allin1 Super App platform. This enables dynamic control over:
- Rider/Captain commission rates
- Seller/Store commission rates
- Platform fees
- Delivery costs
- Service-specific pricing

**Project:** Allin1 Super App (Flutter)  
**Backend:** Firebase Firestore  
**State Management:** Provider  

---

## 1. Current State Analysis

### Existing Hardcoded Values (to be replaced)
- **Delivery Fee**: ₹30 (free above ₹200) - [`lib/providers/cart_provider.dart:50`](lib/providers/cart_provider.dart:50)
- **No admin configuration exists**

### User Types
- `rider` - Delivery captains/drivers
- `user` - Regular customers
- `admin` - Platform administrators

---

## 2. Data Model

### 2.1 Platform Settings Model
```dart
class PlatformSettings {
  String id; // Always "global" - single document
  
  // Rider/Captain Commissions (percentage of ride fare)
  RiderCommission riderCommission;
  
  // Seller/Store Commissions (percentage of order value)
  SellerCommission sellerCommission;
  
  // Platform Fees
  PlatformFee platformFee;
  
  // Delivery Settings
  DeliverySettings deliverySettings;
  
  // Service-specific pricing
  Map<String, ServicePricing> servicePricing;
  
  // Last updated
  DateTime updatedAt;
  String updatedBy;
}

class RiderCommission {
  double bikeTaxiPercent;      // e.g., 15.0 (15%)
  double autoPercent;          // e.g., 15.0
  double carPercent;           // e.g., 12.0
  double deliveryPercent;      // e.g., 15.0
  double foodDeliveryPercent;  // e.g., 18.0
  double groceryPercent;      // e.g., 18.0
  
  // Minimum guaranteed per ride
  double minimumEarning;      // e.g., ₹30
  
  // Peak hour multiplier
  double peakHourMultiplier;  // e.g., 1.5x
}

class SellerCommission {
  double foodPercent;          // e.g., 20.0
  double groceryPercent;      // e.g., 18.0
  double techPercent;         // e.g., 15.0
  double pharmacyPercent;    // e.g., 15.0
  double generalPercent;      // e.g., 15.0
  
  // Commission thresholds
  double? minimumOrder;       // e.g., ₹100 (below this, flat fee)
  double? flatFeeBelowMin;    // e.g., ₹15
}

class PlatformFee {
  double paymentGatewayFee;   // e.g., 2.0% (UPI/cards)
  double upiZeroFee;         // true/false - zero UPI fees
  
  // Subscription fees (future)
  double? monthlySubscription;
  double? annualSubscription;
}

class DeliverySettings {
  double baseDeliveryFee;     // ₹30
  double freeDeliveryThreshold; // ₹200
  double perKmRate;          // ₹5/km
  double minimumDistanceKm;  // 2km
  
  // Distance tiers
  List<DeliveryTier> tiers;
  
  // Special delivery types
  double expressDeliveryFee;  // ₹50 extra
  double scheduledDeliveryFee; // ₹20 extra
}

class DeliveryTier {
  double maxDistanceKm;
  double fee;
}

class ServicePricing {
  String serviceName;
  double basePrice;
  double perKmRate;
  double perKgRate;
  double minimumPrice;
}
```

### 2.2 Firestore Collection Structure
```
platformSettings/
  global/
    - id: "global"
    - riderCommission: map
      - bikeTaxiPercent: 15.0
      - autoPercent: 15.0
      - carPercent: 12.0
      - deliveryPercent: 15.0
      - foodDeliveryPercent: 18.0
      - groceryPercent: 18.0
      - minimumEarning: 30.0
      - peakHourMultiplier: 1.5
    - sellerCommission: map
      - foodPercent: 20.0
      - groceryPercent: 18.0
      - techPercent: 15.0
      - pharmacyPercent: 15.0
      - generalPercent: 15.0
      - minimumOrder: 100.0
      - flatFeeBelowMin: 15.0
    - platformFee: map
      - paymentGatewayFee: 2.0
      - upiZeroFee: true
    - deliverySettings: map
      - baseDeliveryFee: 30.0
      - freeDeliveryThreshold: 200.0
      - perKmRate: 5.0
      - minimumDistanceKm: 2.0
      - expressDeliveryFee: 50.0
      - scheduledDeliveryFee: 20.0
      - tiers: [
          {maxDistanceKm: 3, fee: 30},
          {maxDistanceKm: 5, fee: 40},
          {maxDistanceKm: 10, fee: 60},
          {maxDistanceKm: 999, fee: 100}
        ]
    - servicePricing: map (optional per-service overrides)
    - updatedAt: timestamp
    - updatedBy: string

// Individual store/seller overrides
sellerOverrides/
  {storeId}/
    - customCommissionPercent: 15.0 (overrides default)
    - customDeliveryFee: 25.0
    - isActive: true
    - notes: string
```

---

## 3. Commission Calculation Logic

### 3.1 Rider Earnings Calculation
```dart
double calculateRiderEarnings({
  required double fare,
  required String serviceType,
  required bool isPeakHour,
}) {
  final settings = getPlatformSettings();
  final commissionPercent = _getRiderCommissionPercent(serviceType);
  
  double earnings = fare * (1 - (commissionPercent / 100));
  
  // Apply minimum guarantee
  if (earnings < settings.riderCommission.minimumEarning) {
    earnings = settings.riderCommission.minimumEarning;
  }
  
  // Apply peak hour multiplier
  if (isPeakHour) {
    earnings *= settings.riderCommission.peakHourMultiplier;
  }
  
  return earnings;
}
```

### 3.2 Seller Payout Calculation
```dart
double calculateSellerPayout({
  required double orderTotal,
  required String category,
}) {
  final settings = getPlatformSettings();
  final commissionPercent = _getSellerCommissionPercent(category);
  
  // Check for minimum order threshold
  if (settings.sellerCommission.minimumOrder != null &&
      orderTotal < settings.sellerCommission.minimumOrder!) {
    return orderTotal - settings.sellerCommission.flatFeeBelowMin!;
  }
  
  return orderTotal * (1 - (commissionPercent / 100));
}
```

### 3.3 Customer Delivery Fee Calculation
```dart
double calculateDeliveryFee({
  required double distanceKm,
  required String deliveryType,
  required double subtotal,
}) {
  final settings = getPlatformSettings();
  
  // Free delivery above threshold
  if (subtotal >= settings.deliverySettings.freeDeliveryThreshold) {
    return 0.0;
  }
  
  double fee = settings.deliverySettings.baseDeliveryFee;
  
  // Distance-based tiers
  for (final tier in settings.deliverySettings.tiers) {
    if (distanceKm <= tier.maxDistanceKm) {
      fee = tier.fee;
      break;
    }
  }
  
  // Add express/scheduled fees
  if (deliveryType == 'express') {
    fee += settings.deliverySettings.expressDeliveryFee;
  } else if (deliveryType == 'scheduled') {
    fee += settings.deliverySettings.scheduledDeliveryFee;
  }
  
  return fee;
}
```

---

## 4. Admin UI Specification

### 4.1 Settings Screen Layout
```
┌─────────────────────────────────────────────────────────┐
│  Platform Settings                    [Save] [Reset]    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─ Rider Commission ─────────────────────────────┐   │
│  │  Bike Taxi:    [____15____] %                   │   │
│  │  Auto:         [____15____] %                   │   │
│  │  Car:          [____12____] %                   │   │
│  │  Delivery:     [____15____] %                   │   │
│  │  Food Delivery:[____18____] %                   │   │
│  │  Grocery:      [____18____] %                   │   │
│  │                                                │   │
│  │  Min Guarantee: [₹____30____]                   │   │
│  │  Peak Multiplier:[__1.5__]x                     │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─ Seller Commission ────────────────────────────┐   │
│  │  Food:        [____20____] %                   │   │
│  │  Grocery:     [____18____] %                   │   │
│  │  Tech:        [____15____] %                   │   │
│  │  Pharmacy:    [____15____] %                   │   │
│  │  General:     [____15____] %                   │   │
│  │                                                │   │
│  │  Min Order:   [₹__100____]  (below = flat ₹15) │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─ Platform Fees ────────────────────────────────┐   │
│  │  Payment Gateway: [____2____] %                 │   │
│  │  ☑ Zero UPI Fees                               │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─ Delivery Settings ─────────────────────────────┐   │
│  │  Base Fee:     [₹____30____]                   │   │
│  │  Free Above:   [₹__200____]                    │   │
│  │  Per KM Rate:  [₹_____5____]                   │   │
│  │  Express Fee:  [₹____50____]                   │   │
│  │  Scheduled Fee:[₹____20____]                   │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Validation Rules
- Commission percentages: 0-100%
- Minimum guarantee: ₹0-100
- Fees: ₹0-1000
- All fields required
- Warning if rider commission < 10% (may discourage captains)

---

## 5. Implementation Components

### 5.1 Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `lib/models/platform_settings.dart` | Create | Data models |
| `lib/services/platform_settings_service.dart` | Create | Load/save settings |
| `lib/providers/platform_settings_provider.dart` | Create | State management |
| `lib/screens/admin/commission_settings_screen.dart` | Create | Admin UI |
| `lib/main.dart` | Modify | Add route |
| `firestore.rules` | Modify | Add security rules |
| `lib/providers/cart_provider.dart` | Modify | Use dynamic fees |

### 5.2 Service Layer
```dart
class PlatformSettingsService {
  static final PlatformSettingsService _instance = 
      PlatformSettingsService._internal();
  factory PlatformSettingsService() => _instance;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current settings (cached)
  Future<PlatformSettings> getSettings();
  
  // Update settings (admin only)
  Future<void> updateSettings(PlatformSettings settings);
  
  // Get seller override if exists
  Future<SellerOverride?> getSellerOverride(String storeId);
  
  // Set seller override
  Future<void> setSellerOverride(String storeId, SellerOverride override);
  
  // Reset to defaults
  Future<void> resetToDefaults();
}
```

---

## 6. Firestore Security Rules

```javascript
// Platform settings - Admin only
match /platformSettings/global {
  allow read: if request.auth != null;
  allow write: if isAdmin();
}

match /sellerOverrides/{storeId} {
  allow read: if request.auth != null;
  allow write: if isAdmin();
}
```

---

## 7. Integration Points

### 7.1 Cart Provider Integration
- Replace hardcoded `_deliveryFee` with dynamic value from settings
- Fetch settings on app start, cache locally
- Listen to settings changes in real-time

### 7.2 Order Completion Integration
- Calculate rider earnings using commission settings
- Calculate seller payout using commission settings
- Record platform fee for analytics

### 7.3 Wallet Integration
- Use rider commission for earnings calculation
- Display platform deduction transparently

---

## 8. Default Values

| Setting | Default | Description |
|---------|---------|-------------|
| Bike Taxi Commission | 15% | Rider receives 85% |
| Auto Commission | 15% | Rider receives 85% |
| Car Commission | 12% | Rider receives 88% |
| Delivery Commission | 15% | Rider receives 85% |
| Food Delivery Commission | 18% | Rider receives 82% |
| Grocery Commission | 18% | Rider receives 82% |
| Minimum Rider Earning | ₹30 | Floor per ride |
| Peak Hour Multiplier | 1.5x | Surge pricing |
| Food Seller Commission | 20% | Platform takes 20% |
| Grocery Seller Commission | 18% | Platform takes 18% |
| Tech Seller Commission | 15% | Platform takes 15% |
| Payment Gateway Fee | 2% | Transaction fee |
| Zero UPI Fees | true | No extra UPI charge |
| Base Delivery Fee | ₹30 | Standard delivery |
| Free Delivery Threshold | ₹200 | Free above this |

---

## 9. Analytics & Reporting

### Admin Dashboard Additions
- Total platform revenue (commissions collected)
- Average rider earnings after commission
- Average seller payout after commission
- Delivery fee revenue
- Commission by service type

---

*Plan created: 2026-03-16*
*For implementation, switch to Code mode*
