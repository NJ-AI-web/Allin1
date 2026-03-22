# Self-Pickup Feature - Comprehensive Plan

## Overview
Add self-pickup option for store orders in the Erode Super App (Kutty Guru AI). This allows customers to order online and pick up from the store instead of delivery.

**State Management:** Provider  
**Design Pattern:** Match `captain_screen.dart`  
**Responsive:** Mobile (portrait/landscape), Tablet, Desktop Web

---

## 1. Data Models

### 1.1 Order with Pickup
```dart
enum DeliveryType {
  delivery,    // Captain delivers to customer
  selfPickup, // Customer picks up from store
}

enum PickupStatus {
  pending,           // Order placed, awaiting pickup
  readyForPickup,   // Store marked as ready
  pickedUp,         // Customer collected
  expired,           // Not picked within time limit
  cancelled,        // Pickup cancelled
}

class Order {
  String id;
  String customerId;
  String storeId;
  String storeName;
  List<OrderItem> items;
  double subtotal;
  double deliveryFee;      // 0 for self-pickup
  double discount;
  double total;
  
  DeliveryType deliveryType;
  
  // Pickup specific
  PickupStatus? pickupStatus;
  String? pickupCode;      // 6-digit verification code
  DateTime? pickupTimeSlot; // Scheduled pickup time
  DateTime? readyAt;       // When store marked ready
  DateTime? pickedUpAt;     // Actual pickup time
  
  // Delivery specific
  String? deliveryAddress;
  String? assignedCaptainId;
  
  OrderStatus status;
  DateTime createdAt;
  DateTime? completedAt;
}
```

### 1.2 Time Slot
```dart
class PickupTimeSlot {
  String id;
  String storeId;
  DateTime startTime;
  DateTime endTime;
  int maxOrders;     // Capacity
  int currentOrders; // Filled
  bool isActive;
}

class Store {
  // Add to existing model
  bool selfPickupEnabled;
  String address;
  String latitude;
  String longitude;
  String operatingHours; // "9:00 AM - 9:00 PM"
  List<PickupTimeSlot> pickupSlots;
  int pickupSlotDurationMinutes; // Default: 30
}
```

### 1.3 Pickup Verification
```dart
class PickupVerification {
  String orderId;
  String pickupCode;     // 6-digit numeric
  int attemptsRemaining; // Max 3
  DateTime? lastAttemptAt;
  bool isVerified;
}
```

---

## 2. Customer-Facing Screens

### 2.1 Store Product Listing (Modified)
```
┌────────────────────────────────────────────┐
│  🍕 Domino's Pizza                    ⭐4.5│
│  📍 Erode Main Road         🚗 2.5km      │
├────────────────────────────────────────────┤
│  🍔 Food · 🍅 Grocery · 📱 Tech            │
├────────────────────────────────────────────┤
│                                            │
│  Delivery Type:                            │
│  ┌─────────────────┐  ┌─────────────────┐ │
│  │ 🚗 Delivery     │  │ 🏪 Self-Pickup │ │
│  │   ₹29          │  │   FREE         │ │
│  └─────────────────┘  └─────────────────┘ │
│                                            │
│  ⏱ Select Pickup Time (if self-pickup)   │
│  [ Today 11:00 AM - 11:30 AM         ▼ ] │
│  [ Today 11:30 AM - 12:00 PM         ▼ ] │
│                                            │
└────────────────────────────────────────────┘
```

### 2.2 Order Creation Flow
```
Step 1: Cart → Select Delivery Type
  - Toggle: Delivery / Self-Pickup
  - If Self-Pickup: Show store location map
  - If Self-Pickup: Show time slot selector

Step 2: Select Time Slot (Self-Pickup only)
  - Calendar view of available slots
  - Show capacity (3/10 slots filled)
  - No slots available → Show next available

Step 3: Payment
  - Delivery: subtotal + delivery fee
  - Self-Pickup: subtotal only (no delivery fee)

Step 4: Confirmation
  - Show pickup code (6-digit)
  - Show store address
  - Show estimated ready time
```

### 2.3 Order Tracking Screen (Modified)
```
┌────────────────────────────────────────────┐
│  ORDER #ORD-12345                          │
│  🏪 Self-Pickup from Domino's              │
├────────────────────────────────────────────┤
│  STATUS: ✅ Ready for Pickup!             │
│                                            │
│  📍 Store Location                         │
│  Erode Main Road, Erode                   │
│  [ View Map ]                              │
│                                            │
│  ⏰ Pickup Time                            │
│  Today, 11:30 AM - 12:00 PM              │
│                                            │
│  🔢 Pickup Code                            │
│  ┌───┬───┬───┬───┬───┬───┐               │
│  │ 8 │ 4 │ 2 │ 1 │ 5 │ 9 │               │
│  └───┴───┴───┴───┴───┴───┘               │
│                                            │
│  Show this code to store staff            │
│                                            │
│  [ 📞 Call Store ]  [ 🗺️ Navigate ]      │
│                                            │
│  [ Cancel Pickup ]                         │
└────────────────────────────────────────────┘
```

---

## 3. Store Owner Dashboard

### 3.1 Pickup Management Screen
```
┌─────────────────────────────────────────────────────────────────┐
│  📦 Pickup Orders (12)                          🔔 3 Ready    │
├─────────────────────────────────────────────────────────────────┤
│  Filter: [All ▼] [Pending ▼] [Ready ▼] [Completed ▼]          │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐│
│  │ #ORD-12345 - Raj Kumar                                    ││
│  │ Items: 2x Chicken Pizza, 1x Garlic Bread                 ││
│  │ Total: ₹650                                               ││
│  │ Code: 842159  │  Status: Ready  │  Time: 11:30 AM        ││
│  │ [Mark Ready] [View Details] [Cancel]                     ││
│  └────────────────────────────────────────────────────────────┘│
│  ┌────────────────────────────────────────────────────────────┐│
│  │ #ORD-12346 - Sarah M                                      ││
│  │ Items: 1x Veg Burger, 2x Fries                            ││
│  │ Total: ₹320                                               ││
│  │ Code: 753921  │  Status: Pending │  Time: 12:00 PM        ││
│  │ [Mark Ready] [View Details] [Cancel]                     ││
│  └────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Pickup Actions
| Action | Description |
|--------|-------------|
| Mark Ready | Change status to readyForPickup, notify customer |
| Verify Pickup | Enter code or scan QR, mark as pickedUp |
| View on Map | Show customer location (if en route) |
| Cancel Pickup | Cancel and refund if paid |
| Reschedule | Change pickup time slot |

### 3.3 QR Code Scanner
- Store staff can scan customer's QR code
- Or manually enter 6-digit code
- After verification: Mark order as pickedUp

---

## 4. Captain/Delivery Partner Interface

### 4.1 When Captain Arrives at Store (Delivery Orders)
```
┌────────────────────────────────────────────┐
│  📦 Pickup from Store                      │
├────────────────────────────────────────────┤
│  Store: Domino's Pizza                     │
│  Address: Erode Main Road                  │
│                                            │
│  Orders to Collect: 2                      │
│  ┌──────────────────────────────────────┐ │
│  │ #ORD-12345 - ₹650                    │ │
│  │ #ORD-12347 - ₹420                    │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  [ 📷 Scan Package ]  [ Confirm Pickup ]   │
│                                            │
└────────────────────────────────────────────┘
```

**Note:** Self-pickup orders do NOT involve captains. This is for delivery orders where captains pick up from stores.

---

## 5. Responsive Layouts

### 5.1 Mobile Portrait (< 480px)
```
┌─────────────────────┐
│  Order #ORD-12345   │
├─────────────────────┤
│  [Map Full Width]   │
│                     │
│  Status Card        │
│  (Full Width)       │
│                     │
│  Action Buttons     │
│  (Stacked)          │
└─────────────────────┘
```

### 5.2 Mobile Landscape (480-768px)
```
┌────────────────────────────────────────────┐
│  Order #ORD-12345     │  Map (Half Width) │
├──────────────────────┼────────────────────│
│  Status Card         │                    │
│  (Half Width)        │  Verification Code │
│                      │  (Centered)        │
│  Action Buttons      │                    │
└──────────────────────┴────────────────────┘
```

### 5.3 Tablet (768-1024px)
```
┌─────────────────────────────────────────────────────┐
│  Header                                              │
├──────────────────────┬──────────────────────────────┤
│                      │                              │
│  Order Details       │     Map + Store Info         │
│  (40% width)         │     (60% width)              │
│                      │                              │
├──────────────────────┴──────────────────────────────┤
│  Action Buttons (Centered)                          │
└─────────────────────────────────────────────────────┘
```

### 5.4 Desktop Web (>1024px)
```
┌──────────────────────────────────────────────────────────────────┐
│  Header                                                          │
├─────────────────────┬────────────────────────────────────────────┤
│                     │                                            │
│  Order Details      │         Map (Large)                        │
│  (300px fixed)     │         Store Location                     │
│                     │                                            │
│  Verification      │                                            │
│  Code (Large)      │                                            │
│                     │                                            │
│  Action Buttons     │                                            │
│  (Horizontal)       │                                            │
│                     │                                            │
└─────────────────────┴────────────────────────────────────────────┘
     300px                        Flexible
```

---

## 6. State Management (Provider)

### 6.1 PickupOrderProvider
```dart
class PickupOrderProvider extends ChangeNotifier {
  Order? currentOrder;
  DeliveryType deliveryType = DeliveryType.delivery;
  PickupTimeSlot? selectedSlot;
  List<PickupTimeSlot> availableSlots = [];
  PickupStatus? pickupStatus;
  String? pickupCode;
  
  // Methods
  void setDeliveryType(DeliveryType type);
  Future<void> loadAvailableSlots(String storeId);
  void selectTimeSlot(PickupTimeSlot slot);
  Future<void> createPickupOrder();
  Future<void> markAsReady();
  Future<bool> verifyPickup(String code);
  Future<void> cancelPickup();
}
```

### 6.2 StorePickupProvider (For Store Owners)
```dart
class StorePickupProvider extends ChangeNotifier {
  List<Order> pendingPickups = [];
  List<Order> readyPickups = [];
  List<Order> completedPickups = [];
  
  Future<void> loadPickupOrders();
  Future<void> markOrderReady(String orderId);
  Future<bool> verifyAndComplete(String orderId, String code);
  Future<void> cancelPickup(String orderId);
}
```

---

## 7. File Structure

```
lib/
├── models/
│   ├── order.dart              # Updated with pickup fields
│   ├── pickup_time_slot.dart
│   └── store.dart              # Updated with pickup settings
├── providers/
│   ├── pickup_order_provider.dart     # Customer
│   └── store_pickup_provider.dart     # Store owner
├── screens/
│   ├── store/
│   │   ├── store_detail_screen.dart   # Add pickup toggle
│   │   └── checkout_screen.dart       # Add pickup flow
│   ├── order/
│   │   └── pickup_tracking_screen.dart # Track pickup order
│   └── store_owner/
│       └── pickup_management_screen.dart # Store dashboard
├── widgets/
│   ├── pickup/
│   │   ├── delivery_type_selector.dart
│   │   ├── time_slot_selector.dart
│   │   ├── pickup_code_display.dart
│   │   ├── pickup_status_card.dart
│   │   ├── pickup_map_view.dart
│   │   └── verification_input.dart
│   └── common/
│       └── responsive_wrapper.dart
└── services/
    └── pickup_service.dart
```

---

## 8. Implementation Phases

### Phase 1: Data Layer
- [ ] Update Order model with pickup fields
- [ ] Add PickupTimeSlot model
- [ ] Update Store model
- [ ] Create Firestore indexes

### Phase 2: Customer UI
- [ ] Delivery type toggle component
- [ ] Time slot selector
- [ ] Order creation with pickup
- [ ] Pickup tracking screen

### Phase 3: Store Owner UI
- [ ] Pickup management dashboard
- [ ] Mark ready functionality
- [ ] Verification input (code entry)
- [ ] QR code scanning

### Phase 4: Responsive
- [ ] Mobile layouts
- [ ] Tablet layouts
- [ ] Desktop layouts

---

## 9. UI Components

### Status Badges
| Status | Color | Icon |
|--------|-------|------|
| pending | Orange | `Icons.hourglass_empty` |
| readyForPickup | Blue | `Icons.check_circle` |
| pickedUp | Green | `Icons.done_all` |
| expired | Gray | `Icons.timer_off` |
| cancelled | Red | `Icons.cancel` |

### Design Tokens (from captain_screen.dart)
```dart
const kGold = Color(0xFFF5C542);
const kGreen = Color(0xFF3DBA6F);
const kPurple2 = Color(0xFF7B6FE0);
const kMuted = Color(0xFF7777A0);
const kCard2 = Color(0xFF1A1A28);
const kBorder = Color(0xFF2A2A3E);
```

---

## 10. Key Features Summary

| Feature | Description |
|---------|-------------|
| Toggle | Switch between Delivery and Self-Pickup |
| Time Slots | Select convenient pickup time |
| No Delivery Fee | Save delivery charges for pickup |
| Verification Code | 6-digit code for pickup verification |
| Status Updates | Real-time pickup status |
| Store Dashboard | Manage pickup orders |
| Responsive | Works on all screen sizes |

---

*Plan created: 2026-03-15*
