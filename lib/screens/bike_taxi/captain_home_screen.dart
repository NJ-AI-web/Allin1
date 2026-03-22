// ================================================================
// CaptainHomeScreen v2.0 — REAL Firebase (No Dummy Data!)
// Hero receives rides from Firestore in real-time
// ================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/location_service.dart';

class CaptainHomeScreen extends StatefulWidget {
  const CaptainHomeScreen({super.key});
  @override
  State<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends State<CaptainHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // ── Theme ────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF0A0A12);
  static const Color _surface = Color(0xFF12121E);
  static const Color _card = Color(0xFF1A1A2A);
  static const Color _green = Color(0xFF00C853);
  static const Color _gold = Color(0xFFFFBB00);
  static const Color _red = Color(0xFFFF5252);
  static const Color _purple = Color(0xFF6C63FF);
  static const Color _text = Color(0xFFEEEEF5);
  static const Color _muted = Color(0xFF7777A0);
  static const Color _border = Color(0x1AFFFFFF);

  // ── State ────────────────────────────────────────────────────
  bool _isOnline = false;
  bool _accepting = false;
  String _activeRideId = '';

  // Commission + Hero Coins state
  double _commissionRate = 0.10;
  bool _waiverShown = false;
  bool _waiverCompleted = false;
  int _heroCoins = 0;
  bool _firstLoginToday = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Captain profile from Firebase Auth
  User? _user;
  String get _captainName =>
      _user?.displayName ?? _user?.email?.split('@').first ?? 'Hero Rider';
  String get _avatarLetter =>
      _captainName.isNotEmpty ? _captainName[0].toUpperCase() : 'H';

  // Stream subscriptions
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rideUpdateSub;
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    WidgetsBinding.instance.addObserver(this);
    _checkActiveRide();
    _loadHeroData();

    // Listen for pending rides
    _rideUpdateSub = FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'searching')
        .snapshots()
        .listen((snap) {
      if (mounted) {
        // This state variable is not defined in the original code,
        // assuming it's meant to update the list of pending rides.
        // For now, just logging to avoid error.
        // setState(() => _pendingRides = snap.docs);
        debugPrint('Pending rides updated: ${snap.docs.length}');
      }
    });
  }

  @override
  // AppLifecycleState — keep online when app backgrounded
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isOnline || _user == null) {
      return;
    }
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        // App backgrounded — DO NOT go offline!
        // Only explicit Go Offline button changes status
        debugPrint('Hero: backgrounded — staying ONLINE');
        break;
      case AppLifecycleState.resumed:
        debugPrint('Hero: resumed — reconfirming ONLINE');
        _syncOnlineStatus(true);
        break;
      case AppLifecycleState.detached:
        _syncOnlineStatus(false);
        break;
    }
  }

// ── Commission Waiver Banner + Hero Coins snippets ──

  Future<void> _loadHeroData() async {
    if (_user == null) {
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('captains')
          .doc(_user!.uid)
          .get();
      final data = doc.data() ?? {};

      // Commission rate — default 10%, reduced to 5% after task
      final double rate =
          (data['active_commission_rate'] as num?)?.toDouble() ?? 0.10;

      // Hero coins
      final int coins = (data['hero_coins'] as int?) ?? 0;

      // Check if first login today
      final DateTime? lastLogin =
          (data['last_login_date'] as Timestamp?)?.toDate();
      final DateTime today = DateTime.now();
      final bool isFirstToday = lastLogin == null ||
          lastLogin.day != today.day ||
          lastLogin.month != today.month ||
          lastLogin.year != today.year;

      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _commissionRate = rate;
          _heroCoins = coins;
          _firstLoginToday = isFirstToday;
          _waiverCompleted = rate < 0.10;
        });
      }

      // Update last login date
      if (isFirstToday) {
        await FirebaseFirestore.instance
            .collection('captains')
            .doc(_user!.uid)
            .set(
          {'last_login_date': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Hero data load error: $e');
    }
  }

  Future<void> _launchCommissionWaiverTask() async {
    if (_user == null) {
      return;
    }
    final String trackUrl =
        'https://earnkaro.com/offer/featured?subid1=HERO_${_user!.uid}&subid2=commission_waiver';
    final Uri uri = Uri.parse(trackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Record initiated — Admin verifies & updates commission
      await FirebaseFirestore.instance.collection('coin_transactions').add({
        'userId': _user!.uid,
        'taskId': 'commission_waiver',
        'taskName': 'Commission Waiver Task',
        'coins': 0,
        'status': 'initiated',
        'source': 'hero_cpa',
        'subId': 'HERO_${_user!.uid}',
        'type': 'commission_waiver',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() => _waiverShown = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task started! Admin verifies → commission 5% ஆகும்.',
              style: GoogleFonts.notoSansTamil(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // Sync captain online status to Firestore
  Future<void> _syncOnlineStatus(bool online) async {
    if (_user == null) {
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('captains')
          .doc(_user!.uid)
          .set(
        {
          'status': online ? 'online' : 'offline',
          'lastSeen': FieldValue.serverTimestamp(),
          'captainName': _captainName,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Sync status error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _rideUpdateSub?.cancel();
    _stopLocationUpdates();
    super.dispose();
  }

  // Check if captain has an active ride already
  Future<void> _checkActiveRide() async {
    if (_user == null) {
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('rides')
          .where('captainId', isEqualTo: _user!.uid)
          .where('status', whereIn: ['accepted', 'arriving', 'in_progress'])
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty && mounted) {
        final doc = snap.docs.first;
        setState(() {
          _activeRideId = doc.id;
          _isOnline = true;
        });
        _startLocationUpdates(doc.id);
      }
    } catch (_) {}
  }

  // Accept a ride from Firestore — DISPATCH v2.0
  Future<void> _acceptRide(String rideId, Map<String, dynamic> rideData) async {
    setState(() => _accepting = true);
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch()
        ..update(db.collection('rides').doc(rideId), {
          'status': 'accepted',
          'captainId': _user?.uid ?? 'hero_001',
          'captainName': _captainName,
          'captainPhone': _user?.phoneNumber ?? _user?.email ?? '',
          'captainBike': '',
          'captainModel': 'Bike',
          'captainRating': 4.8,
          'captainTrips': 0,
          'captainEta': 5,
          'acceptedAt': FieldValue.serverTimestamp(),
        })
        ..set(
          db.collection('captains').doc(_user!.uid),
          {
            'status': 'on_ride',
            'activeRideId': rideId,
            'lastUpdated': FieldValue.serverTimestamp(),
            'captainName': _captainName,
          },
          SetOptions(merge: true),
        );

      await batch.commit();
      debugPrint('Hero status: on_ride — ghosted from new pings');

      setState(() {
        _activeRideId = rideId;
        _accepting = false;
      });
      _startLocationUpdates(rideId);
    } catch (e) {
      setState(() => _accepting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Complete a ride — revert Hero to 'online'
  Future<void> _completeRide() async {
    if (_activeRideId.isEmpty) {
      return;
    }
    final db = FirebaseFirestore.instance;
    final batch = db.batch()
      ..update(db.collection('rides').doc(_activeRideId), {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

    // 2. Revert Hero status to 'online' — back in dispatch pool!
    if (_user != null) {
      batch.set(
        db.collection('captains').doc(_user!.uid),
        {
          'status': 'online',
          'activeRideId': null,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    debugPrint('Hero status: online — back in dispatch pool');

    setState(() {
      _activeRideId = '';
    });
    _stopLocationUpdates();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ride completed! Collect payment from customer.',
            style: GoogleFonts.notoSansTamil(color: Colors.white),
          ),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // Call customer
  Future<void> _callCustomer(String phone) async {
    if (phone.isEmpty) {
      return;
    }
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── LOCATION TRACKING ─────────────────────────────────────────
  void _startLocationUpdates(String rideId) {
    _stopLocationUpdates();
    _locationSubscription = LocationService().getLocationStream().listen(
      (position) {
        FirebaseFirestore.instance.collection('rides').doc(rideId).update({
          'captainLat': position.latitude,
          'captainLng': position.longitude,
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });
      },
      onError: (Object e) => debugPrint('Location update error: $e'),
    );
    debugPrint('Location tracking STARTED for ride: $rideId');
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint('Location tracking STOPPED');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isOnline) ...[
              _buildStatsRow(),
              _buildCommissionBanner(),
              _buildHeroCoinsTile(),
              if (_activeRideId.isNotEmpty) ...[
                _buildActiveRideCard(),
              ] else
                Expanded(child: _buildRideStream()),
            ] else
              Expanded(child: _buildOfflineView()),
          ],
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFBB00), Color(0xFFFF6B35)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _avatarLetter,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _captainName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Allin1 Hero · Erode',
                  style: TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
          // Online toggle
          GestureDetector(
            onTap: () {
              setState(() => _isOnline = !_isOnline);
              _syncOnlineStatus(_isOnline);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isOnline
                    ? const Color(0x1A00C853)
                    : const Color(0x1AFF5252),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isOnline
                      ? const Color(0x4D00C853)
                      : const Color(0x4DFF5252),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isOnline ? _green : _red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 10,
                      color: _isOnline ? _green : _red,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS ROW ─────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('rides')
          .where('captainId', isEqualTo: _user?.uid ?? '')
          .where('status', isEqualTo: 'completed')
          .get(),
      builder: (context, snap) {
        final int rides = snap.data?.docs.length ?? 0;
        double earn = 0;
        if (snap.hasData) {
          for (final d in snap.data!.docs) {
            earn += ((d.data()! as Map<String, dynamic>)['fare'] as num? ?? 0)
                .toDouble();
          }
        }
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x22FFBB00)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _stat('🏍️', 'Rides', '$rides', _purple),
                        _vline(),
                        _stat('💰', 'Earned', '₹${earn.toInt()}', _gold),
                        _vline(),
                        _stat('⭐', 'Rating', '4.8', _green),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: _border, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Service Quality',
                    style: TextStyle(fontSize: 11, color: _muted),
                  ),
                  _buildCommissionBadge(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String e, String l, String v, Color c) => Expanded(
        child: Column(
          children: [
            Text(e, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              v,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c,
              ),
            ),
            Text(l, style: const TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
      );

  Widget _vline() => Container(
        width: 1,
        height: 36,
        color: _border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  // ── PENDING RIDES STREAM ──────────────────────────────────────
  Widget _buildRideStream() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const Text('🔔', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              const Text(
                'PENDING RIDES — LIVE',
                style: TextStyle(
                  fontSize: 10,
                  color: _muted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 9,
                  color: _green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // DISPATCH RULE: Only 'online' heroes see ride pings
        Expanded(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('captains')
                .doc(_user?.uid ?? 'none')
                .snapshots(),
            builder: (context, heroSnap) {
              final Map<String, dynamic>? heroData = heroSnap.data?.data();
              final String heroStatus =
                  heroData?['status'] as String? ?? 'online';
              if (heroStatus == 'on_ride') {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🚦', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'On-Ride Mode',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: _text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Complete current ride — then new rides varum!',
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 12,
                            color: _muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rides')
                    .where('status', isEqualTo: 'searching')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _gold),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snap.error}',
                        style: const TextStyle(color: _red, fontSize: 12),
                      ),
                    );
                  }
                  final List<QueryDocumentSnapshot> docs =
                      snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🛵', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text(
                            'No pending rides',
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Customers book pannumpothe inghe varum!',
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 12,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data()! as Map<String, dynamic>;
                      return _PendingRideCard(
                        rideId: doc.id,
                        data: data,
                        accepting: _accepting,
                        onAccept: () => _acceptRide(doc.id, data),
                        onCall: () => _callCustomer(
                          data['customerPhone'] as String? ?? '',
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── ACTIVE RIDE CARD ──────────────────────────────────────────
  Widget _buildActiveRideCard() {
    if (_activeRideId.isEmpty) {
      return const SizedBox.shrink();
    }

    // StreamBuilder to listen to payment status changes
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rides')
          .doc(_activeRideId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final rideDoc = snapshot.data!;
        final rideData = rideDoc.data() as Map<String, dynamic>? ?? {};
        final paymentStatus = rideData['paymentStatus'] as String? ?? '';

        // Check if payment is completed - show success dialog
        if (paymentStatus == 'completed' || paymentStatus == 'paid') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: _surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: _green, width: 2),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _green.withValues(alpha: 0.2),
                            border: Border.all(color: _green, width: 3),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 50,
                            color: _green,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '💚 Payment Received!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _green,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The customer has completed the payment successfully.',
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 14,
                            color: _muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            child: const Text(
                              'Awesome! 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          });
        }

        final int fare = (rideData['fare'] as num?)?.toInt() ?? 0;
        final String pickup = rideData['pickup'] as String? ?? '';
        final String drop = rideData['drop'] as String? ?? '';
        final String phone = rideData['customerPhone'] as String? ?? '';
        final String cname = rideData['customerName'] as String? ?? 'Customer';

        return Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x1A00C853),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x3300C853)),
                  ),
                  child: Column(
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'Ride Accepted!',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Go pick up $cname',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Route card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      _rRow('🔴', 'Pickup', pickup),
                      const SizedBox(height: 12),
                      _rRow('🟢', 'Drop', drop),
                      const Divider(color: Color(0x1AFFFFFF), height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Collect from Customer:',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                          Text(
                            '₹$fare',
                            style: const TextStyle(
                              fontSize: 22,
                              color: _gold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Call customer
                if (phone.isNotEmpty)
                  GestureDetector(
                    onTap: () => _callCustomer(phone),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0x1A00C853),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x3300C853)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 18, color: _green),
                          SizedBox(width: 8),
                          Text(
                            'Call Customer',
                            style: TextStyle(
                              fontSize: 14,
                              color: _green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),

                // Complete ride
                GestureDetector(
                  onTap: _completeRide,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_green, Color(0xFF009624)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mark Ride Complete ✅',
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rRow(String dot, String lbl, String txt) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dot, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lbl,
                  style: const TextStyle(
                    fontSize: 9,
                    color: _muted,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  txt,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  // ── OFFLINE VIEW ──────────────────────────────────────────────
  // ── Commission Waiver Banner Widget ──────────────────────────
  Widget _buildCommissionBanner() {
    // Show only on first login AND waiver not completed
    if (!_firstLoginToday || _waiverCompleted || _waiverShown) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1500), Color(0xFF0F1A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFBB00).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFBB00).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFBB00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFFFBB00).withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Commission 10% → 5%!',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: const Color(0xFFFFBB00),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'TODAY ONLY',
                        style: TextStyle(
                          fontSize: 7,
                          color: Color(0xFFFF5252),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete one quick sponsored task to reduce your commission!',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 10,
                    color: const Color(0xFF7777A0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _launchCommissionWaiverTask,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBB00),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'Go!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Coins Tile ──────────────────────────────────────────
  Widget _buildHeroCoinsTile() {
    final double rupeesValue = _heroCoins / 100.0; // 100 coins = Rs.1
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hero Coins coming soon! Abhi $_heroCoins coins = Rs.${rupeesValue.toStringAsFixed(2)}',
              style: GoogleFonts.notoSansTamil(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF6C63FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF10102A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hero Coins: $_heroCoins',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFEEEEF5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Waiting for a ride? Earn coins & offset commission!',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 10,
                      color: const Color(0xFF7777A0),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '= Rs.${rupeesValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Earn more →',
                  style: TextStyle(fontSize: 9, color: Color(0xFF7777A0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Commission Rate Badge ──────────────────────────────────
  Widget _buildCommissionBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _commissionRate < 0.10
              ? const Color(0xFF00C853).withValues(alpha: 0.12)
              : const Color(0xFF1A1A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _commissionRate < 0.10
                ? const Color(0xFF00C853).withValues(alpha: 0.4)
                : const Color(0x1AFFFFFF),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _commissionRate < 0.10
                  ? Icons.trending_down_rounded
                  : Icons.percent_rounded,
              size: 12,
              color: _commissionRate < 0.10
                  ? const Color(0xFF00C853)
                  : const Color(0xFF7777A0),
            ),
            const SizedBox(width: 4),
            Text(
              '${(_commissionRate * 100).toInt()}% Fee',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _commissionRate < 0.10
                    ? const Color(0xFF00C853)
                    : const Color(0xFF7777A0),
              ),
            ),
          ],
        ),
      );

  Widget _buildOfflineView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😴', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              'நீங்கள் Offline-ல இருக்கீங்க',
              style: GoogleFonts.notoSansTamil(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ride accept பண்ண Online பண்ணுங்க!',
              style: GoogleFonts.notoSansTamil(
                fontSize: 13,
                color: _muted,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                // The user's snippet had `(Timestamp ts) { if (mounted) { setState(() => _selectedDay = ts); } }`
                // This is incorrect as onTap expects a `VoidCallback`.
                // Reverting to original logic for onTap.
                setState(() => _isOnline = true);
                _syncOnlineStatus(true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_green, Color(0xFF009624)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Go Online 🟢',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PENDING RIDE CARD WIDGET
// ================================================================
class _PendingRideCard extends StatelessWidget {
  final String rideId;
  final Map<String, dynamic> data;
  final bool accepting;
  final VoidCallback onAccept;
  final VoidCallback onCall;
  const _PendingRideCard({
    required this.rideId,
    required this.data,
    required this.accepting,
    required this.onAccept,
    required this.onCall,
  });

  String _ago(Object? ts) {
    if (ts == null) {
      return 'just now';
    }
    try {
      final dt = (ts as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) {
        return '${diff.inSeconds}s ago';
      }
      return '${diff.inMinutes}m ago';
    } catch (_) {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fare = (data['fare'] as num?)?.toInt() ?? 0;
    final dist = (data['distanceKm'] as num?)?.toStringAsFixed(1) ?? '?';
    final pickup = data['pickup'] as String? ?? '';
    final drop = data['drop'] as String? ?? '';
    final cname = data['customerName'] as String? ?? 'Customer';
    final ts = data['createdAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x44FFBB00),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22FFBB00),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x22FFBB00),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0x44FFBB00)),
                  ),
                  child: const Center(
                    child: Text('🏍️', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cname,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFEEEEF5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _ago(ts),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7777A0),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$fare',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFBB00),
                      ),
                    ),
                    Text(
                      '$dist km',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7777A0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _loc('🔴', pickup),
            const SizedBox(height: 6),
            _loc('🟢', drop),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: onCall,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0x1A00C853),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x3300C853)),
                    ),
                    child: const Icon(
                      Icons.phone,
                      size: 18,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: accepting ? null : onAccept,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFBB00), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x44FFBB00),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: accepting
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Accept Ride →',
                                  style: GoogleFonts.notoSansTamil(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loc(String dot, String txt) => Row(
        children: [
          Text(dot, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              txt,
              style: const TextStyle(fontSize: 12, color: Color(0xFFEEEEF5)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('rideId', rideId))
      ..add(DiagnosticsProperty<Map<String, dynamic>>('data', data))
      ..add(DiagnosticsProperty<bool>('accepting', accepting))
      ..add(ObjectFlagProperty<VoidCallback>.has('onAccept', onAccept))
      ..add(ObjectFlagProperty<VoidCallback>.has('onCall', onCall));
  }
}
