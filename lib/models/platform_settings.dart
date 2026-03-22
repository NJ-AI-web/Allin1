// ================================================================
// Platform Settings Model - Commission & Fee Configuration
// Allin1 Super App v1.0
// ================================================================

/// Main platform settings container
class PlatformSettings {
  final String id;
  final RiderCommission riderCommission;
  final SellerCommission sellerCommission;
  final PlatformFee platformFee;
  final DeliverySettings deliverySettings;
  final DateTime? updatedAt;
  final String? updatedBy;

  PlatformSettings({
    required this.riderCommission,
    required this.sellerCommission,
    required this.platformFee,
    required this.deliverySettings,
    this.id = 'global',
    this.updatedAt,
    this.updatedBy,
  });

  factory PlatformSettings.defaults() {
    return PlatformSettings(
      riderCommission: RiderCommission.defaults(),
      sellerCommission: SellerCommission.defaults(),
      platformFee: PlatformFee.defaults(),
      deliverySettings: DeliverySettings.defaults(),
    );
  }

  factory PlatformSettings.fromMap(Map<String, dynamic> map) {
    return PlatformSettings(
      id: map['id'] as String? ?? 'global',
      riderCommission: map['riderCommission'] != null
          ? RiderCommission.fromMap(
              map['riderCommission'] as Map<String, dynamic>,
            )
          : RiderCommission.defaults(),
      sellerCommission: map['sellerCommission'] != null
          ? SellerCommission.fromMap(
              map['sellerCommission'] as Map<String, dynamic>,
            )
          : SellerCommission.defaults(),
      platformFee: map['platformFee'] != null
          ? PlatformFee.fromMap(map['platformFee'] as Map<String, dynamic>)
          : PlatformFee.defaults(),
      deliverySettings: map['deliverySettings'] != null
          ? DeliverySettings.fromMap(
              map['deliverySettings'] as Map<String, dynamic>,
            )
          : DeliverySettings.defaults(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'riderCommission': riderCommission.toMap(),
      'sellerCommission': sellerCommission.toMap(),
      'platformFee': platformFee.toMap(),
      'deliverySettings': deliverySettings.toMap(),
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'updatedBy': updatedBy,
    };
  }

  PlatformSettings copyWith({
    String? id,
    RiderCommission? riderCommission,
    SellerCommission? sellerCommission,
    PlatformFee? platformFee,
    DeliverySettings? deliverySettings,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return PlatformSettings(
      id: id ?? this.id,
      riderCommission: riderCommission ?? this.riderCommission,
      sellerCommission: sellerCommission ?? this.sellerCommission,
      platformFee: platformFee ?? this.platformFee,
      deliverySettings: deliverySettings ?? this.deliverySettings,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Rider/Captain commission configuration
class RiderCommission {
  final double bikeTaxiPercent;
  final double autoPercent;
  final double carPercent;
  final double deliveryPercent;
  final double foodDeliveryPercent;
  final double groceryPercent;
  final double minimumEarning;
  final double peakHourMultiplier;

  RiderCommission({
    required this.bikeTaxiPercent,
    required this.autoPercent,
    required this.carPercent,
    required this.deliveryPercent,
    required this.foodDeliveryPercent,
    required this.groceryPercent,
    required this.minimumEarning,
    required this.peakHourMultiplier,
  });

  factory RiderCommission.defaults() {
    return RiderCommission(
      bikeTaxiPercent: 15,
      autoPercent: 15,
      carPercent: 12,
      deliveryPercent: 15,
      foodDeliveryPercent: 18,
      groceryPercent: 18,
      minimumEarning: 30,
      peakHourMultiplier: 1.5,
    );
  }

  factory RiderCommission.fromMap(Map<String, dynamic> map) {
    return RiderCommission(
      bikeTaxiPercent: (map['bikeTaxiPercent'] as num?)?.toDouble() ?? 15.0,
      autoPercent: (map['autoPercent'] as num?)?.toDouble() ?? 15.0,
      carPercent: (map['carPercent'] as num?)?.toDouble() ?? 12.0,
      deliveryPercent: (map['deliveryPercent'] as num?)?.toDouble() ?? 15.0,
      foodDeliveryPercent:
          (map['foodDeliveryPercent'] as num?)?.toDouble() ?? 18.0,
      groceryPercent: (map['groceryPercent'] as num?)?.toDouble() ?? 18.0,
      minimumEarning: (map['minimumEarning'] as num?)?.toDouble() ?? 30.0,
      peakHourMultiplier:
          (map['peakHourMultiplier'] as num?)?.toDouble() ?? 1.5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bikeTaxiPercent': bikeTaxiPercent,
      'autoPercent': autoPercent,
      'carPercent': carPercent,
      'deliveryPercent': deliveryPercent,
      'foodDeliveryPercent': foodDeliveryPercent,
      'groceryPercent': groceryPercent,
      'minimumEarning': minimumEarning,
      'peakHourMultiplier': peakHourMultiplier,
    };
  }

  RiderCommission copyWith({
    double? bikeTaxiPercent,
    double? autoPercent,
    double? carPercent,
    double? deliveryPercent,
    double? foodDeliveryPercent,
    double? groceryPercent,
    double? minimumEarning,
    double? peakHourMultiplier,
  }) {
    return RiderCommission(
      bikeTaxiPercent: bikeTaxiPercent ?? this.bikeTaxiPercent,
      autoPercent: autoPercent ?? this.autoPercent,
      carPercent: carPercent ?? this.carPercent,
      deliveryPercent: deliveryPercent ?? this.deliveryPercent,
      foodDeliveryPercent: foodDeliveryPercent ?? this.foodDeliveryPercent,
      groceryPercent: groceryPercent ?? this.groceryPercent,
      minimumEarning: minimumEarning ?? this.minimumEarning,
      peakHourMultiplier: peakHourMultiplier ?? this.peakHourMultiplier,
    );
  }

  /// Get commission percentage for a specific service type
  double getCommissionForType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'biketaxi':
      case 'bike':
        return bikeTaxiPercent;
      case 'auto':
      case 'autorickshaw':
        return autoPercent;
      case 'car':
      case 'taxi':
        return carPercent;
      case 'delivery':
      case 'parcel':
        return deliveryPercent;
      case 'fooddelivery':
      case 'food':
        return foodDeliveryPercent;
      case 'grocery':
        return groceryPercent;
      default:
        return deliveryPercent;
    }
  }
}

/// Seller/Store commission configuration
class SellerCommission {
  final double foodPercent;
  final double groceryPercent;
  final double techPercent;
  final double pharmacyPercent;
  final double generalPercent;
  final double? minimumOrder;
  final double? flatFeeBelowMin;

  SellerCommission({
    required this.foodPercent,
    required this.groceryPercent,
    required this.techPercent,
    required this.pharmacyPercent,
    required this.generalPercent,
    this.minimumOrder,
    this.flatFeeBelowMin,
  });

  factory SellerCommission.defaults() {
    return SellerCommission(
      foodPercent: 20,
      groceryPercent: 18,
      techPercent: 15,
      pharmacyPercent: 15,
      generalPercent: 15,
      minimumOrder: 100,
      flatFeeBelowMin: 15,
    );
  }

  factory SellerCommission.fromMap(Map<String, dynamic> map) {
    return SellerCommission(
      foodPercent: (map['foodPercent'] as num?)?.toDouble() ?? 20.0,
      groceryPercent: (map['groceryPercent'] as num?)?.toDouble() ?? 18.0,
      techPercent: (map['techPercent'] as num?)?.toDouble() ?? 15.0,
      pharmacyPercent: (map['pharmacyPercent'] as num?)?.toDouble() ?? 15.0,
      generalPercent: (map['generalPercent'] as num?)?.toDouble() ?? 15.0,
      minimumOrder: (map['minimumOrder'] as num?)?.toDouble(),
      flatFeeBelowMin: (map['flatFeeBelowMin'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodPercent': foodPercent,
      'groceryPercent': groceryPercent,
      'techPercent': techPercent,
      'pharmacyPercent': pharmacyPercent,
      'generalPercent': generalPercent,
      'minimumOrder': minimumOrder,
      'flatFeeBelowMin': flatFeeBelowMin,
    };
  }

  SellerCommission copyWith({
    double? foodPercent,
    double? groceryPercent,
    double? techPercent,
    double? pharmacyPercent,
    double? generalPercent,
    double? minimumOrder,
    double? flatFeeBelowMin,
  }) {
    return SellerCommission(
      foodPercent: foodPercent ?? this.foodPercent,
      groceryPercent: groceryPercent ?? this.groceryPercent,
      techPercent: techPercent ?? this.techPercent,
      pharmacyPercent: pharmacyPercent ?? this.pharmacyPercent,
      generalPercent: generalPercent ?? this.generalPercent,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      flatFeeBelowMin: flatFeeBelowMin ?? this.flatFeeBelowMin,
    );
  }

  /// Get commission percentage for a specific category
  double getCommissionForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
      case 'foodcourt':
        return foodPercent;
      case 'grocery':
      case 'vegetables':
      case 'kirana':
        return groceryPercent;
      case 'tech':
      case 'electronics':
      case 'mobile':
        return techPercent;
      case 'pharmacy':
      case 'medicine':
      case 'medical':
        return pharmacyPercent;
      default:
        return generalPercent;
    }
  }
}

/// Platform fee configuration
class PlatformFee {
  final double paymentGatewayFee;
  final bool upiZeroFee;

  PlatformFee({
    required this.paymentGatewayFee,
    required this.upiZeroFee,
  });

  factory PlatformFee.defaults() {
    return PlatformFee(
      paymentGatewayFee: 2,
      upiZeroFee: true,
    );
  }

  factory PlatformFee.fromMap(Map<String, dynamic> map) {
    return PlatformFee(
      paymentGatewayFee: (map['paymentGatewayFee'] as num?)?.toDouble() ?? 2.0,
      upiZeroFee: map['upiZeroFee'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentGatewayFee': paymentGatewayFee,
      'upiZeroFee': upiZeroFee,
    };
  }

  PlatformFee copyWith({
    double? paymentGatewayFee,
    bool? upiZeroFee,
  }) {
    return PlatformFee(
      paymentGatewayFee: paymentGatewayFee ?? this.paymentGatewayFee,
      upiZeroFee: upiZeroFee ?? this.upiZeroFee,
    );
  }
}

/// Delivery settings configuration
class DeliverySettings {
  final double baseDeliveryFee;
  final double freeDeliveryThreshold;
  final double perKmRate;
  final double minimumDistanceKm;
  final double expressDeliveryFee;
  final double scheduledDeliveryFee;
  final List<DeliveryTier> tiers;

  DeliverySettings({
    required this.baseDeliveryFee,
    required this.freeDeliveryThreshold,
    required this.perKmRate,
    required this.minimumDistanceKm,
    required this.expressDeliveryFee,
    required this.scheduledDeliveryFee,
    required this.tiers,
  });

  factory DeliverySettings.defaults() {
    return DeliverySettings(
      baseDeliveryFee: 30,
      freeDeliveryThreshold: 200,
      perKmRate: 5,
      minimumDistanceKm: 2,
      expressDeliveryFee: 50,
      scheduledDeliveryFee: 20,
      tiers: [
        DeliveryTier(maxDistanceKm: 3, fee: 30),
        DeliveryTier(maxDistanceKm: 5, fee: 40),
        DeliveryTier(maxDistanceKm: 10, fee: 60),
        DeliveryTier(maxDistanceKm: 999, fee: 100),
      ],
    );
  }

  factory DeliverySettings.fromMap(Map<String, dynamic> map) {
    List<DeliveryTier> tiers = [];
    if (map['tiers'] != null) {
      tiers = (map['tiers'] as List)
          .map((t) => DeliveryTier.fromMap(t as Map<String, dynamic>))
          .toList();
    }

    return DeliverySettings(
      baseDeliveryFee: (map['baseDeliveryFee'] as num?)?.toDouble() ?? 30.0,
      freeDeliveryThreshold:
          (map['freeDeliveryThreshold'] as num?)?.toDouble() ?? 200.0,
      perKmRate: (map['perKmRate'] as num?)?.toDouble() ?? 5.0,
      minimumDistanceKm: (map['minimumDistanceKm'] as num?)?.toDouble() ?? 2.0,
      expressDeliveryFee:
          (map['expressDeliveryFee'] as num?)?.toDouble() ?? 50.0,
      scheduledDeliveryFee:
          (map['scheduledDeliveryFee'] as num?)?.toDouble() ?? 20.0,
      tiers: tiers.isEmpty ? DeliverySettings.defaults().tiers : tiers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseDeliveryFee': baseDeliveryFee,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'perKmRate': perKmRate,
      'minimumDistanceKm': minimumDistanceKm,
      'expressDeliveryFee': expressDeliveryFee,
      'scheduledDeliveryFee': scheduledDeliveryFee,
      'tiers': tiers.map((t) => t.toMap()).toList(),
    };
  }

  DeliverySettings copyWith({
    double? baseDeliveryFee,
    double? freeDeliveryThreshold,
    double? perKmRate,
    double? minimumDistanceKm,
    double? expressDeliveryFee,
    double? scheduledDeliveryFee,
    List<DeliveryTier>? tiers,
  }) {
    return DeliverySettings(
      baseDeliveryFee: baseDeliveryFee ?? this.baseDeliveryFee,
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      perKmRate: perKmRate ?? this.perKmRate,
      minimumDistanceKm: minimumDistanceKm ?? this.minimumDistanceKm,
      expressDeliveryFee: expressDeliveryFee ?? this.expressDeliveryFee,
      scheduledDeliveryFee: scheduledDeliveryFee ?? this.scheduledDeliveryFee,
      tiers: tiers ?? this.tiers,
    );
  }

  /// Calculate delivery fee based on distance and order subtotal
  double calculateDeliveryFee({
    required double distanceKm,
    required double subtotal,
    String deliveryType = 'standard',
  }) {
    // Free delivery above threshold
    if (subtotal >= freeDeliveryThreshold) {
      return 0;
    }

    double fee = baseDeliveryFee;

    // Find appropriate tier
    for (final tier in tiers) {
      if (distanceKm <= tier.maxDistanceKm) {
        fee = tier.fee;
        break;
      }
    }

    // Add express/scheduled fees
    if (deliveryType == 'express') {
      fee += expressDeliveryFee;
    } else if (deliveryType == 'scheduled') {
      fee += scheduledDeliveryFee;
    }

    return fee;
  }
}

/// Delivery tier for distance-based pricing
class DeliveryTier {
  final double maxDistanceKm;
  final double fee;

  DeliveryTier({
    required this.maxDistanceKm,
    required this.fee,
  });

  factory DeliveryTier.fromMap(Map<String, dynamic> map) {
    return DeliveryTier(
      maxDistanceKm: (map['maxDistanceKm'] as num?)?.toDouble() ?? 999,
      fee: (map['fee'] as num?)?.toDouble() ?? 30.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxDistanceKm': maxDistanceKm,
      'fee': fee,
    };
  }
}

/// Seller-specific override for commissions
class SellerOverride {
  final String storeId;
  final double? customCommissionPercent;
  final double? customDeliveryFee;
  final bool isActive;
  final String? notes;

  SellerOverride({
    required this.storeId,
    this.customCommissionPercent,
    this.customDeliveryFee,
    this.isActive = true,
    this.notes,
  });

  factory SellerOverride.fromMap(Map<String, dynamic> map) {
    return SellerOverride(
      storeId: map['storeId'] as String,
      customCommissionPercent:
          (map['customCommissionPercent'] as num?)?.toDouble(),
      customDeliveryFee: (map['customDeliveryFee'] as num?)?.toDouble(),
      isActive: map['isActive'] as bool? ?? true,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'customCommissionPercent': customCommissionPercent,
      'customDeliveryFee': customDeliveryFee,
      'isActive': isActive,
      'notes': notes,
    };
  }
}
