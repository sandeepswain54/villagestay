import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:service_app/model/village_model.dart';
import 'package:service_app/model/village_category.dart';
import 'package:service_app/CORE/utils/json_loader.dart';
import 'package:service_app/NearBy/location_service.dart';
import 'package:service_app/NearBy/services/saved_villages_service.dart';
import 'package:service_app/NearBy/village_detail_screen.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> with AutomaticKeepAliveClientMixin {
  // State variables
  LatLng? _userLocation;
  String _selectedDistrict = 'Puri';
  VillageCategory _selectedCategory = VillageCategory.discover;
  List<Village> _allVillages = [];
  List<Village> _filteredVillages = [];
  List<Village> _savedVillages = [];
  bool _isLoading = true;
  bool _isMapLoading = true;
  MapController _mapController = MapController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndVillages();
  }

  Future<void> _initializeLocationAndVillages() async {
    try {
      // Get user's current location and district
      final position = await LocationService.getCurrentLocation();
      final district = await LocationService.getCurrentDistrict();

      // Load villages JSON
      final villages = await VillagesJsonLoader.getVillagesByDistrict(district);
      final savedVillages = await SavedVillagesService.getSavedVillages();

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _selectedDistrict = district;
        _allVillages = villages;
        _savedVillages = savedVillages;
        _isLoading = false;
        _isMapLoading = false;
        _filterVillagesByCategory();
      });

      // Add extra small delay to ensure map is ready before moving camera
      await Future.delayed(const Duration(milliseconds: 100));
      _moveMapToUserLocation();
    } catch (e) {
      print('Error initializing location and villages: $e');
      setState(() {
        _isLoading = false;
        _isMapLoading = false;
        _selectedDistrict = 'Puri';
      });
      // Load default district villages
      _loadVillagesByDistrict('Puri');
    }
  }

  Future<void> _loadVillagesByDistrict(String district) async {
    try {
      final villages = await VillagesJsonLoader.getVillagesByDistrict(district);
      setState(() {
        _selectedDistrict = district;
        _allVillages = villages;
        _filterVillagesByCategory();
      });
    } catch (e) {
      print('Error loading villages: $e');
    }
  }

  Future<void> _moveMapToUserLocation() async {
    try {
      _mapController.move(_userLocation!, 13.0);
    } catch (e) {
      print('Error moving map: $e');
    }
  }

  void _filterVillagesByCategory() {
    if (_selectedCategory == VillageCategory.saved) {
      _filteredVillages = _allVillages
          .where((v) => _savedVillages.any((sv) => sv.villageName == v.villageName))
          .toList();
    } else if (_selectedCategory == VillageCategory.discover) {
      _filteredVillages = _allVillages;
    } else {
      _filteredVillages = _allVillages
          .where((v) =>
              v.category.toLowerCase() == _selectedCategory.displayName.toLowerCase())
          .toList();
    }
  }

  void _onCategorySelected(VillageCategory category) {
    setState(() {
      _selectedCategory = category;
      _filterVillagesByCategory();
    });
  }

  Future<void> _toggleSaveVillage(Village village) async {
    final isSaved = await SavedVillagesService.isVillageSaved(village.villageName);

    if (isSaved) {
      await SavedVillagesService.removeVillage(village.villageName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Village removed from saved'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await SavedVillagesService.saveVillage(village);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Village saved!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Refresh saved villages
    final savedVillages = await SavedVillagesService.getSavedVillages();
    setState(() {
      _savedVillages = savedVillages;
      if (_selectedCategory == VillageCategory.saved) {
        _filterVillagesByCategory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Section
                  _buildMapSection(),
                  const SizedBox(height: 16),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Explore villages near you',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  // Village Cards
                  _buildVillageCards(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: _isMapLoading || _userLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? const LatLng(19.8047, 85.8345),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    // User location marker
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.my_location,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    // Village markers
                    ..._getVillageMarkers(),
                  ],
                ),
              ],
            ),
    );
  }

  List<Marker> _getVillageMarkers() {
    return _filteredVillages.isEmpty ? [] : _filteredVillages.asMap().entries.map((entry) {
      final village = entry.value;
      final index = entry.key;
      
      // Create marker position - offset from district center to avoid overlap
      final districtCenter =
          LocationService.districtCenters[_selectedDistrict] ??
              const LatLng(19.8047, 85.8345);
      
      // Spread villages in a grid around district center
      final offsetLat = districtCenter.latitude + (index % 3) * 0.1 - 0.1;
      final offsetLon = districtCenter.longitude + (index ~/ 3) * 0.1 - 0.1;
      final markerPosition = LatLng(offsetLat, offsetLon);

      // Get category color
      final categoryColor = _getCategoryColor(village.category);

      return Marker(
        point: markerPosition,
        width: 40,
        height: 50,
        child: GestureDetector(
          onTap: () => _showVillageMarkerInfo(village),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  village.category.length > 3
                      ? village.category.substring(0, 3)
                      : village.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showVillageMarkerInfo(Village village) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              village.villageName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${village.category}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Distance: ${village.approxDistanceFromDistrictHqKm} km from district HQ',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.to(
                  () => VillageDetailScreen(village: village, district: _selectedDistrict),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: VillageCategoryHelper.getAllCategories().map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (_) => _onCategorySelected(category),
              backgroundColor: Colors.grey.shade200,
              selectedColor: _getCategoryColorForChip(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVillageCards() {
    if (_filteredVillages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No villages found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different category or district',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredVillages.length,
        itemBuilder: (context, index) {
          return _buildVillageCard(_filteredVillages[index]);
        },
      ),
    );
  }

  Widget _buildVillageCard(Village village) {
    final isSaved = _savedVillages.any((v) => v.villageName == village.villageName);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => VillageDetailScreen(village: village, district: _selectedDistrict),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey,
                  ),
                  child: village.images.isNotEmpty
                      ? Image.asset(
                          'assets/${village.images[0]}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey, size: 40),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 40),
                        ),
                ),
                // Heart button
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSaveVillage(village),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Title and info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          village.villageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCategoryColorForChip(
                          VillageCategoryHelper.fromString(village.category) ??
                              VillageCategory.discover),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      village.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    village.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${village.approxDistanceFromDistrictHqKm} km',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final categoryEnum = VillageCategoryHelper.fromString(category);
    if (categoryEnum == null) return Colors.purple;

    switch (categoryEnum) {
      case VillageCategory.discover:
        return Colors.green;
      case VillageCategory.saved:
        return Colors.red;
      case VillageCategory.tribal:
        return Colors.orange;
      case VillageCategory.craft:
        return Colors.purple;
      case VillageCategory.eco:
        return Colors.teal;
    }
  }

  Color _getCategoryColorForChip(VillageCategory category) {
    switch (category) {
      case VillageCategory.discover:
        return Colors.green;
      case VillageCategory.saved:
        return Colors.red;
      case VillageCategory.tribal:
        return Colors.orange;
      case VillageCategory.craft:
        return Colors.purple;
      case VillageCategory.eco:
        return Colors.teal;
    }
  }
}
