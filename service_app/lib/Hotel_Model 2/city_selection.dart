import 'package:flutter/material.dart';
import 'package:service_app/DATE&%20Booking/date_selection.dart';
import 'package:service_app/Hotel_Model%202/hotel_service.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  List<String> cities = [];
  List<String> filteredCities = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchController.addListener(_filterCities);
  }

  Future<void> _loadCities() async {
    final loadedCities = await HotelService.getCities();
    setState(() {
      cities = loadedCities;
      filteredCities = loadedCities;
    });
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCities = cities.where((city) => 
        city.toLowerCase().contains(query)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select City")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search cities...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(filteredCities[index]),
                trailing: const Text("City"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DateSelectionScreen(
                        city: filteredCities[index], locationId: '', locationName: '', locationType: '', state: '',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}