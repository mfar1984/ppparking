import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking_spot.dart';
import '../services/parking_service.dart';

class FindParkingScreen extends StatefulWidget {
  const FindParkingScreen({super.key});

  @override
  State<FindParkingScreen> createState() => _FindParkingScreenState();
}

class _FindParkingScreenState extends State<FindParkingScreen> {
  late GoogleMapController mapController;
  final ParkingService _parkingService = ParkingService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ParkingSpot> _allSpots = [];
  bool _isLoading = true;
  bool _isNavigating = false;
  String _selectedFilter = 'All';
  ParkingSpot? _selectedSpot;
  
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyAOoht4XpGA921iHdm81kaPTVXxeDXI9zk";
  BitmapDescriptor? _carIcon;

  final LatLng _initialPosition = const LatLng(5.402, 100.331);
  LatLng _mockUserLocation = const LatLng(5.398353, 100.328436); // Updated to Lebuh Sungai Pinang 6

  // Search related
  List<dynamic> _placePredictions = [];
  Timer? _debounce;
  Marker? _searchMarker;

  @override
  void initState() {
    super.initState();
    _loadParkingSpots();
    _createCarMarker();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _createCarMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const size = Size(100, 100);
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.3)..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5);
    final path = Path();
    path.moveTo(50, 10); path.lineTo(85, 90); path.lineTo(50, 75); path.lineTo(15, 90); path.close();
    canvas.save(); canvas.translate(2, 4); canvas.drawPath(path, shadowPaint); canvas.restore();
    final paint = Paint()..shader = ui.Gradient.linear(const Offset(50, 10), const Offset(50, 90), [const Color(0xFF4285F4), const Color(0xFF1A73E8)]);
    canvas.drawPath(path, paint);
    final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawPath(path, borderPaint);
    final image = await pictureRecorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) setState(() => _carIcon = BitmapDescriptor.fromBytes(data.buffer.asUint8List()));
  }

  Future<void> _loadParkingSpots() async {
    final spots = await _parkingService.fetchParkingSpots();
    setState(() {
      _allSpots = spots;
      _isLoading = false;
    });
  }

  // --- Search Logic ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _autoCompleteSearch(query);
      } else {
        setState(() => _placePredictions = []);
      }
    });
  }

  Future<void> _autoCompleteSearch(String query) async {
    String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleAPiKey&location=5.402,100.331&radius=5000";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _placePredictions = json.decode(response.body)['predictions'];
      });
    }
  }

  Future<void> _getPlaceDetails(String placeId, String description) async {
    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleAPiKey";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var result = json.decode(response.body)['result'];
      var lat = result['geometry']['location']['lat'];
      var lng = result['geometry']['location']['lng'];
      LatLng destination = LatLng(lat, lng);

      setState(() {
        _searchController.text = description;
        _placePredictions = [];
        _searchMarker = Marker(
          markerId: const MarkerId('searched_place'),
          position: destination,
          infoWindow: InfoWindow(title: description),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        _selectedSpot = null;
        _polylines.clear();
      });

      mapController.animateCamera(CameraUpdate.newLatLngZoom(destination, 16.0));
      
      // Focus on this destination and show nearby parking
      _fitToPlaceAndParking(destination);
    }
  }

  void _fitToPlaceAndParking(LatLng destination) {
    // Find parking within reasonable distance
    double minLat = destination.latitude;
    double minLng = destination.longitude;
    double maxLat = destination.latitude;
    double maxLng = destination.longitude;

    // Expand bounds to include nearest few parking spots
    for (var spot in _allSpots) {
      double dist = Geolocator.distanceBetween(destination.latitude, destination.longitude, spot.position.latitude, spot.position.longitude);
      if (dist < 1000) { // 1km radius
        if (spot.position.latitude < minLat) minLat = spot.position.latitude;
        if (spot.position.latitude > maxLat) maxLat = spot.position.latitude;
        if (spot.position.longitude < minLng) minLng = spot.position.longitude;
        if (spot.position.longitude > maxLng) maxLng = spot.position.longitude;
      }
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
      70,
    ));
  }

  List<ParkingSpot> get _filteredSpots {
    if (_selectedFilter == 'All') return _allSpots;
    return _allSpots.where((s) => s.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Parking', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadParkingSpots),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15.0),
            markers: {
              if (!_isNavigating) ..._filteredSpots.map((spot) {
                return Marker(
                  markerId: MarkerId(spot.id),
                  position: spot.position,
                  infoWindow: InfoWindow(title: spot.name, snippet: spot.address),
                  icon: _getMarkerIcon(spot.type),
                  onTap: () => setState(() { _selectedSpot = spot; _polylines.clear(); }),
                );
              }),
              if (_searchMarker != null && !_isNavigating) _searchMarker!,
              if (_isNavigating && _selectedSpot != null)
                Marker(
                  markerId: MarkerId(_selectedSpot!.id),
                  position: _selectedSpot!.position,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              Marker(
                markerId: const MarkerId('current_location'),
                position: _mockUserLocation,
                infoWindow: _isNavigating ? InfoWindow.noText : const InfoWindow(title: 'Your Location'),
                rotation: _isNavigating ? 30.0 : 0, 
                flat: _isNavigating,
                anchor: const Offset(0.5, 0.5),
                icon: _isNavigating 
                  ? (_carIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)) 
                  : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            tiltGesturesEnabled: true,
          ),
          
          // Search Bar
          if (!_isNavigating)
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search destination...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF0054A6)),
                        suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                              _searchController.clear();
                              setState(() { _placePredictions = []; _searchMarker = null; });
                            }) 
                          : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  if (_placePredictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _placePredictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.grey),
                            title: Text(_placePredictions[index]['description']),
                            onTap: () => _getPlaceDetails(_placePredictions[index]['place_id'], _placePredictions[index]['description']),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Navigation Top Banner
          if (_isNavigating)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: const BoxDecoration(color: Color(0xFF004D40), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                child: Row(
                  children: [
                    const Icon(Icons.navigation_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 15),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text('Jln Lebuh Sungai Pinang', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Head north toward destination', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ])),
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                  ],
                ),
              ),
            ),

          // Filter Chips (Hide when search predictions or navigation active)
          if (!_isNavigating && _placePredictions.isEmpty)
            Positioned(
              top: 75, left: 0, right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('All'), const SizedBox(width: 8),
                    _filterChip('Car'), const SizedBox(width: 8),
                    _filterChip('Motorcycle'), const SizedBox(width: 8),
                    _filterChip('Disabled'),
                  ],
                ),
              ),
            ),

          // Selected Spot Card
          if (_selectedSpot != null && !_isNavigating)
            Positioned(
              bottom: 20, left: 16, right: 16,
              child: Card(
                elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_selectedSpot!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(_selectedSpot!.address, style: const TextStyle(color: Colors.grey)),
                          ])),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _selectedSpot = null; _polylines.clear(); }))
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _typeBadge(_selectedSpot!.type),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _startNavigation(_selectedSpot!),
                            icon: const Icon(Icons.directions), label: const Text('Go There'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0054A6), foregroundColor: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

          // Navigation Bottom Banner
          if (_isNavigating)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
                decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)], borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                child: Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      const Text('3 min', style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('1.2 km • Arriving', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ])),
                    const Icon(Icons.alt_route, color: Colors.grey, size: 28),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _exitNavigation,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isNavigating ? null : FloatingActionButton(
        onPressed: _goToNearest,
        backgroundColor: Colors.white,
        child: const Icon(Icons.near_me, color: Color(0xFF0054A6)),
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label), selected: isSelected,
      onSelected: (selected) {
        setState(() { _selectedFilter = label; _selectedSpot = null; _polylines.clear(); });
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitMarkers());
      },
      selectedColor: const Color(0xFF0054A6),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }

  Widget _typeBadge(String type) {
    Color color; IconData icon; String label;
    switch (type.toLowerCase()) {
      case 'motorcycle': color = Colors.orange; icon = Icons.motorcycle; label = 'MOTORCYCLE'; break;
      case 'disabled': color = Colors.blue; icon = Icons.accessible; label = 'DISABLED'; break;
      default: color = Colors.green; icon = Icons.directions_car; label = 'CAR';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]),
    );
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motorcycle': return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'disabled': return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      default: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<void> _startNavigation(ParkingSpot spot) async {
    setState(() => _isNavigating = true);
    await _getPolyline(spot);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _mockUserLocation, zoom: 18.0, tilt: 60.0, bearing: 30.0)));
  }

  void _exitNavigation() {
    setState(() { _isNavigating = false; _polylines.clear(); _selectedSpot = null; });
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _initialPosition, zoom: 15.0, tilt: 0, bearing: 0)));
  }

  Future<void> _getPolyline(ParkingSpot spot) async {
    polylineCoordinates.clear();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKey,
      request: PolylineRequest(
        origin: PointLatLng(_mockUserLocation.latitude, _mockUserLocation.longitude),
        destination: PointLatLng(spot.position.latitude, spot.position.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    }
    setState(() {
      _polylines.add(Polyline(polylineId: const PolylineId("poly"), color: const Color(0xFF0054A6), points: polylineCoordinates, width: 5));
    });
    _fitRoute();
  }

  void _fitRoute() {
    if (polylineCoordinates.isEmpty) return;
    double minLat = polylineCoordinates.first.latitude; double minLng = polylineCoordinates.first.longitude;
    double maxLat = polylineCoordinates.first.latitude; double maxLng = polylineCoordinates.first.longitude;
    for (var point in polylineCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude; if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude; if (point.longitude > maxLng) maxLng = point.longitude;
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 50));
  }

  void _fitMarkers() {
    if (_filteredSpots.isEmpty) return;
    double minLat = _filteredSpots.first.position.latitude; double minLng = _filteredSpots.first.position.longitude;
    double maxLat = _filteredSpots.first.position.latitude; double maxLng = _filteredSpots.first.position.longitude;
    for (var spot in _filteredSpots) {
      if (spot.position.latitude < minLat) minLat = spot.position.latitude; if (spot.position.latitude > maxLat) maxLat = spot.position.latitude;
      if (spot.position.longitude < minLng) minLng = spot.position.longitude; if (spot.position.longitude > maxLng) maxLng = spot.position.longitude;
    }
    if (_mockUserLocation.latitude < minLat) minLat = _mockUserLocation.latitude; if (_mockUserLocation.latitude > maxLat) maxLat = _mockUserLocation.latitude;
    if (_mockUserLocation.longitude < minLng) minLng = _mockUserLocation.longitude; if (_mockUserLocation.longitude > maxLng) maxLng = _mockUserLocation.longitude;
    mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 80));
  }

  Future<void> _goToNearest() async {
    double minDistance = double.infinity; ParkingSpot? nearest;
    for (var spot in _allSpots) {
      double distance = Geolocator.distanceBetween(_mockUserLocation.latitude, _mockUserLocation.longitude, spot.position.latitude, spot.position.longitude);
      if (distance < minDistance) { minDistance = distance; nearest = spot; }
    }
    if (nearest != null) {
      setState(() => _selectedSpot = nearest);
      _getPolyline(nearest);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Found nearest parking: ${nearest.name}')));
    }
  }
}
