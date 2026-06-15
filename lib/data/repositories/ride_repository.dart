import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/enums.dart';
import '../models/ride.dart';
import '../models/tariff.dart';

/// Contract for the ride lifecycle - the shared core between Passenger and
/// Driver apps. Backed by Firestore (realtime) or a mock source.
abstract interface class RideRepository {
  Future<String> createRide({
    required Ride ride,
    required List<LatLng> routePoints,
    String? passengerPhone,
    String? passengerName,
  });

  // Stream<Ride> watchRide(String rideId);
  // Future<void> acceptRide(String rideId, String driverId);
  // Future<void> updateStatus(String rideId, RideStatus status);
  // Future<void> cancelRide(String rideId);
}

class FirebaseRideRepository implements RideRepository {
  FirebaseRideRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<String> createRide({
    required Ride ride,
    required List<LatLng> routePoints,
    String? passengerPhone,
    String? passengerName,
  }) async {
    final doc = _firestore.collection('rides').doc(ride.id);
    final firebaseUser = _auth.currentUser;
    final phone = passengerPhone ?? firebaseUser?.phoneNumber;

    await doc.set({
      'passengerId': firebaseUser?.uid ?? ride.passengerId,
      'passengerName': passengerName,
      'passengerPhone': phone,
      'driverId': null,
      'status': _rideStatusId(ride.status),
      'pickupLat': ride.origin.lat,
      'pickupLng': ride.origin.lng,
      'pickupAddress': ride.origin.fullText,
      'pickupTitle': ride.origin.titleRu,
      'pickupTitleKk': ride.origin.titleKk,
      'destinationLat': ride.destination.lat,
      'destinationLng': ride.destination.lng,
      'destinationAddress': ride.destination.fullText,
      'destinationTitle': ride.destination.titleRu,
      'destinationTitleKk': ride.destination.titleKk,
      'tariffId': _tierId(ride.tier),
      'tariffName': ride.tier.titleRu,
      'tariffNameKk': ride.tier.titleKk,
      'price': ride.priceTenge,
      'distanceKm': ride.distanceKm,
      'durationMin': ride.durationMin,
      'paymentStatus': 'unpaid',
      'paymentType': _paymentTypeId(ride.paymentType),
      'paymentLabel': ride.paymentLabel,
      'routePolyline': routePoints.map(_latLngToJson).toList(),
      'routePointCount': routePoints.length,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Map<String, double> _latLngToJson(LatLng point) => {
        'lat': point.latitude,
        'lng': point.longitude,
      };

  String _rideStatusId(RideStatus status) {
    return switch (status) {
      RideStatus.idle => 'idle',
      RideStatus.searching => 'searching',
      RideStatus.driverAssigned => 'driverAssigned',
      RideStatus.accepted => 'accepted',
      RideStatus.enRoute => 'enRoute',
      RideStatus.arrived => 'arrived',
      RideStatus.inProgress => 'inProgress',
      RideStatus.completed => 'completed',
      RideStatus.paid => 'paid',
      RideStatus.rated => 'rated',
      RideStatus.cancelled => 'cancelled',
    };
  }

  String _tierId(RideTier tier) {
    return switch (tier) {
      RideTier.economy => 'economy',
      RideTier.comfort => 'comfort',
      RideTier.business => 'business',
    };
  }

  String _paymentTypeId(PaymentType type) {
    return switch (type) {
      PaymentType.card => 'card',
      PaymentType.cash => 'cash',
      PaymentType.kaspi => 'kaspi',
      PaymentType.multicard => 'multicard',
    };
  }
}

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return FirebaseRideRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
