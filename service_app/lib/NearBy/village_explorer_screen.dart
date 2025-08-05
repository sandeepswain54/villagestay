import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';
import 'map_service.dart';

class VillageExplorerScreen extends StatefulWidget {
  const VillageExplorerScreen({super.key});

  @override
  State<VillageExplorerScreen> createState() => _VillageExplorerScreenState();
}

class _VillageExplorerScreenState extends State<VillageExplorerScreen> {
  Position? _currentPosition;
  bool _loading = false;
  bool _showVillages = false;
  List<dynamic> _nearbyVillages = [];
  List<Map<String, String>> _villageImages = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _getNearbyVillages() async {
    if (_currentPosition == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final villages = await MapService.getNearbyVillages(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
      
      setState(() {
        _nearbyVillages = villages;
        _showVillages = true;
        _loading = false;
      });
      
      await _getVillageImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching villages: $e')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _getVillageImages() async {
    try {
      List<Map<String, String>> allImages = [];
      
      for (var village in _nearbyVillages.take(5)) {
        final name = village['tags']['name'] ?? '';
        if (name.isNotEmpty) {
          final images = await MapService.getVillageImages(name);
          allImages.addAll(images);
        }
      }
      
      setState(() {
        _villageImages = allImages;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Current Location Display
                if (_currentPosition != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showVillages = !_showVillages;
                        if (_showVillages && _nearbyVillages.isEmpty) {
                          _getNearbyVillages();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[50],
                      child: Column(
                        children: [
                          const Text(
                            'Your Current Location',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                            'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showVillages
                                ? '▼ Nearby villages loaded ▼'
                                : '▲ Click to see nearby villages ▲',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Main Content Area
                Expanded(
                  child: _showVillages && _nearbyVillages.isNotEmpty
                      ? _buildVillageContent()
                      : _buildInitialContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildInitialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Discover nearby villages',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Click on your location above to explore'),
          const SizedBox(height: 24),
          if (_currentPosition == null)
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Get My Location'),
            ),
        ],
      ),
    );
  }

  Widget _buildVillageContent() {
    return Column(
      children: [
        // Map Section
        Expanded(
          flex: 2,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.village_explorer',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  ..._nearbyVillages.map((village) {
                    double lat = village['lat'] ?? village['center']['lat'];
                    double lon = village['lon'] ?? village['center']['lon'];
                    return Marker(
                      width: 30.0,
                      height: 30.0,
                      point: LatLng(lat, lon),
                      child: const Icon(
                        Icons.villa,
                        color: Colors.green,
                        size: 30,
                      ),
                    );
                  }).toList(),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Village Images Section
        if (_villageImages.isNotEmpty)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _villageImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 120,
                        child: CachedNetworkImage(
                          imageUrl: _villageImages[index]['imageUrl']!,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        _villageImages[index]['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        // Village List Section
        Expanded(
          child: ListView.builder(
            itemCount: _nearbyVillages.length,
            itemBuilder: (context, index) {
              final village = _nearbyVillages[index];
              final name = village['tags']['name'] ?? 'Unknown Village';
              double lat = village['lat'] ?? village['center']['lat'];
              double lon = village['lon'] ?? village['center']['lon'];
              
              return ListTile(
                leading: const Icon(Icons.villa, color: Colors.green),
                title: Text(name),
                subtitle: Text('Lat: ${lat.toStringAsFixed(4)}, Lng: ${lon.toStringAsFixed(4)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () async {
                    final url = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=16/$lat/$lon');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch map')),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}