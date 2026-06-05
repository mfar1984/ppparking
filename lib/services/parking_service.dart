import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/parking_spot.dart';

class ParkingService {
  Future<List<ParkingSpot>> fetchParkingSpots() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      ParkingSpot(
        id: 'c1',
        name: 'Car Parking 1',
        position: const LatLng(5.402696, 100.329480),
        type: 'car',
        address: 'Jelutong, Penang',
      ),
      ParkingSpot(
        id: 'c2',
        name: 'Car Parking 2',
        position: const LatLng(5.402722, 100.329491),
        type: 'car',
        address: 'Jelutong, Penang',
      ),
      ParkingSpot(
        id: 'c3',
        name: 'Car Parking 3',
        position: const LatLng(5.402739, 100.329505),
        type: 'car',
        address: 'Jelutong, Penang',
      ),
      ParkingSpot(
        id: 'm1',
        name: 'Motorcycle Parking 1',
        position: const LatLng(5.399757, 100.331554),
        type: 'motorcycle',
        address: 'Hume Marketing, Lebuh Sungai Pinang 6',
      ),
      ParkingSpot(
        id: 'o1',
        name: 'Disabled Parking 1',
        position: const LatLng(5.399051, 100.330798),
        type: 'disabled',
        address: '18, Karpal Singh Dr, Penang',
      ),
      ParkingSpot(
        id: 'o2',
        name: 'Disabled Parking 2',
        position: const LatLng(5.399009, 100.330759),
        type: 'disabled',
        address: '18, Karpal Singh Dr, Penang',
      ),
    ];
  }
}
