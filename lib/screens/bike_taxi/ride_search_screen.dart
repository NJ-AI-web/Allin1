// ================================================================
// RideSearchScreen v3.0 — REAL Firestore (No Dummy Data!)
// Writes ride to Firestore, listens for Captain acceptance
// ================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/ride_model.dart';
import '../../widgets/allin1_map_widget.dart';
import 'ride_tracking_screen.dart';

class RideSearchScreen extends StatefulWidget {
  final RideModel ride;
  const RideSearchScreen({required this.ride, super.key});

  @override
  State<RideSearchScreen> createState() => _RideSearchScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RideModel>('ride', ride));
  }
}

class _RideSearchScreenState extends State<RideSearchScreen>
    with TickerProviderStateMixin {
  // ── Theme ────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF0A0A12);
  static const Color _card = Color(0xFF1A1A2A);
  static const Color _accent = Color(0xFFFF6B35);
  static const Color _gold = Color(0xFFFFBB00);
  static const Color _green = Color(0xFF00C853);
  static const Color _text = Color(0xFFEEEEF5);
  static const Color _muted = Color(0xFF7777A0);
  static const Color _border = Color(0x1AFFFFFF);

  // ── Animation controllers ─────────────────────────────────────
  late AnimationController _radarCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _foundCtrl;
  late Animation<double> _radarAnim;
  late Animation<double> _foundFadeAnim;
  late Animation<Offset> _foundSlideAnim;

  // ── State ─────────────────────────────────────────────────────
  bool _captainFound = false;
  bool _cancelled = false;
  int _searchSeconds = 0;
  String _rideDocId = '';
  Timer? _pingTimer; // 15-second per-hero ping countdown
  int _pingSeconds = 15; // Countdown display
  Timer? _countTimer;
  StreamSubscription<DocumentSnapshot>? _subscription;

  // ── Captain info from Firestore ───────────────────────────────
  String _captainName = '';
  String _captainBike = '';
  String _captainPhone = '';
  String _captainModel = '';
  double _captainRating = 0;
  int _captainTrips = 0;
  int _captainEta = 5;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _writeRideToFirestore();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _pulseCtrl.dispose();
    _foundCtrl.dispose();
    _countTimer?.cancel();
    _pingTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _initAnimations() {
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _foundCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _radarAnim = Tween<double>(begin: 0, end: 1).animate(_radarCtrl);
    // _pulseAnim removed as unused
    _foundFadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _foundCtrl, curve: Curves.easeOut));
    _foundSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _foundCtrl, curve: Curves.easeOutCubic));
  }

  // STEP 1: Write ride to Firestore
  Future<void> _writeRideToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('RIDE WRITE FAILED: not authenticated');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Looking for nearest Hero Riders...',
              style:
                  GoogleFonts.notoSansTamil(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      return;
    }
    try {
      debugPrint('Writing ride for: ${user.uid}');
      final doc = await FirebaseFirestore.instance.collection('rides').add({
        'pickup': widget.ride.pickupAddress ?? '',
        'drop': widget.ride.dropAddress ?? '',
        'distanceKm': widget.ride.distanceKm ?? 0,
        'fare': widget.ride.estimatedFare ?? 0,
        'status': 'searching',
        'customerId': user.uid,
        'customerPhone': user.phoneNumber ?? user.email ?? '',
        'customerName': user.displayName ?? 'Customer',
        'createdAt': FieldValue.serverTimestamp(),
        'captainId': null,
        'captainName': null,
        'captainPhone': null,
        'captainBike': null,
        'captainModel': null,
        'captainRating': null,
        'captainEta': null,
        'pickupLat': widget.ride.pickupLatitude ?? 11.3410,
        'pickupLng': widget.ride.pickupLongitude ?? 77.7172,
        'dropLat': widget.ride.dropLatitude ?? 11.3520,
        'dropLng': widget.ride.dropLongitude ?? 77.7280,
        'paymentStatus': 'pending',
      });
      debugPrint('Ride written! ID: ${doc.id}');
      if (mounted) {
        setState(() => _rideDocId = doc.id);
      }
      _startCountTimer();
      _listenForCaptain(doc.id);
    } catch (e) {
      debugPrint('Firestore FAILED: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking failed: $e',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            backgroundColor: const Color(0xFFFF5252),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
        await Future<void>.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  void _startCountTimer() {
    _countTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _searchSeconds++);
      }
    });
  }

  // ── STEP 2: Listen for Captain acceptance with 15s ping timeout ──
  void _listenForCaptain(String rideId) {
    _subscription = FirebaseFirestore.instance
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .listen((snap) {
      if (!mounted || !snap.exists) {
        return;
      }
      final data = snap.data()!;
      final status = data['status'] as String? ?? 'searching';

      if (status == 'accepted' && !_captainFound) {
        _countTimer?.cancel();
        _pingTimer?.cancel();
        _radarCtrl.stop();
        _foundCtrl.forward();
        if (mounted) {
          setState(() {
            _captainFound = true;
            _captainName = data['captainName'] as String? ?? 'Hero Rider';
            _captainPhone = data['captainPhone'] as String? ?? '';
            _captainBike = data['captainBike'] as String? ?? '';
            _captainModel = data['captainModel'] as String? ?? 'Bike';
            _captainRating = (data['captainRating'] as num?)?.toDouble() ?? 4.5;
            _captainTrips = (data['captainTrips'] as int?) ?? 0;
            _captainEta = (data['captainEta'] as int?) ?? 5;
          });
        }
      }

      if (status == 'cancelled_by_captain') {
        if (mounted) {
          _showCancelledSnack('Hero cancelled. Searching next nearest...');
        }
        _pingNextHero(rideId); // Ping-pong: try next hero
      }
    });

    // 15-second ping timeout — if no hero accepts, mark as timeout
    _startPingTimer(rideId);
  }

  // 15-second countdown per hero ping
  void _startPingTimer(String rideId) {
    _pingSeconds = 15;
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _pingSeconds--);
      if (_pingSeconds <= 0) {
        t.cancel();
        if (!_captainFound) {
          debugPrint('15s timeout — pinging next nearest hero');
          _pingNextHero(rideId);
        }
      }
    });
  }

  // Ping-pong: reset ride to 'searching' after timeout/rejection
  Future<void> _pingNextHero(String rideId) async {
    if (_captainFound || _cancelled) {
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status': 'searching',
        'captainId': null,
        'captainName': null,
        'pingAttempts': FieldValue.increment(1),
        'lastPingAt': FieldValue.serverTimestamp(),
      });
      // Reset ping timer for next hero
      setState(() => _pingSeconds = 15);
      _startPingTimer(rideId);
      debugPrint('Ride reset to searching — ping attempt incremented');
    } catch (e) {
      debugPrint('Ping next hero error: $e');
    }
  }

  // ── Cancel Ride ───────────────────────────────────────────────
  Future<void> _cancelRide() async {
    setState(() => _cancelled = true);
    unawaited(_subscription?.cancel());
    _countTimer?.cancel();
    if (_rideDocId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(_rideDocId)
          .update({'status': 'cancelled'});
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showCancelledSnack(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFE05555),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Call Captain ──────────────────────────────────────────────
  Future<void> _callCaptain() async {
    if (_captainPhone.isEmpty) {
      return;
    }
    final uri = Uri.parse('tel:$_captainPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── Navigate to tracking ──────────────────────────────────────
  void _trackRide() {
    final ride = widget.ride
      ..captainName = _captainName
      ..captainBikeNumber = _captainBike
      ..captainPhone = _captainPhone
      ..captainRating = _captainRating
      ..status = 'arriving';
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, anim, __) =>
            RideTrackingScreen(ride: ride, rideDocId: _rideDocId),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _captainFound ? _buildFoundView() : _buildSearchingView(),
      ),
    );
  }

  // ── SEARCHING VIEW ────────────────────────────────────────────
  Widget _buildSearchingView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              const Text(
                'Finding Hero...',
                style: TextStyle(
                  fontSize: 18,
                  color: _text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _cancelRide,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFFF5252)),
                ),
              ),
            ],
          ),
        ),

        // Map
        Expanded(
          flex: 2,
          child: Allin1MapWidget(
            center: LatLng(
              widget.ride.pickupLatitude ?? 11.3410,
              widget.ride.pickupLongitude ?? 77.7172,
            ),
            zoom: 13,
            markers: [
              MapMarker(
                point: LatLng(
                  widget.ride.pickupLatitude ?? 11.3410,
                  widget.ride.pickupLongitude ?? 77.7172,
                ),
                label: 'You',
              ),
            ],
            interactive: false,
          ),
        ),

        // Radar animation + status
        Expanded(
          flex: 3,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Radar
                AnimatedBuilder(
                  animation: _radarAnim,
                  builder: (_, __) => SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: _RadarPainter(_radarAnim.value),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2A),
                            shape: BoxShape.circle,
                            border: Border.all(color: _accent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🏍️',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Finding Nearby Hero',
                  style: TextStyle(
                    fontSize: 18,
                    color: _text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Looking near Erode... (${_searchSeconds}s)',
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
                if (_rideDocId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1A00C853),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x3300C853)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Live on Firestore',
                          style: TextStyle(
                            fontSize: 10,
                            color: _green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Route info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _routeRow('🔴', widget.ride.pickupAddress ?? ''),
              const SizedBox(height: 8),
              _routeRow('🟢', widget.ride.dropAddress ?? ''),
              const Divider(color: Color(0x1AFFFFFF), height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Fare',
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
                  Text(
                    '₹${widget.ride.estimatedFare?.round() ?? 0}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: _gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeRow(String dot, String text) => Row(
        children: [
          Text(dot, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: _text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  // ── FOUND VIEW ────────────────────────────────────────────────
  Widget _buildFoundView() {
    return FadeTransition(
      opacity: _foundFadeAnim,
      child: SlideTransition(
        position: _foundSlideAnim,
        child: Column(
          children: [
            // Success header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x1A00C853),
                border: Border.all(color: const Color(0x2200C853)),
              ),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  const Text(
                    'Hero is on the way!',
                    style: TextStyle(
                      fontSize: 20,
                      color: _text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: _green),
                      const SizedBox(width: 4),
                      Text(
                        'Arriving in $_captainEta mins',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Captain card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFFFF6B35)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            _captainName.isNotEmpty
                                ? _captainName[0].toUpperCase()
                                : 'H',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _captainName.isNotEmpty
                                  ? _captainName
                                  : 'Hero Rider',
                              style: const TextStyle(
                                fontSize: 16,
                                color: _text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: _gold),
                                const SizedBox(width: 3),
                                Text(
                                  _captainRating > 0
                                      ? _captainRating.toStringAsFixed(1)
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_captainTrips > 0) ...[
                                  const Text(
                                    ' · ',
                                    style: TextStyle(color: _muted),
                                  ),
                                  Text(
                                    '$_captainTrips trips',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFBB00),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x33FFBB00)),
                        ),
                        child: Center(
                          child: Text(
                            '$_captainEta',
                            style: const TextStyle(
                              fontSize: 16,
                              color: _gold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'min',
                        style: TextStyle(fontSize: 9, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0x1AFFFFFF)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler, size: 16, color: _muted),
                      const SizedBox(width: 8),
                      Text(
                        _captainBike.isNotEmpty
                            ? _captainBike
                            : 'Vehicle details',
                        style: const TextStyle(fontSize: 13, color: _text),
                      ),
                      const Spacer(),
                      Text(
                        _captainModel.isNotEmpty ? _captainModel : '',
                        style: const TextStyle(fontSize: 11, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Call + Chat buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _callCaptain,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0x1A00C853),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x3300C853),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, size: 16, color: _green),
                                SizedBox(width: 8),
                                Text(
                                  'Call',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0x1A6C63FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x336C63FF),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: Color(0xFF9B8FF0),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Chat',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9B8FF0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Track My Ride button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: GestureDetector(
                onTap: _trackRide,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_accent, Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Track My Ride',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
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

// ── Radar Painter ─────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    for (int i = 1; i <= 3; i++) {
      final r = maxR * i / 3;
      final opacity = (1 - progress) * 0.3 * (1 - i / 4);
      if (opacity <= 0) {
        continue;
      }
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = const Color(0xFFFF6B35).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    final sweepR = maxR * progress;
    if (sweepR > 0) {
      canvas.drawCircle(
        center,
        sweepR,
        Paint()
          ..color = const Color(0xFFFF6B35).withValues(
            alpha: (1 - progress) * 0.5,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}
