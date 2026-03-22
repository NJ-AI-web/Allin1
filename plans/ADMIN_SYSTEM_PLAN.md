# Admin Management System - Comprehensive Plan

## Overview
A complete admin panel for the Erode Super App (Kutty Guru AI) to manage captains, stores, rides, and platform analytics.

**State Management:** Provider (as requested)  
**Backend:** Firebase Firestore + Authentication  
**UI Theme:** Match existing `captain_screen.dart` patterns

---

## 1. Admin Authentication & Authorization

### 1.1 Admin Roles
```dart
enum AdminRole {
  superAdmin,      // Full access - can manage other admins
  manager,         // Full access to data, limited admin management
  analyst,         // Read-only access to analytics
  support,         // Can manage captain approvals, no financials
}
```

### 1.2 Admin Model
```dart
class AdminUser {
  String id;
  String email;
  String name;
  AdminRole role;
  List<Permission> permissions;
  DateTime createdAt;
  DateTime lastLogin;
  bool isActive;
  String? assignedRegion; // For regional admins
}

class Permission {
  String module; // captains, stores, rides, analytics, settings
  bool canRead;
  bool canWrite;
  bool canDelete;
  bool canApprove;
}
```

### 1.3 Firestore Structure
```
admins/
  {adminId}/
    email: string
    name: string
    role: string (superAdmin|manager|analyst|support)
    permissions: map
    isActive: boolean
    createdAt: timestamp
    lastLogin: timestamp
    assignedRegion: string?

adminActivityLogs/
  {logId}/
    adminId: string
    action: string
    targetType: string
    targetId: string
    timestamp: timestamp
    details: map
```

### 1.4 Auth Flow
- Login via Firebase Auth (email/password)
- Middleware checks `isActive` flag
- Role-based route guards
- Session timeout: 8 hours

---

## 2. Captain/Store Approval Workflow

### 2.1 Captain Application Model
```dart
class CaptainApplication {
  String id;
  String name;
  String phone;
  String email;
  String vehicleType; // bike, auto, car
  String vehicleNumber;
  String licenseNumber;
  String aadharNumber;
  List<String> documentUrls; // license, RC, insurance
  String? storeId; // If associated with store
  ApplicationStatus status; // pending, underReview, approved, rejected
  String? rejectionReason;
  DateTime appliedAt;
  DateTime? reviewedAt;
  String? reviewedBy;
}
```

### 2.2 Approval Status Indicators
| Status | Color | Icon | Description |
|--------|-------|------|-------------|
| pending | Orange | `Icons.hourglass_empty` | Awaiting review |
| underReview | Blue | `Icons.rate_review` | Being reviewed |
| approved | Green | `Icons.check_circle` | Can start rides |
| rejected | Red | `Icons.cancel` | Application denied |

### 2.3 Review Actions
- **Approve** → Creates captain profile, sends welcome notification
- **Reject** → Requires rejection reason, sends rejection email
- **Request Info** → Asks for additional documents
- **Flag** → Marks for fraud review

---

## 3. Admin Dashboard

### 3.1 Key Metrics Cards
```
┌─────────────────────────────────────────────────────────────────┐
│  PLATFORM OVERVIEW                                              │
├────────────────┬────────────────┬────────────────┬────────────────┤
│  👥 Total Users│  🚗 Active    │  ⏳ Pending    │  ⚠️ Issues    │
│      12,450   │   Captains    │   Approvals    │   Reports     │
│     +15% ↑    │     342       │      23       │       5       │
├────────────────┴────────────────┴────────────────┴────────────────┤
│  EARNINGS                                                        │
├────────────────┬────────────────┬────────────────┬────────────────┤
│  Today        │  This Week    │  This Month    │  All Time     │
│   ₹45,200     │   ₹3,25,000   │   ₹12,50,000   │   ₹85,00,000  │
│   +8% ↑       │   +12% ↑      │   +25% ↑       │               │
├────────────────┴────────────────┴────────────────┴────────────────┤
│  RIDES                                                          │
├────────────────┬────────────────┬────────────────┬────────────────┤
│  Today        │  This Week    │  This Month    │  Cancelled    │
│     1,245     │     8,920     │    35,400      │     2.3%      │
└────────────────┴────────────────┴────────────────┴────────────────┘
```

### 3.2 Charts Required
- **Earnings Line Chart** - Daily/Weekly/Monthly trends
- **Rides Bar Chart** - By service type (Bike, Auto, Car, Parcel)
- **User Growth Chart** - New registrations over time
- **Service Utilization** - Pie chart of ride types
- **Captain Activity** - Online vs idle captains

---

## 4. Store Management

### 4.1 Store Model
```dart
class Store {
  String id;
  String name;
  String ownerName;
  String phone;
  String email;
  String address;
  String area; // Erode area
  StoreCategory category; // food, grocery, tech, pharmacy
  StoreStatus status; // active, inactive, suspended
  List<String> captainIds; // Assigned captains
  double rating;
  int totalOrders;
  double totalEarnings;
  DateTime createdAt;
  Map<String, dynamic> settings; // delivery radius, operating hours
}
```

### 4.2 Store Management Actions
- **Edit Details** - Name, address, category, settings
- **Activate/Deactivate** - Toggle active status
- **View Captains** - List captains assigned to store
- **View Orders** - All orders for this store
- **Financial Summary** - Total earnings, commissions

---

## 5. Credential Management

### 5.1 Admin Actions
- **Create Admin** - SuperAdmin only
- **Edit Admin** - Change role, permissions
- **Deactivate Admin** - Disable access
- **Password Reset** - Send reset email
- **Activity Log** - View all admin actions

### 5.2 Activity Log Model
```dart
class AdminActivityLog {
  String id;
  String adminId;
  String adminName;
  String action; // create, update, delete, approve, reject
  String targetType; // captain, store, admin, ride
  String targetId;
  String targetName;
  Map<String, dynamic> previousValue;
  Map<String, dynamic> newValue;
  String? ipAddress;
  DateTime timestamp;
}
```

---

## 6. Real-Time Tracking

### 6.1 Live Dashboard
- **Active Rides Map** - All ongoing rides on map
- **Captain Locations** - Real-time GPS of online captains
- **Ride Status Board** - List of all active rides

### 6.2 Ride Status Types
| Status | Description |
|--------|-------------|
| searching | Looking for captain |
| captainAssigned | Captain accepted |
| arrived | Captain at pickup |
| inProgress | Ride ongoing |
| completed | Ride finished |
| cancelled | Ride cancelled |

### 6.3 Service Types
- Bike Taxi
- Auto
- Car
- Parcel/Delivery
- Food Delivery
- Grocery
- Pharmacy

---

## 7. Notification System

### 7.1 Admin Notification Types
| Type | Trigger | Priority |
|------|---------|----------|
| newCaptainApplication | New registration | HIGH |
| newStoreApplication | Store registration | HIGH |
| rideCompleted | Ride finished | LOW |
| captainIssue | Reported issue | HIGH |
| paymentIssue | Payment failed | HIGH |
| systemAlert | System error | CRITICAL |

### 7.2 Notification Model
```dart
class AdminNotification {
  String id;
  NotificationType type;
  String title;
  String message;
  String? relatedId; // captainId, storeId, rideId
  Priority priority; // low, medium, high, critical
  bool isRead;
  DateTime createdAt;
  String? actionUrl; // Deep link to relevant page
}
```

---

## 8. File Structure

```
lib/
├── main.dart                      # Add admin routes
├── screens/
│   └── admin/
│       ├── admin_login_screen.dart
│       ├── admin_dashboard_screen.dart
│       ├── admin_shell.dart       # Main layout with nav
│       ├── captains/
│       │   ├── captain_list_screen.dart
│       │   ├── captain_detail_screen.dart
│       │   ├── captain_approval_screen.dart
│       │   └── captain_applications_screen.dart
│       ├── stores/
│       │   ├── store_list_screen.dart
│       │   ├── store_detail_screen.dart
│       │   └── store_approval_screen.dart
│       ├── rides/
│       │   ├── active_rides_screen.dart
│       │   ├── ride_detail_screen.dart
│       │   └── ride_history_screen.dart (admin version)
│       ├── analytics/
│       │   └── analytics_screen.dart
│       ├── settings/
│       │   ├── admin_management_screen.dart
│       │   ├── activity_log_screen.dart
│       │   └── system_settings_screen.dart
│       └── notifications/
│           └── admin_notifications_screen.dart
├── models/
│   ├── admin_user.dart
│   ├── captain_application.dart
│   ├── store.dart
│   ├── admin_notification.dart
│   └── admin_activity_log.dart
├── providers/
│   ├── admin_auth_provider.dart
│   ├── admin_dashboard_provider.dart
│   ├── captain_provider.dart
│   ├── store_provider.dart
│   ├── ride_provider.dart
│   └── notification_provider.dart
├── services/
│   ├── admin_auth_service.dart
│   ├── admin_service.dart
│   └── analytics_service.dart
└── widgets/
    ├── admin/
    │   ├── admin_card.dart
    │   ├── admin_data_table.dart
    │   ├── admin_chart.dart
    │   ├── status_badge.dart
    │   └── admin_sidebar.dart
    └── charts/
        ├── earnings_chart.dart
        ├── rides_chart.dart
        └── growth_chart.dart
```

---

## 9. Responsive Layout

### Desktop/Tablet Layout (>768px)
```
┌────────────────────────────────────────────────────────────────┐
│  [Logo]  Admin Panel          [Notifications] [Profile] [Logout]│
├──────────┬─────────────────────────────────────────────────────┤
│          │                                                      │
│ Dashboard│              MAIN CONTENT AREA                       │
│ ────────│                                                      │
│ Captains│    (Full width cards, data tables, charts)          │
│ Stores  │                                                      │
│ Rides   │                                                      │
│ Analytics│                                                     │
│ ────────│                                                      │
│ Settings│                                                      │
│          │                                                      │
└──────────┴─────────────────────────────────────────────────────┘
     240px                         Flexible
```

### Mobile Layout (<768px)
- Bottom navigation bar
- Full-width cards
- Collapsible sidebar → Drawer

---

## 10. Implementation Priority

### Phase 1: Foundation (Week 1)
- [ ] Admin auth screens
- [ ] Role-based access control
- [ ] Admin shell layout
- [ ] Basic navigation

### Phase 2: Core Management (Week 2)
- [ ] Captain list & approval workflow
- [ ] Store list & management
- [ ] Credential management

### Phase 3: Operations (Week 3)
- [ ] Real-time ride tracking
- [ ] Admin notifications
- [ ] Activity logging

### Phase 4: Analytics (Week 4)
- [ ] Dashboard metrics
- [ ] Charts & visualizations
- [ ] Export functionality

---

## 11. Error Handling & Loading States

### Loading States
- Skeleton loaders for tables
- Circular progress for actions
- Pull-to-refresh for lists

### Error States
- Toast notifications for errors
- Retry buttons for failed requests
- Offline indicator
- Session expired handling

### Validation
- Form validation on all inputs
- Confirm dialogs for destructive actions
- Audit trail for all changes

---

*Plan created: 2026-03-15*
*For implementation, switch to Code mode*
