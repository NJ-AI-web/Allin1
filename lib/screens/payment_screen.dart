// payment_screen.dart — PaymentScreen v5.0
// Wallet Balance + NJ Coins Discount + UPI Apps
// Atomic Firestore transaction for wallet payment

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _bg = Color(0xFF0A0A12);
const Color _surface = Color(0xFF12121E);
const Color _card = Color(0xFF1A1A2A);
const Color _card2 = Color(0xFF222235);
const Color _green = Color(0xFF00C853);
const Color _gold = Color(0xFFFFBB00);
const Color _orange = Color(0xFFFF6B35);
const Color _red = Color(0xFFFF5252);
const Color _text = Color(0xFFEEEEF5);
const Color _muted = Color(0xFF7777A0);
const Color _border = Color(0x1AFFFFFF);

class PaymentScreen extends StatefulWidget {
  final double? amount;
  final String? note;
  final String? rideId;
  final String? rideDocId;
  const PaymentScreen({
    super.key,
    this.amount,
    this.note,
    this.rideId,
    this.rideDocId,
  });
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('amount', amount))
      ..add(StringProperty('note', note))
      ..add(StringProperty('rideId', rideId))
      ..add(StringProperty('rideDocId', rideDocId));
  }
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  double _fare = 0;
  double _walletBal = 0;
  int _verifiedCoins = 0;
  int _coinsToUse = 0;
  bool _useCoins = false;
  bool _payingWallet = false;
  bool _paid = false;

  late AnimationController _successCtrl;
  late Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _fare = widget.amount ?? 45.0;
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );
    _loadWalletBalance();
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return;
      }
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _walletBal =
              (doc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
          _verifiedCoins = (doc.data()?['verified_coins'] as int?) ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Wallet load: $e');
    }
  }

  // Atomic wallet payment
  Future<void> _payWithWallet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    if (_walletBal < _fare) {
      _snack('Insufficient wallet balance!', _red);
      return;
    }
    setState(() => _payingWallet = true);
    try {
      final db = FirebaseFirestore.instance;
      final ref = db.collection('users').doc(uid);
      await db.runTransaction((txn) async {
        final snap = await txn.get(ref);
        final bal = (snap.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
        if (bal < _fare) {
          throw Exception('Insufficient balance');
        }
        txn.update(ref, {
          'walletBalance': bal - _fare,
        });
        if (widget.rideId != null) {
          txn.update(db.collection('rides').doc(widget.rideId), {
            'paymentStatus': 'paid_by_wallet',
          });
        }
        txn.set(db.collection('wallet_transactions').doc(), {
          'userId': uid,
          'type': 'debit',
          'amount': _fare,
          'rideId': widget.rideId ?? widget.rideDocId ?? '',
          'balanceBefore': bal,
          'balanceAfter': bal - _fare,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      setState(() {
        _payingWallet = false;
        _paid = true;
      });
      await _successCtrl.forward();
      _snack(
        'Payment successful! ₹${_fare.toStringAsFixed(0)} paid via Wallet',
        _green,
      );
    } catch (e) {
      setState(() => _payingWallet = false);
      _snack('Payment failed: $e', _red);
    }
  }

  // Atomic coin burn + wallet/UPI combination
  Future<void> _payWithCoinsAndWallet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _coinsToUse <= 0) {
      return;
    }
    final discount = _coinsToUse / 100.0;
    final remaining = (_fare - discount).clamp(0.0, _fare);
    setState(() => _payingWallet = true);
    try {
      final db = FirebaseFirestore.instance;
      final userRef = db.collection('users').doc(uid);
      await db.runTransaction((txn) async {
        final snap = await txn.get(userRef);
        final coins = (snap.data()?['verified_coins'] as int?) ?? 0;
        final bal = (snap.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
        if (coins < _coinsToUse) {
          throw Exception('Insufficient coins');
        }
        txn
          ..update(userRef, {
            'verified_coins': coins - _coinsToUse,
            'walletBalance': bal - remaining < 0 ? 0.0 : bal - remaining,
          })
          ..set(db.collection('coin_transactions').doc(), {
            'userId': uid,
            'type': 'burn',
            'coinsUsed': _coinsToUse,
            'discount': discount,
            'rideId': widget.rideId ?? widget.rideDocId ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
      });
      setState(() {
        _payingWallet = false;
        _paid = true;
      });
      await _successCtrl.forward();
      _snack(
        '$_coinsToUse coins burned! Discount: ₹${discount.toStringAsFixed(2)}. '
        'Pay ₹${remaining.toStringAsFixed(2)} remaining via UPI.',
        _gold,
      );
    } catch (e) {
      setState(() => _payingWallet = false);
      _snack('Coin payment failed: $e', _red);
    }
  }

  Future<void> _launchUpi(String app) async {
    final rideId = widget.rideId ?? widget.rideDocId ?? '';
    final uri = Uri.parse(
      'upi://pay?pa=njtech@oksbi'
      '&pn=Allin1+Super+App'
      '&am=${_fare.toStringAsFixed(2)}'
      '&cu=INR'
      '&tn=${Uri.encodeComponent(widget.note ?? "Ride Payment")}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // After UPI app returns — ask customer if payment succeeded
      if (mounted) await _showPaymentConfirmDialog(rideId);
    } else {
      _snack('$app not installed. Try another UPI app.', _orange);
    }
  }

  Future<void> _showPaymentConfirmDialog(String rideId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Payment Successful?',
          style: TextStyle(color: Color(0xFFEEEEF5),
            fontSize: 17, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Did the UPI payment go through?',
            style: TextStyle(color: Color(0xFF7777A0), fontSize: 13)),
          const SizedBox(height: 8),
          Text('Amount: ₹${_fare.toStringAsFixed(2)}',
            style: const TextStyle(color: Color(0xFFFFBB00),
              fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Failed',
              style: TextStyle(color: Color(0xFFFF5252)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Paid! ✅',
              style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w800))),
        ]));

    if (confirmed == true && rideId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
          .collection('rides').doc(rideId)
          .update({
            'paymentStatus': 'completed',
            'paidAt':        FieldValue.serverTimestamp(),
            'paymentMethod': 'upi',
            'amountPaid':    _fare,
          });
        _snack('Payment recorded! Hero-க்கு notification போச்சு! 🎉', const Color(0xFF00C853));
        setState(() => _paid = true);
        _successCtrl.forward();
      } catch (e) {
        _snack('Payment update failed: $e', const Color(0xFFFF5252));
      }
    } else if (confirmed == false) {
      _snack('Payment failed. Try again or use another app.', const Color(0xFFFF5252));
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 10% BURN LIMIT — CEO strict rule
    final maxDiscount = _fare * 0.10;
    final maxUsableCoins = (maxDiscount * 100).floor();
    final usableCoins = _verifiedCoins.clamp(0, maxUsableCoins);
    final coinDiscount = (_coinsToUse / 100.0).clamp(0.0, maxDiscount);
    final discountedFare = (_fare - coinDiscount).clamp(0.0, _fare);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: _muted),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: GoogleFonts.outfit(
            color: _text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: _paid
          ? _buildSuccessView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Fare card
                  _buildFareCard(discountedFare, coinDiscount),
                  const SizedBox(height: 16),

                  // Wallet card
                  _buildWalletCard(),
                  const SizedBox(height: 12),

                  // NJ Coins discount card
                  _buildCoinsDiscountCard(
                    usableCoins,
                    coinDiscount,
                    discountedFare,
                  ),
                  const SizedBox(height: 16),

                  // UPI section
                  _buildUpiSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildFareCard(double discountedFare, double coinDiscount) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Text('🏍️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.note ?? 'Bike Taxi Ride',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: _text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Allin1 Super App · Erode',
                    style: GoogleFonts.outfit(fontSize: 10, color: _muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (coinDiscount > 0) ...[
                  Text(
                    '₹${_fare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    '₹${discountedFare.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      color: _green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ] else
                  Text(
                    '₹${_fare.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      color: _gold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

  Widget _buildWalletCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _walletBal >= _fare ? const Color(0xFF001A0A) : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _walletBal >= _fare ? _green.withValues(alpha: 0.4) : _border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _walletBal >= _fare
                    ? _green.withValues(alpha: 0.12)
                    : _card2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _walletBal >= _fare ? '💚' : '💳',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allin1 Wallet',
                    style: TextStyle(
                      fontSize: 13,
                      color: _text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Balance: ₹${_walletBal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _walletBal >= _fare ? _green : _muted,
                    ),
                  ),
                ],
              ),
            ),
            if (_walletBal >= _fare)
              GestureDetector(
                onTap: _payingWallet ? null : _payWithWallet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _payingWallet
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pay Now',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              )
            else
              Text(
                'Low balance',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: _red,
                ),
              ),
          ],
        ),
      );

  Widget _buildCoinsDiscountCard(
    int usableCoins,
    double coinDiscount,
    double discountedFare,
  ) {
    if (_verifiedCoins <= 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _useCoins ? const Color(0xFF1A1500) : _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _useCoins ? _gold.withValues(alpha: 0.5) : _border,
          width: _useCoins ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '🪙',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Use NJ Coins',
                      style: TextStyle(
                        fontSize: 13,
                        color: _text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$_verifiedCoins coins = ₹${(_verifiedCoins / 100.0).toStringAsFixed(2)}'
                      ' (max 10% discount)',
                      style: GoogleFonts.outfit(fontSize: 10, color: _muted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useCoins,
                activeThumbColor: _gold,
                onChanged: (v) => setState(() {
                  _useCoins = v;
                  _coinsToUse = v ? usableCoins : 0;
                }),
              ),
            ],
          ),
          if (_useCoins) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Coins: $_coinsToUse',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Discount: -₹${coinDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Slider(
              value: _coinsToUse.toDouble(),
              max: usableCoins.toDouble(),
              divisions: usableCoins.clamp(1, 100),
              activeColor: _gold,
              inactiveColor: _card2,
              onChanged: (v) => setState(() => _coinsToUse = v.round()),
            ),
            GestureDetector(
              onTap: _payingWallet ? null : _payWithCoinsAndWallet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Apply $_coinsToUse Coins → Pay ₹${discountedFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpiSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay with UPI',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final app in [
            {'name': 'GPay', 'emoji': '🟢', 'scheme': 'tez'},
            {'name': 'PhonePe', 'emoji': '🟣', 'scheme': 'phonepe'},
            {'name': 'Any UPI', 'emoji': '💸', 'scheme': 'upi'},
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _launchUpi(app['name']!),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Text(app['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app['name']!,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: _text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '₹${_fare.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: _gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: _muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );

  Widget _buildSuccessView() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _successAnim,
              child: const Text('✅', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: GoogleFonts.outfit(
                fontSize: 22,
                color: _green,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_fare.toStringAsFixed(2)} paid',
              style: GoogleFonts.outfit(fontSize: 14, color: _muted),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Done',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
}
