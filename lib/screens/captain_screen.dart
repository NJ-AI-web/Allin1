// ================================================================
// CaptainScreen — Erode Super App v1.0
// Real-time Firestore StreamBuilder for NJ TECH Captains
// ================================================================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

const Color kBg      = Color(0xFF08080F);
const Color kSurface = Color(0xFF0D0D18);
const Color kCard    = Color(0xFF141420);
const Color kCard2   = Color(0xFF1A1A28);
const Color kPurple  = Color(0xFF7B6FE0);
const Color kPurple2 = Color(0xFF9B8FF0);
const Color kOrange  = Color(0xFFE07C6F);
const Color kGreen   = Color(0xFF3DBA6F);
const Color kGold    = Color(0xFFF5C542);
const Color kRed     = Color(0xFFE05555);
const Color kText    = Color(0xFFEEEEF5);
const Color kMuted   = Color(0xFF7777A0);
const Color kBorder  = Color(0x267B6FE0);

class CaptainScreen extends StatefulWidget {
  final VoidCallback? onExitCaptain;
  const CaptainScreen({super.key, this.onExitCaptain});

  @override
  State<CaptainScreen> createState() => _CaptainScreenState();
}

class _CaptainScreenState extends State<CaptainScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  bool   _isOnline      = true;
  int    _todayRides    = 0;
  double _todayEarnings = 0;
  double _avgRating     = 0;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadTodayStats();
  }

  @override
  void dispose() { 
    _pulseCtrl.dispose(); 
    _locationTimer?.cancel();
    super.dispose(); 
  }

  Future<void> _loadTodayStats() async {
    try {
      final today    = DateTime.now();
      final startDay = DateTime(today.year, today.month, today.day);
      final snap = await FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'completed')
        .where('acceptedAt', isGreaterThan: Timestamp.fromDate(startDay))
        .get();
      double total = 0;
      double ratingSum = 0;
      int ratingCount = 0;
      for (final doc in snap.docs) {
        total += (doc['fare'] as num?)?.toDouble() ?? 0;
        final d = doc.data();
        final rating = d.containsKey('customerRating') ? (d['customerRating'] as num?)?.toInt() ?? 0 : 0;
        if (rating > 0) {
          ratingSum += rating;
          ratingCount++;
        }
      }
      if (mounted) setState(() {
        _todayRides    = snap.docs.length;
        _todayEarnings = total;
        _avgRating = ratingCount > 0 ? ratingSum / ratingCount : 5.0;
      });
    } catch (_) {}
  }

  void _startLocationUpdates(String rideId) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition();
        await FirebaseFirestore.instance
          .collection('rides').doc(rideId)
          .update({'captainLat': pos.latitude, 'captainLng': pos.longitude});
      } catch (e) {
        debugPrint('Location update error: $e');
      }
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _acceptRide(String rideId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status':       'accepted',
        'captainId':    'captain_nizam_001',
        'captainName':  'Nizam (NJ TECH)',
        'captainPhone': '8681869091',
        'acceptedAt':   FieldValue.serverTimestamp(),
        'eta':          '5 minutes',
      });
      _startLocationUpdates(rideId);
      if (!mounted) return;
      _showAcceptedSheet(rideId, data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _completeRide(String rideId) async {
    await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
      'status':      'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
    _stopLocationUpdates();
    await _loadTodayStats();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ride completed! ✅',
        style: GoogleFonts.notoSansTamil(color: Colors.white)),
      backgroundColor: kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showAcceptedSheet(String rideId, Map<String, dynamic> data) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AcceptedSheet(
        rideId: rideId, data: data,
        onComplete: () { Navigator.pop(context); _completeRide(rideId); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildStatsRow(),
        if (_isOnline) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              const Text('🔔', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              const Text('PENDING RIDES — LIVE', style: TextStyle(
                fontSize: 10, color: kMuted,
                letterSpacing: 1.2, fontWeight: FontWeight.w700)),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: kGreen, shape: BoxShape.circle)),
                ),
              ),
              const SizedBox(width: 5),
              const Text('LIVE', style: TextStyle(
                fontSize: 9, color: kGreen, fontWeight: FontWeight.w700)),
            ]),
          ),
          Expanded(child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildStream(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(children: [
                  Text('💰', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 6),
                  Text('TODAY EARNINGS', style: TextStyle(
                    fontSize: 10, color: kMuted,
                    letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                ]),
              ),
              _buildCompletedRides(),
              const SizedBox(height: 100),
            ],
          )),
        ] else
          Expanded(child: _buildOffline()),
      ])),
    );
  }

  Widget _buildCompletedRides() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'completed')
        .where('captainId', isEqualTo: 'captain_nizam_001')
        .orderBy('completedAt', descending: true)
        .limit(20)
        .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: kGold, strokeWidth: 2)));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('இன்று இன்னும் rides இல்லை', style: TextStyle(fontSize: 11, color: kMuted))));
        }
        return Column(
          children: docs.map((doc) {
            final d    = doc.data() as Map<String, dynamic>;
            final fare = d['fare'] as num? ?? 0;
            final ts   = d['completedAt'] as Timestamp?;
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33F5C542))),
              child: Row(children: [
                const Text('✅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['pickup'] as String? ?? '',
                      style: const TextStyle(fontSize: 11, color: kText),
                      overflow: TextOverflow.ellipsis),
                    Text(ts != null
                      ? '${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2,'0')}'
                      : '',
                      style: const TextStyle(fontSize: 9, color: kMuted)),
                  ],
                )),
                Text('₹${fare.toInt()}',
                  style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w800, color: kGold)),
              ]),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(children: [
        GestureDetector(
          onTap: () {
            if (widget.onExitCaptain != null) {
              widget.onExitCaptain!();
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: kCard, borderRadius: BorderRadius.circular(11),
              border: Border.all(color: kBorder)),
            child: const Icon(Icons.arrow_back_ios_new, size: 14, color: kMuted),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kGold, Color(0xFFD4961A)]),
            borderRadius: BorderRadius.circular(21)),
          child: const Center(child: Text('🏍️', style: TextStyle(fontSize: 21))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Captain Mode', style: GoogleFonts.notoSansTamil(
              fontSize: 16, fontWeight: FontWeight.w700, color: kGold)),
            const Text('NJ TECH Rider Dashboard',
              style: TextStyle(fontSize: 10, color: kMuted)),
          ],
        )),
        GestureDetector(
          onTap: () => setState(() => _isOnline = !_isOnline),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline
                ? const Color(0x1A3DBA6F)
                : const Color(0x1AE05555),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline
                  ? const Color(0x663DBA6F)
                  : const Color(0x66E05555))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 7,
                decoration: BoxDecoration(
                  color: _isOnline ? kGreen : kRed,
                  shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(_isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800,
                  color: _isOnline ? kGreen : kRed,
                  letterSpacing: 1)),
            ]),
          ),
        ),
        const SizedBox(width: 14),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('read', isEqualTo: false)
            .snapshots(),
          builder: (context, snap) {
            int count = snap.data?.docs.length ?? 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 24, color: kMuted),
                if (count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(count > 9 ? '9+' : '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    ),
                  ),
              ],
            );
          },
        ),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33F5C542))),
      child: Row(children: [
        _stat('🏍️', 'Today Rides', _todayRides.toString(), kPurple2),
        Container(width: 1, height: 40, color: kBorder,
          margin: const EdgeInsets.symmetric(horizontal: 8)),
        _stat('💰', 'Earnings', '₹${_todayEarnings.toStringAsFixed(0)}', kGold),
        Container(width: 1, height: 40, color: kBorder,
          margin: const EdgeInsets.symmetric(horizontal: 8)),
        _stat('⭐', 'Rating', _avgRating.toStringAsFixed(1), kGreen),
      ]),
    );
  }

  Widget _stat(String e, String label, String val, Color color) =>
    Expanded(child: Column(children: [
      Text(e, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 9, color: kMuted)),
    ]));

  Widget _buildStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kGold));
        }
        if (snap.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: ${snap.error}',
              style: const TextStyle(color: kOrange, fontSize: 12),
              textAlign: TextAlign.center)));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛵', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('Pending rides இல்லை',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
              const SizedBox(height: 6),
              const Text('Customers order பண்ணும்போது இங்க வரும்!',
                style: TextStyle(fontSize: 12, color: kMuted),
                textAlign: TextAlign.center),
            ]));
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _RideCard(
              rideId:   doc.id,
              data:     data,
              onAccept: () => _acceptRide(doc.id, data),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOffline() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('😴', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 20),
        Text('நீங்கள் Offline-ல இருக்கீங்க',
          style: GoogleFonts.notoSansTamil(
            fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
        const SizedBox(height: 8),
        const Text('Ride accept பண்ண Online பண்ணுங்க!',
          style: TextStyle(fontSize: 13, color: kMuted)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _isOnline = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kGreen, Color(0xFF2A9A5C)]),
              borderRadius: BorderRadius.circular(20)),
            child: Text('Go Online 🟢',
              style: GoogleFonts.notoSansTamil(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white)),
          ),
        ),
      ]),
    ));
  }
}

// ── Ride Card Widget ──────────────────────────────────────────────
class _RideCard extends StatelessWidget {
  final String              rideId;
  final Map<String, dynamic> data;
  final VoidCallback         onAccept;
  const _RideCard({required this.rideId, required this.data, required this.onAccept});

  String _ago(dynamic ts) {
    if (ts == null) return 'just now';
    final dt   = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final fare     = data['fare']     as num?    ?? 0;
    final dist     = data['distKm']   as num?    ?? 0;
    final pickup   = data['pickup']   as String? ?? '';
    final drop     = data['drop']     as String? ?? '';
    final rideType = data['rideType'] as String? ?? 'Bike';
    final Color accent = rideType == 'Auto' ? kGreen
      : rideType == 'Parcel' ? kPurple2 : kGold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(
          accent.r.toInt(), accent.g.toInt(), accent.b.toInt(), 0.35))),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  accent.r.toInt(), accent.g.toInt(), accent.b.toInt(), 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color.fromRGBO(
                  accent.r.toInt(), accent.g.toInt(), accent.b.toInt(), 0.3))),
              child: Center(child: Text(
                rideType == 'Auto' ? '🛺' : rideType == 'Parcel' ? '📦' : '🏍️',
                style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal:8,vertical:3),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        accent.r.toInt(),accent.g.toInt(),accent.b.toInt(),0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Color.fromRGBO(
                        accent.r.toInt(),accent.g.toInt(),accent.b.toInt(),0.3))),
                    child: Text(rideType.toUpperCase(), style: TextStyle(
                      fontSize:8, color:accent,
                      fontWeight:FontWeight.w800, letterSpacing:1)),
                  ),
                  const Spacer(),
                  Text(_ago(data['createdAt']),
                    style: const TextStyle(fontSize:9, color:kMuted)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Container(width:10, height:10,
                    decoration: const BoxDecoration(
                      color:kGreen, shape:BoxShape.circle)),
                  const SizedBox(width:8),
                  Expanded(child: Text(pickup,
                    style: const TextStyle(fontSize:12, color:kText,
                      fontWeight:FontWeight.w500),
                    overflow: TextOverflow.ellipsis)),
                ]),
                Padding(padding: const EdgeInsets.only(left:4),
                  child: Container(width:2, height:12,
                    color:kBorder, margin:const EdgeInsets.symmetric(vertical:2))),
                Row(children: [
                  Container(width:10, height:10,
                    decoration: BoxDecoration(
                      color:kOrange, borderRadius:BorderRadius.circular(3))),
                  const SizedBox(width:8),
                  Expanded(child: Text(drop,
                    style: const TextStyle(fontSize:12, color:kText,
                      fontWeight:FontWeight.w500),
                    overflow: TextOverflow.ellipsis)),
                ]),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${fare.toInt()}', style: TextStyle(
                fontSize:22, fontWeight:FontWeight.w800, color:accent)),
              Text('${dist.toStringAsFixed(1)} km',
                style: const TextStyle(fontSize:10, color:kMuted)),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14,0,14,14),
          child: GestureDetector(
            onTap: onAccept,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accent,
                  Color.fromRGBO(accent.r.toInt(),accent.g.toInt(),accent.b.toInt(),0.75)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: Color.fromRGBO(accent.r.toInt(),accent.g.toInt(),accent.b.toInt(),0.35),
                  blurRadius:12, offset: const Offset(0,4))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_circle_outline, size:18, color:Colors.white),
                const SizedBox(width:8),
                Text('Accept Ride →', style: GoogleFonts.notoSansTamil(
                  fontSize:14, fontWeight:FontWeight.w700,
                  color: const Color(0xFF1a1500))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Accepted Sheet ────────────────────────────────────────────────
class _AcceptedSheet extends StatelessWidget {
  final String              rideId;
  final Map<String, dynamic> data;
  final VoidCallback         onComplete;
  const _AcceptedSheet({required this.rideId, required this.data, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final fare   = data['fare']   as num?    ?? 0;
    final pickup = data['pickup'] as String? ?? '';
    final drop   = data['drop']   as String? ?? '';
    return Container(
      padding: const EdgeInsets.fromLTRB(20,10,20,30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width:40, height:4, margin:const EdgeInsets.only(bottom:20),
          decoration: BoxDecoration(color: const Color(0x267B6FE0),
            borderRadius: BorderRadius.circular(2))),
        const Text('🎉', style: TextStyle(fontSize:40)),
        const SizedBox(height:12),
        Text('Ride Accepted!', style: GoogleFonts.notoSansTamil(
          fontSize:20, fontWeight:FontWeight.w800, color: const Color(0xFF3DBA6F))),
        const SizedBox(height:16),
        _row('🟢','Pickup',pickup),
        const SizedBox(height:8),
        _row('🟠','Drop',drop),
        const SizedBox(height:16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x1AF5C542),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x4DF5C542))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('💰', style: TextStyle(fontSize:24)),
            const SizedBox(width:10),
            Text('Collect ₹${fare.toInt()} from Customer',
              style: const TextStyle(fontSize:16, fontWeight:FontWeight.w700,
                color: Color(0xFFF5C542))),
          ]),
        ),
        const SizedBox(height:16),
        SizedBox(
          width: double.infinity, height:52,
          child: ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3DBA6F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              elevation:0),
            child: Text('Ride Complete ✅', style: GoogleFonts.notoSansTamil(
              fontSize:15, fontWeight:FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _row(String dot, String lbl, String txt) =>
    Row(children: [
      Text(dot, style: const TextStyle(fontSize:12)),
      const SizedBox(width:10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl, style: const TextStyle(fontSize:9, color: Color(0xFF7777A0),
          letterSpacing:0.8, fontWeight:FontWeight.w600)),
        Text(txt, style: const TextStyle(fontSize:13, color: Color(0xFFEEEEF5),
          fontWeight:FontWeight.w500)),
      ]),
    ]);
}
