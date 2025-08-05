import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePlacesScreen extends StatefulWidget {
  const HomePlacesScreen({super.key});

  @override
  State<HomePlacesScreen> createState() => _HomePlacesScreenState();
}

class _HomePlacesScreenState extends State<HomePlacesScreen> {
 
      String _currentAddress = "Fetching location...";
  StreamSubscription<Position>? _positionStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // newly added 
  String _selectedCity = "Hyderabad"; // default city


  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }



  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // Start real-time location updates
  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentAddress = "Location services disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentAddress = "Permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _currentAddress = "Permission permanently denied");
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((Position position) async {
      await _getAddressFromLatLng(position.latitude, position.longitude);
    });
  }

  // Get address from coordinates (OpenStreetMap)
  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'FlutterApp'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String displayName = data["display_name"] ?? "Unknown location";
        setState(() {
          _currentAddress = displayName;
        });
      } else {
        setState(() => _currentAddress = "Unable to fetch location");
      }
    } catch (e) {
      setState(() => _currentAddress = "Error fetching location");
    }
  }

  // Open bottom sheet for searching location
  void _openLocationSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        TextEditingController searchController = TextEditingController();
        List<dynamic> searchResults = [];

        void searchLocation(String query) async {
          if (query.isEmpty) return;
          final url =
              "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5";
          final response = await http.get(Uri.parse(url), headers: {
            'User-Agent': 'FlutterApp'
          });
          if (response.statusCode == 200) {
            setState(() {
              searchResults = jsonDecode(response.body);
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 400,
                child: Column(
                  children: [
                    const Text(
                      "Search Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Enter location",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) async {
  final url =
      "https://nominatim.openstreetmap.org/search?q=$value&format=json&addressdetails=1&limit=5";
  final response = await http.get(Uri.parse(url), headers: {
    'User-Agent': 'FlutterApp'
  });
  if (response.statusCode == 200) {
    setModalState(() {  // <-- USE THIS instead of setState
      searchResults = jsonDecode(response.body);
    });
  }
},

                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final place = searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(place["display_name"]),
                            onTap: () {
                             setState(() {
  _currentAddress = place["display_name"];
  String city = place["address"]["city"] ??
      place["address"]["town"] ??
      place["address"]["village"] ??
      place["address"]["state_district"] ??
      "Unknown";
  _selectedCity = city.split(",").first.trim(); // Take first part (e.g., "Puri")
});
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // new widget added to build place cards

 Widget _buildPlaceCard({required String name, required String imageUrl}) {
  bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;
  
  return Column(
    children: [
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: isValidUrl
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            : const Icon(Icons.image),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 70,
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildErrorIcon() {
  return const Center(
    child: Icon(Icons.image_not_supported, color: Colors.grey),
  );
}

  // Build Firestore destinations
Widget _buildFirestoreDestinations() {
  return SizedBox(
    height: 120,
    child: StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('popular_places')
          .doc(_selectedCity) // Use the selected city here
          .collection('places')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading places');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No places found in $_selectedCity');
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildPlaceCard(
                name: data['name']?.toString() ?? 'Unnamed',
                imageUrl: data['image']?.toString() ?? '',
              ),
            );
          },
        );
      },
    ),
  );
}
  // Firestore destination widget
Widget _buildFirestoreDestination(String imageUrl, String title) {
  // Validate the URL before using it
  bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;
  
  return Container(
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: isValidUrl 
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                )
              : _buildPlaceholderIcon(),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            title,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    ),
  );
}

Widget _buildPlaceholderIcon() {
  return Container(
    width: 70,
    height: 70,
    color: Colors.grey[200],
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar
              Container(
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _openLocationSearch,
                          child: SizedBox(
                            width: 200,
                            child: Row(
                              children: [
                                const Icon(Icons.edit_location_alt,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _currentAddress,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search activities",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Categories
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCategory(Icons.sailing, "Activities"),
                        _buildCategory(Icons.flight, "Flights"),
                        _buildCategory(Icons.directions_bus, "Bus Ticket"),
                        _buildCategory(Icons.public, "Intl Flights"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.grid_view, color: Colors.red),
                          SizedBox(width: 8),
                          Text("All Categories",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Top Destinations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Top destinations",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFirestoreDestinations(), // Use the Firestore widget here
            ],
          ),
        ),
      ),
    );
  }

  // Category Widget
  Widget _buildCategory(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.red, size: 30),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}