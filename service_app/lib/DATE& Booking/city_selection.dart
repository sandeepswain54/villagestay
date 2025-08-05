import 'package:flutter/material.dart';
import 'package:service_app/DATE&%20Booking/date_selection.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  final List<String> cities = const [
    "Hyderabad", "Delhi", "Gurgaon", "Bangalore", "Mysore", 
    "Mumbai", "Navi Mumbai", "Chandigarh", "Jaipur", "Chennai", "Lucknow",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select City")),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(cities[index]),
          trailing: const Text("City"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DateSelectionScreen(city: cities[index], locationId: '', locationName: '', locationType: '', state: '',),
              ),
            );
          },
        ),
      ),
    );
  }
}