import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/ride_model.dart';
import '../../widgets/allin1_map_widget.dart';
import 'ride_search_screen.dart';

class BikeBookingScreen extends StatefulWidget {
  const BikeBookingScreen({super.key});

  @override
  State<BikeBookingScreen> createState() => _BikeBookingScreenState();
}

class _BikeBookingScreenState extends State<BikeBookingScreen> {
  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _accentOrange = Color(0xFFFF6B35);
  static const Color _accentGold = Color(0xFFFFBB00);
  static const Color _border = Color(0xFF2C2C2C);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF9E9E9E);

  final List<String> _pickupSuggestions = [
    '📍 Erode Bus Stand, Erode',
    '📍 Perundurai Road, Erode',
    '📍 Selvapuram, Erode',
    '📍 Erode Junction Railway Station',
    '📍 Veerappan Chatram, Erode',
    '📍 Kabilarmalai, Erode',
  ];

  final List<String> _dropSuggestions = [
    '🏁 Erode GH Hospital',
    '🏁 Erode Arts College',
    '🏁 Bhavanisagar Dam',
    '🏁 Perundurai SIPCOT',
    '🏁 Chithode, Erode',
    '🏁 Gobichettipalayam',
  ];

  // Simulated lat/lng for each location
  final Map<String, LatLng> _locationCoords = {
    '📍 Erode Bus Stand, Erode': const LatLng(11.3410, 77.7171),
    '📍 Perundurai Road, Erode': const LatLng(11.3350, 77.7250),
    '📍 Selvapuram, Erode': const LatLng(11.3480, 77.7100),
    '📍 Erode Junction Railway Station': const LatLng(11.3398, 77.7283),
    '📍 Veerappan Chatram, Erode': const LatLng(11.3290, 77.7190),
    '📍 Kabilarmalai, Erode': const LatLng(11.3600, 77.7050),
    '🏁 Erode GH Hospital': const LatLng(11.3420, 77.7300),
    '🏁 Erode Arts College': const LatLng(11.3550, 77.7400),
    '🏁 Bhavanisagar Dam': const LatLng(11.4620, 77.1830),
    '🏁 Perundurai SIPCOT': const LatLng(11.2770, 77.5880),
    '🏁 Chithode, Erode': const LatLng(11.3190, 77.6890),
    '🏁 Gobichettipalayam': const LatLng(11.4530, 77.4330),
  };

  String? _selectedPickup;
  String? _selectedDrop;
  bool _showPickupList = false;
  bool _showDropList = false;
  bool _isLocating = false;

  LatLng get _mapCenter {
    if (_selectedPickup != null) {
      return _locationCoords[_selectedPickup] ?? kErodeCenter;
    }
    return kErodeCenter;
  }

  double get _distance {
    if (_selectedPickup == null || _selectedDrop == null) {
      return 0;
    }
    final r = Random(_selectedPickup.hashCode ^ _selectedDrop.hashCode);
    return 2.0 + r.nextDouble() * 8.0;
  }

  double get _fare => RideModel.calculateFare(_distance);
  int get _eta => (_distance * 3).round().clamp(5, 30);
  bool get _canProceed => _selectedPickup != null && _selectedDrop != null;

  void _proceedToSearch() {
    if (!_canProceed) {
      return;
    }
    final ride = RideModel(
      rideId: 'RID${DateTime.now().millisecondsSinceEpoch}',
      pickupAddress: _selectedPickup,
      dropAddress: _selectedDrop,
      estimatedFare: _fare,
      distanceKm: double.parse(_distance.toStringAsFixed(1)),
      etaMinutes: _eta,
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => RideSearchScreen(ride: ride)),
    );
  }

  Future<void> _getMyLocation() async {
    if (kIsWeb) {
      setState(() => _selectedPickup = 'Erode, Tamil Nadu');
      return;
    }
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location service disabled!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      setState(() => _isLocating = true);
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _selectedPickup = '📍 My Location';
        _isLocating = false;
      });
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Bike Taxi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentOrange.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.electric_bike_rounded,
                  color: _accentOrange,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Erode',
                  style: TextStyle(
                    color: _accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: GestureDetector(
        onTap: () => setState(() {
          _showPickupList = false;
          _showDropList = false;
        }),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMapBanner(),
              const SizedBox(height: 20),
              _buildLocationCard(),
              const SizedBox(height: 20),
              if (_canProceed) ...[
                _buildFareCard(),
                const SizedBox(height: 20),
              ],
              _buildRideTypeSelector(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── Real Map Banner ──────────────────────────
  Widget _buildMapBanner() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Allin1MapWidget(
              center: _mapCenter,
              zoom: 13.5,
              markers: [
                if (_selectedPickup != null)
                  MapMarker(
                    point: _locationCoords[_selectedPickup] ?? kErodeCenter,
                    icon: Icons.my_location_rounded,
                    label: 'Pickup',
                  ),
                if (_selectedDrop != null)
                  MapMarker(
                    point: _locationCoords[_selectedDrop] ?? kErodeCenter,
                    color: const Color(0xFF4CAF50),
                    label: 'Drop',
                  ),
                if (_selectedPickup == null && _selectedDrop == null)
                  const MapMarker(
                    point: kErodeCenter,
                    icon: Icons.electric_bike_rounded,
                    label: 'Erode',
                  ),
              ],
              routes: (_selectedPickup != null && _selectedDrop != null)
                  ? [
                      MapRoute(
                        points: [
                          _locationCoords[_selectedPickup]!,
                          _locationCoords[_selectedDrop]!,
                        ],
                      ),
                    ]
                  : [],
            ),
            // Captains nearby badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '12 Heroes nearby',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── My Location Button ──
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: _getMyLocation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C2C2C)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLocating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF6B35),
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFFFF6B35),
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Location Card ────────────────────────────
  Widget _buildLocationCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _buildLocationField(
            icon: Icons.radio_button_checked_rounded,
            iconColor: _accentOrange,
            hint: 'Pickup location',
            selected: _selectedPickup,
            showList: _showPickupList,
            suggestions: _pickupSuggestions,
            onTap: () => setState(() {
              _showPickupList = true;
              _showDropList = false;
            }),
            onSelect: (val) => setState(() {
              _selectedPickup = val;
              _showPickupList = false;
            }),
            onClear: () => setState(() => _selectedPickup = null),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Row(
              children: [
                const Expanded(child: Divider(color: _border, height: 1)),
                GestureDetector(
                  onTap: () => setState(() {
                    final tmp = _selectedPickup;
                    _selectedPickup = _selectedDrop;
                    _selectedDrop = tmp;
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: _textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLocationField(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF4CAF50),
            hint: 'Drop location',
            selected: _selectedDrop,
            showList: _showDropList,
            suggestions: _dropSuggestions,
            onTap: () => setState(() {
              _showDropList = true;
              _showPickupList = false;
            }),
            onSelect: (val) => setState(() {
              _selectedDrop = val;
              _showDropList = false;
            }),
            onClear: () => setState(() => _selectedDrop = null),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required Color iconColor,
    required String hint,
    required String? selected,
    required bool showList,
    required List<String> suggestions,
    required VoidCallback onTap,
    required void Function(String) onSelect,
    required VoidCallback onClear,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    selected ?? hint,
                    style: TextStyle(
                      color: selected != null ? _textPrimary : _textSecondary,
                      fontSize: 14,
                      fontWeight:
                          selected != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      color: _textSecondary,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showList)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: suggestions
                  .map(
                    (s) => InkWell(
                      onTap: () => onSelect(s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: _textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  // ── Fare Card ────────────────────────────────
  Widget _buildFareCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accentOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: _accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Fare Estimate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '₹${_fare.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _accentGold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _border),
          const SizedBox(height: 14),
          Row(
            children: [
              _statChip(
                Icons.route_rounded,
                _accentOrange,
                '${_distance.toStringAsFixed(1)} km',
              ),
              const SizedBox(width: 10),
              _statChip(
                Icons.access_time_rounded,
                const Color(0xFF6C63FF),
                '$_eta mins',
              ),
              const SizedBox(width: 10),
              _statChip(
                Icons.electric_bike_rounded,
                const Color(0xFF4CAF50),
                'Bike',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, Color color, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ride Type Selector ───────────────────────
  Widget _buildRideTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ride Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _rideTypeCard(
                '🏍️',
                'Bike',
                '1 Person',
                _accentOrange,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _rideTypeCard(
                '🛺',
                'Auto',
                '3 Persons',
                _textSecondary,
                false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _rideTypeCard(
                '🚗',
                'Cab',
                '4 Persons',
                _textSecondary,
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Auto & Cab — Coming Soon!',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _rideTypeCard(
    String emoji,
    String name,
    String capacity,
    Color color,
    bool selected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected ? _accentOrange.withValues(alpha: 0.1) : _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _accentOrange : _border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              color: selected ? _textPrimary : _textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Text(
            capacity,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ───────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canProceed ? _proceedToSearch : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentOrange,
            disabledBackgroundColor: _accentOrange.withValues(alpha: 0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            _canProceed
                ? '🏍️  Find Captain — ₹${_fare.toStringAsFixed(0)}'
                : 'Select Pickup & Drop First',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
