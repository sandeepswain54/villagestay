import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class LocationService {
  // Hardcoded district centers (major districts in India)
  static const Map<String, LatLng> districtCenters = {
    'Puri': LatLng(19.8047, 85.8345),
    'Odisha': LatLng(20.2961, 85.0886),
    'Telangana': LatLng(17.3588, 78.4740),
    'Kerala': LatLng(10.8505, 76.2711),
  };

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Get current district based on device location using reverse geocoding
  /// Falls back to 'Puri' if detection fails
  static Future<String> getCurrentDistrict() async {
    try {
      final position = await getCurrentLocation();
      final district = await reverseGeocodeToDistrict(
        LatLng(position.latitude, position.longitude),
      );
      return district;
    } catch (e) {
      print('Error detecting district: $e');
      return 'Puri'; // Default fallback
    }
  }

  /// Reverse geocode a position to district using Nominatim API
  static Future<String> reverseGeocodeToDistrict(LatLng position) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'UpyogiApp/1.0 (contact@upyogi.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Try to extract district information
          String? district = address['district'] ?? address['state'] ?? address['region'];

          if (district != null && district.isNotEmpty) {
            // Try to match with known districts
            for (var knownDistrict in districtCenters.keys) {
              if (district.toLowerCase().contains(knownDistrict.toLowerCase())) {
                return knownDistrict;
              }
            }
            return district;
          }
        }
      }

      return 'Puri'; // Default fallback
    } catch (e) {
      print('Error reverse geocoding: $e');
      return 'Puri'; // Default fallback
    }
  }

  /// Geocode a district name to LatLng coordinates
  static Future<LatLng?> geocodeDistrictCenter(String district) async {
    try {
      // Check if district is in hardcoded map
      if (districtCenters.containsKey(district)) {
        return districtCenters[district];
      }

      // Try Nominatim API as fallback
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$district&format=json&countrycodes=in&limit=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'UpyogiApp/1.0 (contact@upyogi.com)'},
      );

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List<dynamic>;

        if (results.isNotEmpty) {
          final location = results[0] as Map<String, dynamic>;
          final lat = double.tryParse(location['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(location['lon'].toString()) ?? 0.0;

          if (lat != 0.0 || lon != 0.0) {
            return LatLng(lat, lon);
          }
        }
      }

      return null;
    } catch (e) {
      print('Error geocoding district: $e');
      return null;
    }
  }

  /// Calculate distance between two LatLng points in kilometers
  /// Using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    const earthRadiusKm = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final dLon = _degreesToRadians(point2.longitude - point1.longitude);
    
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}