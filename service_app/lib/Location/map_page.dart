import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MapController _mapController = MapController();
  final TextEditingController _emailController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _otherUserLocation;
  List<Polyline> _polylines = [];
  double? _distance;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _trackedUserEmail;
  
  late StreamSubscription<Position> _positionStream;
  StreamSubscription<DocumentSnapshot>? _otherUserStream;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _otherUserStream?.cancel();
    _mapController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);
    await _checkLocationPermission();
    setState(() => _isLoading = false);
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Please enable location services in device settings');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are required');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied. Please enable in app settings');
      return;
    }

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _updateLocationInFirestore(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        if (_lastUpdateTime == null || 
            DateTime.now().difference(_lastUpdateTime!) > Duration(seconds: 1)) {
          _updateLocationInFirestore(position.latitude, position.longitude);
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
          _lastUpdateTime = DateTime.now();
        }
      });

    } catch (e) {
      _showSnackBar('Error getting location: ${e.toString()}');
    }
  }

  void _updateLocationInFirestore(double lat, double lng) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('user_locations').doc(user.uid).set({
        'email': user.email!.toLowerCase(),
        'latitude': lat,
        'longitude': lng,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _trackUserByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      setState(() {
        _isTracking = true;
        _trackedUserEmail = normalizedEmail;
        _isLoading = true;
      });

      final query = await _firestore.collection('user_locations')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showSnackBar('User not found or not sharing location');
        setState(() => _isLoading = false);
        return;
      }

      final doc = query.docs.first;
      _otherUserStream?.cancel();
      
      _otherUserStream = _firestore.collection('user_locations')
          .doc(doc.id)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final lat = data['latitude'] as double;
          final lng = data['longitude'] as double;
          
          // Validate location data
          if (lat.isFinite && lng.isFinite) {
            setState(() {
              _otherUserLocation = LatLng(lat, lng);
              _updateDistance();
              _isLoading = false;
            });
            
            if (_currentLocation != null && _otherUserLocation != null) {
              try {
                final bounds = LatLngBounds.fromPoints([_currentLocation!, _otherUserLocation!]);
                if (bounds.isValid) {
                  _mapController.fitBounds(bounds, padding: EdgeInsets.all(50));
                }
              } catch (e) {
                print('Error fitting bounds: $e');
              }
            }
          }
        }
      });

      await _saveEmail(email);
    } catch (e) {
      _showSnackBar('Tracking error: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _updateDistance() {
    if (_currentLocation != null && 
        _otherUserLocation != null &&
        _currentLocation!.latitude.isFinite &&
        _currentLocation!.longitude.isFinite &&
        _otherUserLocation!.latitude.isFinite &&
        _otherUserLocation!.longitude.isFinite) {
      
      final distance = _calculateDistance(_currentLocation!, _otherUserLocation!);
      
      if (distance.isFinite && (_distance == null || (distance - _distance!).abs() > 0.01)) {
        setState(() {
          _distance = distance;
          _polylines = [
            Polyline(
              points: [_currentLocation!, _otherUserLocation!],
              strokeWidth: 4,
              color: Colors.blue,
            )
          ];
        });
      }
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const R = 6371.0;
    double dLat = (end.latitude - start.latitude) * (pi / 180);
    double dLon = (end.longitude - start.longitude) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * (pi / 180)) *
            cos(end.latitude * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tracked_email', email);
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('tracked_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
      _trackUserByEmail(savedEmail);
    }
  }

  void _showTrackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track User'),
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: "Enter user's email",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_emailController.text.isNotEmpty) {
                _trackUserByEmail(_emailController.text);
              }
            },
            child: const Text('Track'),
          ),
        ],
      ),
    );
  }

  void _stopTracking() {
    _otherUserStream?.cancel();
    setState(() {
      _isTracking = false;
      _trackedUserEmail = null;
      _otherUserLocation = null;
      _polylines = [];
      _distance = null;
    });
    _showSnackBar('Stopped tracking');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(23.8103, 90.4125), // Default to Dhaka
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_polylines.isNotEmpty)
                PolylineLayer(polylines: _polylines),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.person_pin, color: Colors.blue, size: 40),
                    ),
                  if (_otherUserLocation != null)
                    Marker(
                      point: _otherUserLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.person_pin, color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          if (_currentLocation == null && !_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Location Access Required'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initLocation,
                    child: const Text('ENABLE LOCATION'),
                  ),
                ],
              ),
            ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _showTrackDialog,
                  child: const Icon(Icons.search),
                ),
                const SizedBox(height: 10),
                if (_isTracking)
                  FloatingActionButton(
                    onPressed: _stopTracking,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.stop),
                  ),
              ],
            ),
          ),

          if (_distance != null)
            Positioned(
              top: 70,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking: $_trackedUserEmail',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Distance: ${_distance!.toStringAsFixed(2)} km',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension MapControllerExtensions on MapController {
  void fitBounds(LatLngBounds bounds, {EdgeInsets padding = EdgeInsets.zero}) {
    if (!bounds.isValid) return;
    
    final center = bounds.center;
    final zoom = _getZoomLevelForBounds(bounds, padding);
    
    if (zoom.isFinite) {
      move(center, zoom);
    }
  }
  
  double _getZoomLevelForBounds(LatLngBounds bounds, EdgeInsets padding) {
    final width = bounds.east - bounds.west;
    final height = bounds.north - bounds.south;
    
    if (width.isNaN || height.isNaN || width.isInfinite || height.isInfinite) {
      return 13.0;
    }
    
    final maxDimension = max(width, height);
    double zoom = 16 - log(maxDimension * 1000) / log(2);
    return zoom.clamp(1.0, 18.0);
  }
}

class LatLngBounds {
  final LatLng northeast;
  final LatLng southwest;

  LatLngBounds({required this.northeast, required this.southwest});

  factory LatLngBounds.fromPoints(List<LatLng> points) {
    if (points.isEmpty) throw ArgumentError('Points list cannot be empty');
    
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      northeast: LatLng(maxLat, maxLng),
      southwest: LatLng(minLat, minLng),
    );
  }

  LatLng get center {
    return LatLng(
      (northeast.latitude + southwest.latitude) / 2,
      (northeast.longitude + southwest.longitude) / 2,
    );
  }

  double get east => northeast.longitude;
  double get west => southwest.longitude;
  double get north => northeast.latitude;
  double get south => southwest.latitude;
  
  bool get isValid {
    return northeast.latitude.isFinite &&
           northeast.longitude.isFinite &&
           southwest.latitude.isFinite &&
           southwest.longitude.isFinite &&
           northeast.latitude >= -90 &&
           northeast.latitude <= 90 &&
           southwest.latitude >= -90 &&
           southwest.latitude <= 90 &&
           northeast.longitude >= -180 &&
           northeast.longitude <= 180 &&
           southwest.longitude >= -180 &&
           southwest.longitude <= 180;
  }
}