// ================================================================
// Permission Service - Device Permissions Handler
// Allin1 Super App v1.0
// ================================================================

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  location,
  microphone,
  camera,
  storage,
}

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // ================================================================
  // Check if Permission is Granted
  // ================================================================
  Future<bool> isPermissionGranted(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        return await Permission.location.isGranted;
      case AppPermission.microphone:
        return await Permission.microphone.isGranted;
      case AppPermission.camera:
        return await Permission.camera.isGranted;
      case AppPermission.storage:
        return await Permission.storage.isGranted;
    }
  }

  // ================================================================
  // Request Permission
  // ================================================================
  Future<bool> requestPermission(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        return await requestLocationPermission();
      case AppPermission.microphone:
        return await requestMicrophonePermission();
      case AppPermission.camera:
        return await requestCameraPermission();
      case AppPermission.storage:
        return await requestStoragePermission();
    }
  }

  // ================================================================
  // Request Location Permission
  // ================================================================
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // ================================================================
  // Request Microphone Permission
  // ================================================================
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // ================================================================
  // Request Camera Permission
  // ================================================================
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // ================================================================
  // Request Storage Permission
  // ================================================================
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // ================================================================
  // Request Multiple Permissions
  // ================================================================
  Future<Map<AppPermission, bool>> requestMultiplePermissions(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, bool>{};

    for (final permission in permissions) {
      results[permission] = await requestPermission(permission);
    }

    return results;
  }

  // ================================================================
  // Check Permission Status
  // ================================================================
  Future<PermissionStatus> getPermissionStatus(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        return await Permission.location.status;
      case AppPermission.microphone:
        return await Permission.microphone.status;
      case AppPermission.camera:
        return await Permission.camera.status;
      case AppPermission.storage:
        return await Permission.storage.status;
    }
  }

  // ================================================================
  // Open App Settings
  // ================================================================
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // ================================================================
  // Show Permission Dialog
  // ================================================================
  Future<bool> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String permissionName,
    required IconData icon,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ================================================================
  // Get Permission Description
  // ================================================================
  String getPermissionDescription(AppPermission permission) {
    switch (permission) {
      case AppPermission.location:
        return 'Location access is needed to show your position on the map, find nearby rides, and track your journey.';
      case AppPermission.microphone:
        return 'Microphone access is needed for voice commands and driver-passenger communication.';
      case AppPermission.camera:
        return 'Camera access is needed to take profile photos and verify your identity.';
      case AppPermission.storage:
        return 'Storage access is needed to save trip receipts and documents.';
    }
  }

  // ================================================================
  // Get Permission Title
  // ================================================================
  String getPermissionTitle(AppPermission permission) {
    switch (permission) {
      case AppPermission.location:
        return 'Location Permission';
      case AppPermission.microphone:
        return 'Microphone Permission';
      case AppPermission.camera:
        return 'Camera Permission';
      case AppPermission.storage:
        return 'Storage Permission';
    }
  }

  // ================================================================
  // Get Permission Icon
  // ================================================================
  IconData getPermissionIcon(AppPermission permission) {
    switch (permission) {
      case AppPermission.location:
        return Icons.location_on;
      case AppPermission.microphone:
        return Icons.mic;
      case AppPermission.camera:
        return Icons.camera_alt;
      case AppPermission.storage:
        return Icons.storage;
    }
  }
}
