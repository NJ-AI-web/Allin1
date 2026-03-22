// lib/widgets/allin1_map_widget.dart
// Coder 2.0 | flutter_map v8.x compatible
// ─────────────────────────────────────────
// OFFLINE SWITCH (Phase 2 — Future):
// Change _useOfflineMap = true
// Change _offlineTileUrl to 'assets/erode_map/{z}/{x}/{y}.png'
// Add AssetTileProvider() — that's it!
// ─────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ── Erode Default Coordinates ──
const LatLng kErodeCenter = LatLng(11.3410, 77.7171);

// ── Phase Switch (Change this for offline) ──
const bool _useOfflineMap = false;

const String _onlineTileUrl =
    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
const String _offlineTileUrl = 'assets/erode_map/{z}/{x}/{y}.png';

class Allin1MapWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<MapMarker> markers;
  final List<MapRoute> routes;
  final bool interactive;
  final MapController? mapController;

  const Allin1MapWidget({
    super.key,
    this.center = kErodeCenter,
    this.zoom = 14.0,
    this.markers = const [],
    this.routes = const [],
    this.interactive = true,
    this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: 10,
        maxZoom: 18,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        // ── Tile Layer (THE ONE-LINE SWITCH POINT) ──
        TileLayer(
          urlTemplate: _useOfflineMap ? _offlineTileUrl : _onlineTileUrl,
          userAgentPackageName: 'com.allin1.superapp',
          maxZoom: 18,
        ),

        // ── Routes ──
        if (routes.isNotEmpty)
          PolylineLayer(
            polylines: routes
                .map(
                  (r) => Polyline(
                    points: r.points,
                    color: r.color,
                    strokeWidth: r.strokeWidth,
                  ),
                )
                .toList(),
          ),

        // ── Markers ──
        MarkerLayer(
          markers: markers
              .map(
                (m) => Marker(
                  point: m.point,
                  width: m.size,
                  height: m.size,
                  child: _DefaultMarker(
                    color: m.color,
                    icon: m.icon,
                    label: m.label,
                  ),
                ),
              )
              .toList(),
        ),

        // ── Branding ──
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: _WatermarkBadge(),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LatLng>('center', center));
    properties.add(DoubleProperty('zoom', zoom));
    properties.add(IterableProperty<MapMarker>('markers', markers));
    properties.add(IterableProperty<MapRoute>('routes', routes));
    properties.add(DiagnosticsProperty<bool>('interactive', interactive));
    properties.add(
      DiagnosticsProperty<MapController?>('mapController', mapController),
    );
  }
}

// ── Watermark ──────────────────────────────────
class _WatermarkBadge extends StatelessWidget {
  const _WatermarkBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Allin1 • OSM',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 9,
        ),
      ),
    );
  }
}

// ── Default Marker ─────────────────────────────
class _DefaultMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String? label;

  const _DefaultMarker({
    required this.color,
    required this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('label', label));
  }
}

// ── Data Models ────────────────────────────────
class MapMarker {
  final LatLng point;
  final Color color;
  final IconData icon;
  final String? label;
  final double size;

  const MapMarker({
    required this.point,
    this.color = const Color(0xFFFF6B35),
    this.icon = Icons.location_on_rounded,
    this.label,
    this.size = 56,
  });
}

class MapRoute {
  final List<LatLng> points;
  final Color color;
  final double strokeWidth;

  const MapRoute({
    required this.points,
    this.color = const Color(0xFFFF6B35),
    this.strokeWidth = 4.0,
  });
}
