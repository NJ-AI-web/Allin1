enum RideStatus {
  searching,
  captainAssigned,
  arriving,
  inProgress,
  completed,
  cancelled,
}

class RideModel {
  // Original fields
  final String? id;
  final String? customerId;
  final String? captainId;
  final String? pickupLocation;
  final String? dropLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropLatitude;
  final double? dropLongitude;
  final double? fare;
  String? status;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Booking screen fields
  final String? rideId;
  final String? pickupAddress;
  final String? dropAddress;
  double? estimatedFare;
  final double? distanceKm;
  final int? etaMinutes;

  // Captain fields (set when captain found)
  String? captainName;
  String? captainBikeNumber;
  String? captainPhone;
  double? captainRating;
  double? captainLat;
  double? captainLng;

  RideModel({
    this.id,
    this.customerId,
    this.captainId,
    this.pickupLocation,
    this.dropLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
    this.fare,
    this.status,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
    // Booking screen fields
    this.rideId,
    this.pickupAddress,
    this.dropAddress,
    this.estimatedFare,
    this.distanceKm,
    this.etaMinutes,
    // Captain fields
    this.captainName,
    this.captainBikeNumber,
    this.captainPhone,
    this.captainRating,
    this.captainLat,
    this.captainLng,
  });

  // Fare calculation: Base fare ₹25 + ₹12 per km
  static double calculateFare(double distanceKm) {
    const double baseFare = 25;
    const double perKm = 12;
    return baseFare + (distanceKm * perKm);
  }

  // Get status as display string
  String get statusDisplay {
    switch (status) {
      case 'searching':
        return 'Searching for captain...';
      case 'captain_assigned':
        return 'Captain Assigned';
      case 'arriving':
        return 'Captain Arriving';
      case 'in_progress':
        return 'Ride in Progress';
      case 'completed':
        return 'Ride Completed';
      case 'cancelled':
        return 'Ride Cancelled';
      default:
        return 'Unknown';
    }
  }
}
