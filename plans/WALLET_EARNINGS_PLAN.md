# Captain/Driver Wallet & Earnings Feature Plan

## Current State
The captain screen already has:
- Today's earnings display (`_todayEarnings`)
- Today's rides count (`_todayRides`)
- Average rating (`_avgRating`)
- Data loaded from Firestore

## What's Missing - Wallet Screen for Captains

### Required Screens

1. **CaptainWalletScreen** - Main wallet page
   - Display total wallet balance
   - Show today's earnings
   - Show weekly/monthly earnings summary
   - Withdraw button

2. **EarningsHistoryScreen** - Transaction history
   - List of all completed rides with earnings
   - Date-wise grouping
   - Filter by date range

3. **WithdrawScreen** - Withdraw to bank/UPI
   - Add bank account
   - Add UPI ID
   - Withdraw request form
   - Withdrawal history

---

## Feature Requirements

### 1. Wallet Dashboard
```
┌─────────────────────────────────────┐
│  🏍️ Captain Wallet                  │
├─────────────────────────────────────┤
│  Total Balance    │  Today's Earn   │
│  ₹12,450          │  ₹850           │
├─────────────────────────────────────┤
│  [Withdraw]  [Add Bank]  [History] │
├─────────────────────────────────────┤
│  This Week: ₹4,250                   │
│  This Month: ₹28,500                 │
└─────────────────────────────────────┘
```

### 2. Earnings Data Model
```dart
class CaptainWallet {
  String captainId;
  double totalBalance;      // Total available
  double pendingBalance;    // Pending clearance
  double todayEarnings;
  double weekEarnings;
  double monthEarnings;
  DateTime lastUpdated;
  List<BankAccount> bankAccounts;
  List<UpiId> upiIds;
  List<Transaction> transactions;
}

class Transaction {
  String id;
  String rideId;
  double amount;
  DateTime timestamp;
  TransactionType type; // ride_earning, withdrawal, refund
  TransactionStatus status; // pending, completed, failed
}

class BankAccount {
  String id;
  String bankName;
  String accountNumber; // last 4 digits
  String ifscCode;
  bool isVerified;
}

class UpiId {
  String id;
  String upiAddress;
  String provider; // gpay, phonepe, paytm
  bool isVerified;
}
```

### 3. Firestore Structure
```
captains/
  {captainId}/
    wallet/
      balance: number
      pendingBalance: number
      todayEarnings: number
      weekEarnings: number
      monthEarnings: number
      bankAccounts: [subcollection]
      upiIds: [subcollection]
      transactions: [subcollection]
```

---

## Implementation Tasks

### Phase 1: Data Layer
- [ ] Add wallet fields to captain model
- [ ] Create Firestore wallet subcollection
- [ ] Update API service for wallet operations

### Phase 2: Wallet Screen
- [ ] Create `captain_wallet_screen.dart`
- [ ] Display balance, today/week/month earnings
- [ ] Add withdraw button
- [ ] Add transaction history link

### Phase 3: Earnings History
- [ ] Create `earnings_history_screen.dart`
- [ ] List all ride transactions
- [ ] Group by date
- [ ] Add filter by date range

### Phase 4: Withdrawal
- [ ] Create `withdraw_screen.dart`
- [ ] Add bank account form
- [ ] Add UPI ID form
- [ ] Withdrawal request flow
- [ ] Withdrawal history

---

## Files to Create

| File | Purpose |
|------|---------|
| `lib/screens/captain_wallet_screen.dart` | Main wallet dashboard |
| `lib/screens/earnings_history_screen.dart` | Transaction history |
| `lib/screens/withdraw_screen.dart` | Withdraw to bank/UPI |
| `lib/models/wallet_models.dart` | Data models |
| `lib/services/wallet_service.dart` | Wallet operations API |

---

## Integration Points

1. **Captain Screen** → Add "Wallet" button that opens CaptainWalletScreen
2. **Ride Completion** → Update captain's wallet balance in Firestore
3. **Dashboard** → Link wallet to main app wallet

---

*Plan created: 2026-03-15*
