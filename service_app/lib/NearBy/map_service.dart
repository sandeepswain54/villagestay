import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapService {
  static Future<List<dynamic>> getNearbyVillages(LatLng position) async {
    final overpassUrl = Uri.parse('https://overpass-api.de/api/interpreter');
    final query = '''
      [out:json];
      (
        node["place"="village"](around:10000,${position.latitude},${position.longitude});
        way["place"="village"](around:10000,${position.latitude},${position.longitude});
        relation["place"="village"](around:10000,${position.latitude},${position.longitude});
      );
      out center;
    ''';

    final response = await http.post(overpassUrl, body: {'data': query});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['elements'];
    } else {
      throw Exception('Failed to load villages');
    }
  }

  static Future<List<Map<String, String>>> getVillageImages(String villageName) async {
    final url = Uri.parse(
        'https://commons.wikimedia.org/w/api.php?action=query&generator=images&titles=$villageName&prop=imageinfo&iiprop=url&format=json&gimlimit=5');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> images = [];
      
      if (data['query'] != null && data['query']['pages'] != null) {
        final pages = data['query']['pages'] as Map<String, dynamic>;
        for (var page in pages.values) {
          if (page['imageinfo'] != null) {
            images.add({
              'title': villageName,
              'imageUrl': page['imageinfo'][0]['url'],
            });
          }
        }
      }
      return images;
    } else {
      return [];
    }
  }
}