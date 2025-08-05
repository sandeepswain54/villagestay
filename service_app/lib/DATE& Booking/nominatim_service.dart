import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimService {
  static Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?'
          'format=json&'
          'q=$query&'
          'countrycodes=in&' // Restrict to India
          'addressdetails=1&'
          'limit=5&' // Limit to 5 results
          'featuretype=city' // Only cities
        ),
        headers: {
          'User-Agent': 'YourAppName/1.0 (your@email.com)', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) {
          return {
            'id': item['osm_id'].toString(),
            'name': _extractCityName(item),
            'state': item['address']['state'] ?? 'India',
            'type': 'city',
          };
        }).toList();
      }
      throw Exception('Failed with status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  static String _extractCityName(dynamic item) {
    // Try to get the best display name
    if (item['name'] != null) return item['name'];
    if (item['display_name'] != null) {
      return item['display_name'].split(',').first;
    }
    return 'Unknown City';
  }
}