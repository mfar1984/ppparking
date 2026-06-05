import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingSpot {
  final String id;
  final String name;
  final LatLng position;
  final String type; // 'kereta', 'motosikal', 'oku'
  final String address;

  ParkingSpot({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    required this.address,
  });
}
