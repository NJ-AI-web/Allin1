// ================================================================
// RideTrackingScreen v2.0 — Real Firestore status listener
// ================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/ride_model.dart';
import '../../widgets/allin1_map_widget.dart';
import '../payment_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final RideModel ride;
  final String rideDocId;
  const RideTrackingScreen({
    required this.ride,
    required this.rideDocId,
    super.key,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<RideModel>('ride', ride))
      ..add(StringProperty('rideDocId', rideDocId));
  }
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {

  static const Color _card = Color(0xFF1A1A2A);
  static const Color _green = Color(0xFF00C853);
  static const Color _gold = Color(0xFFFFBB00);
  static const Color _text = Color(0xFFEEEEF5);
  static const Color _muted = Color(0xFF7777A0);
  static const Color _border = Color(0x1AFFFFFF);

  String _rideStatus = 'arriving';
  bool _completed = false;
  double? _captainLat;
  double? _captainLng;
  String? _captainName;
  String? _captainBike;
  String? _captainPhone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: widget.rideDocId.isNotEmpty
            ? StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rides')
                    .doc(widget.rideDocId)
                    .snapshots(),
                builder: (_, snap) {
                  if (snap.hasData && snap.data!.exists) {
                    final data = snap.data!.data()! as Map<String, dynamic>;
                    final st = data['status'] as String? ?? 'arriving';
                    final cLat = (data['captainLat'] as num?)?.toDouble();
                    final cLng = (data['captainLng'] as num?)?.toDouble();
                    final cName = data['captainName'] as String?;
                    final cBike = data['captainBike'] as String?;
                    final cPhone = data['captainPhone'] as String?;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        bool changed = false;
                        if (_rideStatus != st) {
                          _rideStatus = st;
                          changed = true;
                          if (st == 'completed') {
                            _completed = true;
                          }
                        }
                        if (_captainLat != cLat || _captainLng != cLng) {
                          _captainLat = cLat;
                          _captainLng = cLng;
                          changed = true;
                        }
                        if (_captainName != cName ||
                            _captainBike != cBike ||
                            _captainPhone != cPhone) {
                          _captainName = cName;
                          _captainBike = cBike;
                          _captainPhone = cPhone;
                          changed = true;
                        }
                        if (changed) {
                          setState(() {});
                        }
                      }
                    });
                  }
                  return _buildBody();
                },
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_completed)
                  _completedBanner()
                else ...[
                  _arrivalBanner(),
                  const SizedBox(height: 16),
                  _buildTrackingMap(),
                ],
                const SizedBox(height: 16),
                _captainCard(),
                const SizedBox(height: 16),
                _routeCard(),
                if (_completed) ...[
                  const SizedBox(height: 16),
                  _upiButton(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF12121E),
          border: Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: _muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Track Your Ride',
              style: TextStyle(
                fontSize: 16,
                color: _text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x1A00C853),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x3300C853)),
              ),
              child: Text(
                _completed ? 'Completed ✅' : 'Live 🟢',
                style: const TextStyle(
                  fontSize: 10,
                  color: _green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _arrivalBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x1AFF6B35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33FF6B35)),
        ),
        child: Column(
          children: [
            const Text('🏍️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text(
              'Hero is on the way!',
              style: TextStyle(
                fontSize: 18,
                color: _text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_captainName ?? widget.ride.captainName ?? 'Your Hero'} வருகிறார்',
              style: GoogleFonts.notoSansTamil(
                fontSize: 12,
                color: _muted,
              ),
            ),
          ],
        ),
      );

  Widget _completedBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x1A00C853),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x3300C853)),
        ),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text(
              'Ride Complete!',
              style: TextStyle(
                fontSize: 18,
                color: _green,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'நன்றி! இப்போ pay பண்ணுங்க',
              style: GoogleFonts.notoSansTamil(
                fontSize: 12,
                color: _muted,
              ),
            ),
          ],
        ),
      );

  Widget _captainCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFBB00), Color(0xFFFF6B35)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  (_captainName ?? widget.ride.captainName)?.isNotEmpty ?? false
                      ? (_captainName ?? widget.ride.captainName)![0]
                          .toUpperCase()
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
                    _captainName ?? widget.ride.captainName ?? 'Hero Rider',
                    style: const TextStyle(
                      fontSize: 15,
                      color: _text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((_captainBike ?? widget.ride.captainBikeNumber)
                          ?.isNotEmpty ??
                      false)
                    Text(
                      _captainBike ?? widget.ride.captainBikeNumber!,
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                ],
              ),
            ),
            // Call button
            if ((_captainPhone ?? widget.ride.captainPhone)?.isNotEmpty ??
                false)
              GestureDetector(
                onTap: () async {
                  final phone = _captainPhone ?? widget.ride.captainPhone;
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) {
                    if (mounted) {
                      await launchUrl(uri);
                    }
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x1A00C853),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0x3300C853)),
                  ),
                  child: const Icon(Icons.phone, size: 18, color: _green),
                ),
              ),
          ],
        ),
      );

  Widget _routeCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            _rRow('🔴', 'Pickup', widget.ride.pickupAddress ?? ''),
            const SizedBox(height: 10),
            _rRow('🟢', 'Drop', widget.ride.dropAddress ?? ''),
            const Divider(color: Color(0x1AFFFFFF), height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fare',
                  style: TextStyle(
                    fontSize: 12,
                    color: _muted,
                  ),
                ),
                Text(
                  '₹${widget.ride.estimatedFare?.round() ?? 0}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: _gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _upiButton() {
    final fare = widget.ride.estimatedFare?.toDouble() ?? 0;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder<void>(
              pageBuilder: (_, __, ___) => PaymentScreen(
                amount: fare,
                note: 'Bike Taxi Ride - Allin1',
                rideDocId:
                    widget.rideDocId.isNotEmpty ? widget.rideDocId : null,
              ),
              transitionDuration: const Duration(milliseconds: 350),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4A44CC)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x446C63FF),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment_rounded, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay Rs.${fare.toStringAsFixed(0)} via UPI',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'GPay - PhonePe - Super Money',
                  style: TextStyle(fontSize: 9, color: Color(0xCCFFFFFF)),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingMap() {
    final pickup = LatLng(
      widget.ride.pickupLatitude ?? 11.3410,
      widget.ride.pickupLongitude ?? 77.7172,
    );

    final markers = <MapMarker>[
      MapMarker(
        point: pickup,
        label: 'Pickup',
        icon: Icons.person_pin_circle_rounded,
      ),
    ];

    if (_captainLat != null && _captainLng != null) {
      markers.add(
        MapMarker(
          point: LatLng(_captainLat!, _captainLng!),
          color: _green,
          label: 'Hero',
          icon: Icons.motorcycle_rounded,
        ),
      );
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Allin1MapWidget(
          center: markers.length > 1 ? markers.last.point : pickup,
          zoom: 15,
          markers: markers,
        ),
      ),
    );
  }



  Widget _rRow(String dot, String lbl, String txt) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dot, style: const TextStyle(fontSize: 11)),
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
}
