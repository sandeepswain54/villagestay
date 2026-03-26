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
  String _selectedCity = "Hyderabad"; // default city
  final ScrollController _scrollController = ScrollController();
  int _currentOfferIndex = 0;
  Timer? _carouselTimer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _startCarouselAutoPlay();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _scrollController.dispose();
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarouselAutoPlay() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _firestore.collection('offers').get().then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            int nextIndex = (_currentOfferIndex + 1) % snapshot.docs.length;
            _pageController.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            );
            setState(() {
              _currentOfferIndex = nextIndex;
            });
          }
        });
      }
    });
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        final response = await http.get(Uri.parse(url),
                            headers: {'User-Agent': 'FlutterApp'});
                        if (response.statusCode == 200) {
                          setModalState(() {
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
                                _selectedCity =
                                    city.split(",").first.trim();
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

  // Offers Carousel (Top banners)
  Widget _buildOffersCarousel() {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('offers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Error loading offers');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('No offers available', style: TextStyle(color: Colors.grey)),
              ),
            );
          }

          final offers = snapshot.data!.docs;
          
          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: offers.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentOfferIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final doc = offers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: data['image'] ?? '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) =>
                                Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, size: 50),
                                ),
                          ),
                          if (data['title'] != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  data['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(offers.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentOfferIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Category chips
  Widget _buildCategoryChips() {
    final categories = ['All', 'Adventure', 'Cultural', 'Nature', 'Food', 'Relaxation'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categories[index]),
              selected: index == 0, // First item selected by default
              onSelected: (bool selected) {
                // Handle category selection
              },
              selectedColor: Colors.red[100],
              labelStyle: TextStyle(
                color: index == 0 ? Colors.red : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build Firestore activity cards like in the image
  Widget _buildFirestoreActivityCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('activities')
          .doc(_selectedCity)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading activities');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.explore_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text('No activities found in $_selectedCity', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        final activities = snapshot.data!.docs;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final doc = activities[index];
            final data = doc.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                // Navigate to activity details
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: data['image'] ?? '',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) =>
                                Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, size: 40),
                                ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    (data['rating'] ?? 0).toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title & location
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'Unnamed',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  data['location'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "NPR ${data['price'] ?? '0'}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Top Bar
            SliverAppBar(
              backgroundColor: Colors.red,
              expandedHeight: 60,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: GestureDetector(
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
                            maxLines: 1,
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
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    // Navigate to notifications
                  },
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search activities",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // Offers Carousel
            SliverToBoxAdapter(
              child: _buildOffersCarousel(),
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 20),
            ),

            // Category Chips
            SliverToBoxAdapter(
              child: _buildCategoryChips(),
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 16),
            ),

            // Explore Activities Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Explore Activities",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all activities
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 12),
            ),

            // Activity Cards Grid
            SliverToBoxAdapter(
              child: _buildFirestoreActivityCards(),
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 20),
            ),
            
            // Popular Destinations Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Popular Destinations",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all destinations
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 12),
            ),
            
            // Popular Destinations List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Container(
                              width: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.place, size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Popular Destination",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 30),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}