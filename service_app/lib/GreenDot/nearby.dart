import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';


class VillageFromJson {
  final String villageName;
  final String category;
  final String shortDescription;
  final List<String> images;
  final List<String> experiences;
  final List<String> localProducts;
  final List<String> revenueStreams;
  final String bestTimeToVisit;
  final double approxDistanceFromDistrictHqKm;

  VillageFromJson({
    required this.villageName,
    required this.category,
    required this.shortDescription,
    required this.images,
    required this.experiences,
    required this.localProducts,
    required this.revenueStreams,
    required this.bestTimeToVisit,
    required this.approxDistanceFromDistrictHqKm,
  });

  factory VillageFromJson.fromJson(Map<String, dynamic> json) {
    return VillageFromJson(
      villageName: json['village_name'],
      category: json['category'],
      shortDescription: json['short_description'],
      images: List<String>.from(json['images']),
      experiences: List<String>.from(json['experiences']),
      localProducts: List<String>.from(json['local_products']),
      revenueStreams: List<String>.from(json['revenue_streams']),
      bestTimeToVisit: json['best_time_to_visit'],
      approxDistanceFromDistrictHqKm: (json['approx_distance_from_district_hq_km'] as num).toDouble(),
    );
  }
}

class DistrictVillages {
  final String district;
  final List<VillageFromJson> villages;

  DistrictVillages({required this.district, required this.villages});

  factory DistrictVillages.fromJson(Map<String, dynamic> json) {
    return DistrictVillages(
      district: json['district'],
      villages: (json['villages'] as List)
          .map((v) => VillageFromJson.fromJson(v))
          .toList(),
    );
  }
}

// Extended Village model for map display with coordinates
class MapVillage {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final String description;
  final String bestTimeToVisit;
  final List<String> experiences;
  final List<String> localProducts;
  final List<String> images;
  final double? distanceFromUser; // calculated
  final double approxDistanceFromDistrictHqKm;

  MapVillage({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.description,
    required this.bestTimeToVisit,
    required this.experiences,
    required this.localProducts,
    required this.images,
    this.distanceFromUser,
    required this.approxDistanceFromDistrictHqKm,
  });

  Color get markerColor {
    switch (category.toLowerCase()) {
      case 'craft':
        return Colors.purple;
      case 'eco':
        return Colors.green;
      case 'heritage':
        return Colors.orange;
      case 'tribal':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'craft':
        return Icons.brush;
      case 'eco':
        return Icons.park;
      case 'heritage':
        return Icons.history;
      case 'tribal':
        return Icons.people;
      default:
        return Icons.location_on;
    }
  }
}

// Helper widget for green dot rating
class GreenDotRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  const GreenDotRating({super.key, required this.rating, this.maxStars = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(maxStars, (index) {
        final isFull = index < rating.floor();
        return Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Icon(
            isFull ? Icons.circle : Icons.circle_outlined,
            size: 12,
            color: isFull ? Colors.green : Colors.green.shade200,
          ),
        );
      }),
    );
  }
}

// Tour Card Data (unchanged)
class TourCardData {
  final String title;
  final double rating;
  final String price;
  final String imageAsset;
  TourCardData({required this.title, required this.rating, required this.price, required this.imageAsset});
}

// Attraction Data (unchanged)
class AttractionData {
  final String title;
  final String location;
  final String description;
  final double rating;
  final String imageAsset;
  AttractionData({required this.title, required this.location, required this.description, required this.rating, required this.imageAsset});
}

// ============================================================
// VILLAGE DATA LOADER (From the provided JSON)
// ============================================================

class VillageDataLoader {
  static List<MapVillage> _allVillages = [];
  
  // Pre-defined coordinates for villages (based on actual Odisha locations)
  // These are approximate real coordinates for each village
  static final Map<String, LatLng> _villageCoordinates = {
    // Puri District
    'Raghurajpur': const LatLng(19.8951, 85.8349),
    'Mangalajodi': const LatLng(19.8484, 85.4850),
    'Pipli': const LatLng(20.1155, 85.8342),
    'Satapada': const LatLng(19.6583, 85.4419),
    'Sakhigopal': const LatLng(19.9807, 85.8054),
    
    // Khordha District
    'Atri': const LatLng(20.1203, 85.5517),
    'Sadeibereni': const LatLng(20.2343, 85.5532),
    'Dhauli': const LatLng(20.1925, 85.8442),
    'Banapur': const LatLng(19.7849, 85.1792),
    'Tangi': const LatLng(20.0214, 85.4465),
    
    // Ganjam District
    'Gopalpur': const LatLng(19.2664, 84.9056),
    'Tara Tarini': const LatLng(19.4725, 84.9961),
    'Pati Sonepur': const LatLng(19.3218, 84.8763),
    'Bomokei': const LatLng(19.5232, 84.7561),
    'Belaguntha': const LatLng(19.8822, 84.6311),
    
    // Mayurbhanj District
    'Barehipani': const LatLng(21.6164, 86.3819),
    'Khiching': const LatLng(21.9814, 85.8245),
    'Jashipur': const LatLng(22.0592, 85.9243),
    'Lulung': const LatLng(21.9672, 86.0224),
    'Bangriposi': const LatLng(21.9121, 86.0378),
    
    // Sambalpur District
    'Huma': const LatLng(21.2648, 83.9798),
    'Hirakud': const LatLng(21.5250, 83.8667),
    'Chipilima': const LatLng(21.3635, 84.0077),
    'Ghess': const LatLng(21.3431, 84.0762),
    'Kud Gunda': const LatLng(21.3315, 83.9459),
    
    // Dhenkanal District
    'Sadeibareni': const LatLng(20.5676, 85.4403),
    'Gonasika': const LatLng(21.1598, 85.3953),
    'Talcher': const LatLng(20.9493, 85.2332),
    'Onda': const LatLng(20.6987, 85.5649),
    'Hindol': const LatLng(20.6972, 85.1871),
    
    // Sundargarh District
    'Bonai': const LatLng(21.8172, 84.9511),
    'Tensa': const LatLng(22.0035, 85.0107),
    'Rourkela': const LatLng(22.2605, 84.8534),
    'Kuanripal': const LatLng(22.1078, 84.9173),
    'Jamshedpur': const LatLng(22.0804, 84.8231),
    
    // Kendrapara District
    'Bhitarkanika': const LatLng(20.7278, 86.9731),
    'Rajnagar': const LatLng(20.6681, 86.6213),
    'Talchua': const LatLng(20.7278, 86.9731),
    'Mahakalpada': const LatLng(20.3031, 86.5850),
    'Mahakalapada': const LatLng(20.3031, 86.5850),
    
    // Jagatsinghpur District
    'Ersama': const LatLng(20.1156, 86.4405),
    'Paradeep': const LatLng(20.3165, 86.6098),
    'Pataspur': const LatLng(20.1892, 86.5471),
    'Aul': const LatLng(20.1562, 86.3005),
    'Raghunathpur': const LatLng(20.2697, 86.3284),
    
    // Baleswar District
    'Nilagiri': const LatLng(21.4635, 86.7683),
    'Baleshwar': const LatLng(21.4928, 86.9311),
    'Remuna': const LatLng(21.5289, 86.8813),
    'Soro': const LatLng(21.2906, 86.6903),
    'Anugul': const LatLng(21.1953, 86.3844),
    
    // Koraput District
    'Kotpad': const LatLng(19.0028, 82.5311),
    'Lamptaput': const LatLng(18.6753, 82.5861),
    'Deomali': const LatLng(18.6789, 82.9531),
    'Harishankar': const LatLng(20.0892, 83.3364),
    'Sunabeda': const LatLng(18.7594, 82.9822),
    
    // Rayagada District
    'Muniguda': const LatLng(19.3245, 83.4201),
    'Lanjia': const LatLng(19.3393, 83.6394),
    'Seranga': const LatLng(19.3476, 83.5689),
    'Rayagada Sadar': const LatLng(19.1696, 83.4165),
    'Bissamcuttack': const LatLng(19.5322, 83.5256),
    
    // Andhra Pradesh - East Godavari
    'Dwaraka Tirumala': const LatLng(16.6667, 81.5000),
    'Ryali': const LatLng(16.8333, 81.4167),
    'Draksharamam': const LatLng(16.6500, 81.2333),
    'Pithapuram': const LatLng(16.7167, 81.1833),
    'Uppada': const LatLng(16.6500, 81.4667),
    'Antarvedi': const LatLng(14.6333, 80.1667),
    'Tallarevu': const LatLng(16.5667, 81.5333),
    'Yeleswaram': const LatLng(16.5833, 81.3333),
    
    // West Godavari
    'Palakollu': const LatLng(16.7222, 81.2667),
    'Bhimavaram': const LatLng(16.5333, 81.5167),
    'Narasapuram': const LatLng(16.4333, 81.4167),
    'Eluru': const LatLng(16.7167, 81.1000),
    'Perupalem': const LatLng(16.8500, 81.0833),
    'Kolleru Lake Villages': const LatLng(16.7500, 81.1500),
    
    // Visakhapatnam
    'Araku Valley': const LatLng(18.2000, 82.8000),
    'Lambasingi': const LatLng(18.3333, 82.5000),
    'Bheemunipatnam': const LatLng(17.9833, 83.4333),
    'Ananthagiri': const LatLng(18.1333, 82.8333),
    'Dumbriguda': const LatLng(18.2500, 82.6667),
    'Chintapalli': const LatLng(18.3667, 82.3833),
    'Paderu': const LatLng(18.3000, 82.4333),
    'Kothapalli': const LatLng(18.2500, 82.7000),
    
    // Vizianagaram
    'Kumili': const LatLng(18.0500, 83.2333),
    'Salur': const LatLng(18.1000, 83.1333),
    'Bobbili': const LatLng(18.0667, 83.2667),
    'Parvathipuram': const LatLng(18.3333, 83.5000),
    
    // Srikakulam
    'Srikurmam': const LatLng(18.3167, 83.8667),
    'Arasavalli': const LatLng(18.4167, 84.0000),
    'Baruva': const LatLng(18.2000, 84.0333),
    'Mandasa': const LatLng(18.3000, 83.8667),
    
    // Krishna
    'Kondapalli': const LatLng(16.5333, 80.8667),
    'Avanigadda': const LatLng(16.2833, 81.0333),
    'Pedana': const LatLng(16.1667, 81.1667),
    'Machilipatnam': const LatLng(16.1833, 81.1333),
    'Ghantasala': const LatLng(16.0333, 80.9333),
    'Manginapudi': const LatLng(16.0667, 80.8333),
    
    // Guntur
    'Amaravati': const LatLng(16.5833, 80.6333),
    'Bhattiprolu': const LatLng(16.1500, 80.3667),
    'Mangalagiri': const LatLng(16.4500, 80.6167),
    'Tenali': const LatLng(16.2500, 80.6000),
    'Chebrolu': const LatLng(16.3667, 80.5833),
    'Nagarjuna Sagar': const LatLng(16.5333, 78.8333),
    
    // Prakasam
    'Kothapatnam': const LatLng(14.2667, 79.8333),
    'Martur': const LatLng(14.4000, 79.6667),
    'Kanigiri': const LatLng(14.4167, 79.5333),
    'Markapuram': const LatLng(14.5500, 79.6667),
    'Tripurantakam': const LatLng(14.3667, 79.3000),
    
    // Nellore
    'Nelapattu': const LatLng(14.4333, 79.9833),
    'Udayagiri': const LatLng(14.4500, 79.8500),
    'Mypadu': const LatLng(14.4167, 79.9333),
    'Sullurpeta': const LatLng(14.5167, 79.9000),
    'Pulicat Lake': const LatLng(13.9667, 80.2167),
    
    // Chittoor
    'Tirupati': const LatLng(13.1833, 79.8833),
    'Nagalapuram': const LatLng(13.2500, 79.8667),
    'Kailasakona': const LatLng(13.1667, 80.0000),
    'Horsley Hills': const LatLng(13.3667, 79.9167),
    'Palamaneru': const LatLng(13.4833, 79.6167),
    'Vellore': const LatLng(12.9690, 79.1288),
    
    // Kadapa
    'Gandikota': const LatLng(14.5667, 79.4167),
    'Vempalli': const LatLng(14.4333, 79.5833),
    'Lankamala': const LatLng(14.3167, 79.6833),
    'Pullampeta': const LatLng(14.3833, 79.8667),
    'Arugonda': const LatLng(14.2333, 79.5333),
    
    // Anantapur
    'Lepakshi': const LatLng(13.5167, 79.4333),
    'Penukonda': const LatLng(13.6167, 79.2333),
    'Hemavathi': const LatLng(13.8333, 79.1667),
    'Gooty': const LatLng(14.0667, 78.9667),
    'Rayadurg': const LatLng(13.7000, 78.5667),
    
    // Kurnool
    'Ahobilam': const LatLng(15.1833, 78.3833),
    'Mantralayam': const LatLng(15.2333, 78.7833),
    'Srisailam': const LatLng(15.4333, 78.4167),
    'Alampur': const LatLng(15.6833, 78.6000),
    'Nandyal': const LatLng(15.4833, 78.4667),
    'Orvakal': const LatLng(15.7333, 78.7833),
    
    // Telangana - Hyderabad
    'Golconda': const LatLng(17.3667, 78.4000),
    'Shamirpet': const LatLng(17.6500, 78.5500),
    'Keesaragutta': const LatLng(17.6333, 78.5667),
    'Himayatsagar': const LatLng(17.5500, 78.5000),
    
    // Rangareddy
    'Anantagiri Hills': const LatLng(17.3333, 78.6167),
    'Vikarabad': const LatLng(17.3667, 78.7667),
    'Manjira Lake': const LatLng(17.5333, 78.7000),
    'Chevella': const LatLng(17.2167, 78.8167),
    
    // Medak
    'Medak': const LatLng(18.0333, 78.4500),
    'Pocharam': const LatLng(18.1167, 78.5333),
    'Narsapur': const LatLng(18.1333, 78.4333),
    'Siddipet': const LatLng(18.2667, 78.3500),
    'Andole': const LatLng(18.3167, 78.2667),
    
    // Sangareddy
    'Zaheerabad': const LatLng(17.9167, 78.2333),
    'Jharasangam': const LatLng(17.8667, 78.1667),
    'Naldurg': const LatLng(17.7333, 78.0333),
    
    // Warangal
    'Warangal': const LatLng(17.9689, 79.5941),
    'Ramappa': const LatLng(18.2000, 79.1667),
    'Palampet': const LatLng(18.2333, 79.1833),
    'Pakhal Lake': const LatLng(18.3333, 79.0833),
    'Eturnagaram': const LatLng(18.2000, 79.3333),
    'Ghanpur': const LatLng(18.1667, 79.5000),
    
    // Khammam
    'Bhadrachalam': const LatLng(17.0833, 80.4833),
    'Kothagudem': const LatLng(17.2500, 80.6000),
    'Palvoncha': const LatLng(17.4667, 80.4667),
    'Nelakondapalli': const LatLng(17.1333, 80.2667),
    'Yellandu': const LatLng(17.3333, 80.7333),
    
    // Karimnagar
    'Vemulawada': const LatLng(18.6667, 78.8167),
    'Dharmapuri': const LatLng(18.6333, 78.6333),
    'Elgandal': const LatLng(18.7333, 78.7667),
    'Manthani': const LatLng(18.6667, 78.5333),
    'Jagtial': const LatLng(18.7833, 78.4667),
    
    // Nizamabad
    'Nizamabad': const LatLng(18.6722, 78.1300),
    'Armoor': const LatLng(18.5667, 78.3333),
    'Bodhan': const LatLng(18.7667, 78.0667),
    'Pochampad': const LatLng(18.4333, 77.8333),
    
    // Adilabad
    'Adilabad': const LatLng(19.0780, 78.5395),
    'Utnoor': const LatLng(19.3333, 78.6667),
    'Kawal Tiger Reserve': const LatLng(19.2500, 78.8333),
    'Jainath': const LatLng(19.0167, 78.8333),
    'Nirmal': const LatLng(19.0333, 78.3667),
    'Kuntala': const LatLng(19.0833, 78.6667),
    
    // Nalgonda
    'Panagal': const LatLng(17.0333, 79.1333),
    'Devarakonda': const LatLng(17.0667, 79.0000),
    'Bhongir': const LatLng(17.4333, 79.0667),
    'Kolanupaka': const LatLng(17.4667, 79.2667),
    
    // Mahabubnagar
    'Gadwal': const LatLng(16.2167, 78.5333),
    'Jogulamba': const LatLng(15.8333, 78.7167),
    'Kollapur': const LatLng(15.8667, 78.5000),
    'Amrabad': const LatLng(15.9000, 78.5333),
    
    // Mancherial
    'Mancherial': const LatLng(18.9833, 78.0167),
    'Chennur': const LatLng(18.9500, 77.8333),
    'Bellampalli': const LatLng(18.8000, 77.9000),
    
    // Jagitial
    'Mallial': const LatLng(18.8333, 78.5667),
    'Medipalli': const LatLng(18.7667, 78.4833),
    
    // Peddapalli
    'Ramagundam': const LatLng(18.8167, 79.1333),
  };

  // District to Villages Mapping
  static final Map<String, List<String>> districtVillages = {
    'Puri': ['Raghurajpur', 'Mangalajodi', 'Pipli', 'Satapada', 'Sakhigopal'],
    'Khordha': ['Atri', 'Sadeibereni', 'Dhauli', 'Banapur', 'Tangi'],
    'Ganjam': ['Gopalpur', 'Tara Tarini', 'Pati Sonepur', 'Bomokei', 'Belaguntha'],
    'Mayurbhanj': ['Barehipani', 'Khiching', 'Jashipur', 'Lulung', 'Bangriposi'],
    'Sambalpur': ['Huma', 'Hirakud', 'Chipilima', 'Ghess', 'Kud Gunda'],
    'Dhenkanal': ['Sadeibareni', 'Gonasika', 'Talcher', 'Onda', 'Hindol'],
    'Sundargarh': ['Bonai', 'Tensa', 'Rourkela', 'Kuanripal', 'Jamshedpur'],
    'Kendrapara': ['Bhitarkanika', 'Rajnagar', 'Talchua', 'Mahakalpada', 'Mahakalapada'],
    'Jagatsinghpur': ['Ersama', 'Paradeep', 'Pataspur', 'Aul', 'Raghunathpur'],
    'Baleswar': ['Nilagiri', 'Baleshwar', 'Remuna', 'Soro', 'Anugul'],
    'Koraput': ['Kotpad', 'Lamptaput', 'Deomali', 'Harishankar', 'Sunabeda'],
    'Rayagada': ['Muniguda', 'Lanjia', 'Seranga', 'Rayagada Sadar', 'Bissamcuttack'],
    
    // Andhra Pradesh - East Godavari
    'East Godavari': ['Dwaraka Tirumala', 'Ryali', 'Draksharamam', 'Pithapuram', 'Uppada', 'Antarvedi', 'Tallarevu', 'Yeleswaram'],
    'West Godavari': ['Palakollu', 'Bhimavaram', 'Narasapuram', 'Eluru', 'Perupalem', 'Kolleru Lake Villages'],
    'Visakhapatnam': ['Araku Valley', 'Lambasingi', 'Bheemunipatnam', 'Ananthagiri', 'Dumbriguda', 'Chintapalli', 'Paderu', 'Kothapalli'],
    'Vizianagaram': ['Kumili', 'Salur', 'Bobbili', 'Parvathipuram'],
    'Srikakulam': ['Srikurmam', 'Arasavalli', 'Baruva', 'Mandasa'],
    'Krishna': ['Kondapalli', 'Avanigadda', 'Pedana', 'Machilipatnam', 'Ghantasala', 'Manginapudi'],
    'Guntur': ['Amaravati', 'Bhattiprolu', 'Mangalagiri', 'Tenali', 'Chebrolu', 'Nagarjuna Sagar'],
    'Prakasam': ['Kothapatnam', 'Martur', 'Kanigiri', 'Markapuram', 'Tripurantakam'],
    'Nellore': ['Nelapattu', 'Udayagiri', 'Mypadu', 'Sullurpeta', 'Pulicat Lake'],
    'Chittoor': ['Tirupati', 'Nagalapuram', 'Kailasakona', 'Horsley Hills', 'Palamaneru', 'Vellore'],
    'Kadapa': ['Gandikota', 'Vempalli', 'Lankamala', 'Pullampeta', 'Arugonda'],
    'Anantapur': ['Lepakshi', 'Penukonda', 'Hemavathi', 'Gooty', 'Rayadurg'],
    'Kurnool': ['Ahobilam', 'Mantralayam', 'Srisailam', 'Alampur', 'Nandyal', 'Orvakal'],
    
    // Telangana Villages
    'Hyderabad': ['Golconda', 'Shamirpet', 'Keesaragutta', 'Himayatsagar'],
    'Rangareddy': ['Anantagiri Hills', 'Vikarabad', 'Manjira Lake', 'Chevella'],
    'Medak': ['Medak', 'Pocharam', 'Narsapur', 'Siddipet', 'Andole'],
    'Sangareddy': ['Zaheerabad', 'Jharasangam', 'Naldurg'],
    'Warangal': ['Warangal', 'Ramappa', 'Palampet', 'Pakhal Lake', 'Eturnagaram', 'Ghanpur'],
    'Khammam': ['Bhadrachalam', 'Kothagudem', 'Palvoncha', 'Nelakondapalli', 'Yellandu'],
    'Karimnagar': ['Vemulawada', 'Dharmapuri', 'Elgandal', 'Manthani', 'Jagtial'],
    'Nizamabad': ['Nizamabad', 'Armoor', 'Bodhan', 'Pochampad'],
    'Adilabad': ['Adilabad', 'Utnoor', 'Kawal Tiger Reserve', 'Jainath', 'Nirmal', 'Kuntala'],
    'Nalgonda': ['Nagarjuna Sagar', 'Panagal', 'Devarakonda', 'Bhongir', 'Kolanupaka'],
    'Mahabubnagar': ['Gadwal', 'Jogulamba', 'Kollapur', 'Amrabad'],
    'Mancherial': ['Mancherial', 'Chennur', 'Bellampalli'],
    'Jagitial': ['Mallial', 'Medipalli'],
    'Peddapalli': ['Ramagundam', 'Manthani'],
  };

  static Future<List<MapVillage>> loadAllVillages() async {
    if (_allVillages.isNotEmpty) return _allVillages;
    
    try {
      final List<MapVillage> villages = [];
      
      // Create villages from all districts in districtVillages map
      districtVillages.forEach((district, villageNames) {
        for (var villageName in villageNames) {
          final coordinates = _villageCoordinates[villageName];
          if (coordinates != null) {
            // Create basic village data for all villages
            villages.add(MapVillage(
              id: '${district}_${villageName}',
              name: villageName,
              latitude: coordinates.latitude,
              longitude: coordinates.longitude,
              category: _getCategoryForVillage(villageName),
              description: _getDescriptionForVillage(villageName),
              bestTimeToVisit: 'October - March',
              experiences: ['Visit village', 'Local exploration', 'Community interaction'],
              localProducts: ['Local handicrafts', 'Agricultural products'],
              images: ['images/demo.jpg'],
              approxDistanceFromDistrictHqKm: 25.0,
            ));
          }
        }
      });
      
      _allVillages = villages;
      return villages;
    } catch (e) {
      print("Error loading villages: $e");
      return [];
    }
  }
  
  // Helper method to get category for villages
  static String _getCategoryForVillage(String villageName) {
    final categories = {
      'Raghurajpur': 'Craft',
      'Mangalajodi': 'Eco',
      'Pipli': 'Craft',
      'Satapada': 'Eco',
      'Sakhigopal': 'Heritage',
      'Atri': 'Eco',
      'Sadeibereni': 'Craft',
      'Dhauli': 'Heritage',
      'Banapur': 'Heritage',
      'Tangi': 'Eco',
      'Gopalpur': 'Eco',
      'Tara Tarini': 'Heritage',
      'Pati Sonepur': 'Tribal',
      'Bomokei': 'Eco',
      'Belaguntha': 'Tribal',
      'Barehipani': 'Eco',
      'Khiching': 'Heritage',
      'Jashipur': 'Tribal',
      'Lulung': 'Eco',
      'Bangriposi': 'Craft',
      'Huma': 'Tribal',
      'Hirakud': 'Heritage',
      'Chipilima': 'Eco',
      'Ghess': 'Craft',
      'Kud Gunda': 'Tribal',
      'Sadeibareni': 'Craft',
      'Gonasika': 'Eco',
      'Talcher': 'Heritage',
      'Onda': 'Tribal',
      'Hindol': 'Heritage',
      'Bonai': 'Tribal',
      'Tensa': 'Eco',
      'Rourkela': 'Heritage',
      'Kuanripal': 'Eco',
      'Jamshedpur': 'Heritage',
      'Bhitarkanika': 'Eco',
      'Rajnagar': 'Tribal',
      'Talchua': 'Eco',
      'Mahakalpada': 'Heritage',
      'Mahakalapada': 'Heritage',
      'Ersama': 'Craft',
      'Paradeep': 'Heritage',
      'Pataspur': 'Eco',
      'Aul': 'Tribal',
      'Raghunathpur': 'Craft',
      'Nilagiri': 'Eco',
      'Baleshwar': 'Heritage',
      'Remuna': 'Heritage',
      'Soro': 'Craft',
      'Anugul': 'Tribal',
      'Kotpad': 'Craft',
      'Lamptaput': 'Tribal',
      'Deomali': 'Eco',
      'Harishankar': 'Heritage',
      'Sunabeda': 'Eco',
      'Muniguda': 'Tribal',
      'Lanjia': 'Craft',
      'Seranga': 'Eco',
      'Rayagada Sadar': 'Heritage',
      'Bissamcuttack': 'Tribal',
      // Andhra Pradesh
      'Dwaraka Tirumala': 'Heritage',
      'Ryali': 'Heritage',
      'Draksharamam': 'Heritage',
      'Pithapuram': 'Heritage',
      'Uppada': 'Eco',
      'Antarvedi': 'Heritage',
      'Tallarevu': 'Eco',
      'Yeleswaram': 'Heritage',
      'Palakollu': 'Heritage',
      'Bhimavaram': 'Eco',
      'Narasapuram': 'Eco',
      'Eluru': 'Heritage',
      'Perupalem': 'Heritage',
      'Kolleru Lake Villages': 'Eco',
      'Araku Valley': 'Eco',
      'Lambasingi': 'Eco',
      'Bheemunipatnam': 'Eco',
      'Ananthagiri': 'Eco',
      'Dumbriguda': 'Tribal',
      'Chintapalli': 'Tribal',
      'Paderu': 'Tribal',
      'Kothapalli': 'Tribal',
      'Kumili': 'Heritage',
      'Salur': 'Heritage',
      'Bobbili': 'Heritage',
      'Parvathipuram': 'Heritage',
      'Srikurmam': 'Heritage',
      'Arasavalli': 'Heritage',
      'Baruva': 'Eco',
      'Mandasa': 'Heritage',
      'Kondapalli': 'Craft',
      'Avanigadda': 'Eco',
      'Pedana': 'Eco',
      'Machilipatnam': 'Eco',
      'Ghantasala': 'Heritage',
      'Manginapudi': 'Eco',
      'Amaravati': 'Heritage',
      'Bhattiprolu': 'Heritage',
      'Mangalagiri': 'Heritage',
      'Tenali': 'Heritage',
      'Chebrolu': 'Heritage',
      'Kothapatnam': 'Eco',
      'Martur': 'Heritage',
      'Kanigiri': 'Heritage',
      'Markapuram': 'Heritage',
      'Tripurantakam': 'Heritage',
      'Nelapattu': 'Eco',
      'Udayagiri': 'Heritage',
      'Mypadu': 'Eco',
      'Sullurpeta': 'Heritage',
      'Pulicat Lake': 'Eco',
      'Tirupati': 'Heritage',
      'Nagalapuram': 'Heritage',
      'Kailasakona': 'Heritage',
      'Horsley Hills': 'Eco',
      'Palamaneru': 'Heritage',
      'Vellore': 'Heritage',
      'Gandikota': 'Heritage',
      'Vempalli': 'Heritage',
      'Lankamala': 'Heritage',
      'Pullampeta': 'Heritage',
      'Arugonda': 'Heritage',
      'Lepakshi': 'Heritage',
      'Penukonda': 'Heritage',
      'Hemavathi': 'Heritage',
      'Gooty': 'Heritage',
      'Rayadurg': 'Heritage',
      'Ahobilam': 'Heritage',
      'Mantralayam': 'Heritage',
      'Srisailam': 'Heritage',
      'Alampur': 'Heritage',
      'Nandyal': 'Heritage',
      'Orvakal': 'Eco',
      // Telangana
      'Golconda': 'Heritage',
      'Shamirpet': 'Eco',
      'Keesaragutta': 'Heritage',
      'Himayatsagar': 'Eco',
      'Anantagiri Hills': 'Eco',
      'Vikarabad': 'Heritage',
      'Manjira Lake': 'Eco',
      'Chevella': 'Heritage',
      'Medak': 'Heritage',
      'Pocharam': 'Eco',
      'Narsapur': 'Heritage',
      'Siddipet': 'Heritage',
      'Andole': 'Heritage',
      'Zaheerabad': 'Heritage',
      'Jharasangam': 'Heritage',
      'Naldurg': 'Heritage',
      'Warangal': 'Heritage',
      'Ramappa': 'Heritage',
      'Palampet': 'Heritage',
      'Pakhal Lake': 'Eco',
      'Eturnagaram': 'Eco',
      'Ghanpur': 'Eco',
      'Bhadrachalam': 'Heritage',
      'Kothagudem': 'Heritage',
      'Palvoncha': 'Heritage',
      'Nelakondapalli': 'Heritage',
      'Yellandu': 'Heritage',
      'Vemulawada': 'Heritage',
      'Dharmapuri': 'Heritage',
      'Elgandal': 'Heritage',
      'Manthani': 'Heritage',
      'Jagtial': 'Heritage',
      'Nizamabad': 'Heritage',
      'Armoor': 'Heritage',
      'Bodhan': 'Heritage',
      'Pochampad': 'Heritage',
      'Adilabad': 'Heritage',
      'Utnoor': 'Tribal',
      'Kawal Tiger Reserve': 'Eco',
      'Jainath': 'Heritage',
      'Nirmal': 'Heritage',
      'Kuntala': 'Eco',
      'Panagal': 'Heritage',
      'Devarakonda': 'Heritage',
      'Bhongir': 'Heritage',
      'Kolanupaka': 'Heritage',
      'Gadwal': 'Heritage',
      'Jogulamba': 'Heritage',
      'Kollapur': 'Heritage',
      'Amrabad': 'Eco',
      'Mancherial': 'Heritage',
      'Chennur': 'Heritage',
      'Bellampalli': 'Heritage',
      'Mallial': 'Heritage',
      'Medipalli': 'Heritage',
      'Ramagundam': 'Heritage',
    };
    return categories[villageName] ?? 'Heritage';
  }
  
  // Helper method to get description for villages
  static String _getDescriptionForVillage(String villageName) {
    final descriptions = {
      'Raghurajpur': 'Heritage crafts village famous for Pattachitra paintings',
      'Mangalajodi': 'Bird sanctuary on Chilika Lake',
      'Pipli': 'World-renowned center for colorful Appliqué work',
      'Satapada': 'Gateway to Irrawaddy dolphin habitat',
      'Sakhigopal': 'Temple village with coconut groves',
      'Atri': 'Home to therapeutic sulfur hot springs',
      'Sadeibereni': 'Tribal metal craft village famous for Dhokra',
      'Dhauli': 'Historical village at Shanti Stupa',
      'Banapur': 'Ancient Bhagabati Temple and bell metal work',
      'Tangi': 'Riverside agriculture hub near Chilika',
      'Gopalpur': 'Beach village with scenic beauty',
      'Tara Tarini': 'Temple village on hilltop',
      'Pati Sonepur': 'Tribal village with traditional culture',
      'Bomokei': 'Eco-tourism village',
      'Belaguntha': 'Rural tribal settlement',
      'Barehipani': 'Waterfall and eco-tourism hub',
      'Khiching': 'Heritage temple village',
      'Jashipur': 'Tribal craft center',
      'Lulung': 'Scenic eco-village',
      'Bangriposi': 'Craft village with artisan community',
      'Huma': 'Tribal village settlement',
      'Hirakud': 'Dam and heritage site',
      'Chipilima': 'Eco-tourism destination',
      'Ghess': 'Craft center village',
      'Kud Gunda': 'Tribal cultural village',
      'Sadeibareni': 'Metalcraft village',
      'Gonasika': 'Eco-village with natural beauty',
      'Talcher': 'Heritage and mining region',
      'Onda': 'Tribal settlement',
      'Hindol': 'Historical temple region',
      'Bonai': 'Tribal cultural hub',
      'Tensa': 'Eco-tourism village',
      'Rourkela': 'Heritage industrial city',
      'Kuanripal': 'Eco-village',
      'Jamshedpur': 'Heritage city region',
      'Bhitarkanika': 'Wildlife sanctuary and eco-center',
      'Rajnagar': 'Tribal settlement',
      'Talchua': 'Eco-village',
      'Mahakalpada': 'Heritage village',
      'Mahakalapada': 'Heritage temple village',
      'Ersama': 'Craft village',
      'Paradeep': 'Port city heritage',
      'Pataspur': 'Eco-village',
      'Aul': 'Tribal village',
      'Raghunathpur': 'Craft center',
      'Nilagiri': 'Eco-tourism hub',
      'Baleshwar': 'Historic town',
      'Remuna': 'Heritage temple village',
      'Soro': 'Craft village',
      'Anugul': 'Tribal region',
      'Kotpad': 'Handloom craft center',
      'Lamptaput': 'Tribal settlement',
      'Deomali': 'Scenic mountain village',
      'Harishankar': 'Temple heritage site',
      'Sunabeda': 'Eco-tourism destination',
      'Muniguda': 'Tribal cultural center',
      'Lanjia': 'Craft village',
      'Seranga': 'Eco-village',
      'Rayagada Sadar': 'District heritage hub',
      'Bissamcuttack': 'Tribal settlement',
      // Andhra Pradesh
      'Dwaraka Tirumala': 'Ancient temple dedicated to Lord Vishnu',
      'Ryali': 'Pottery craft village with traditional artisans',
      'Draksharamam': 'Ashram of sage Draksharama near Godavari',
      'Pithapuram': 'Historic site with Suryanarayana temple',
      'Uppada': 'Coastal village famous for silk weaving',
      'Antarvedi': 'Anusuya Devi temple on Krishna river',
      'Tallarevu': 'Godavari delta farming village',
      'Yeleswaram': 'Temple village on Godavari banks',
      'Palakollu': 'Historic town with cultural heritage',
      'Bhimavaram': 'Temple city with religious significance',
      'Narasapuram': 'Coastal village with scenic views',
      'Eluru': 'Historic trading city',
      'Perupalem': 'Heritage temple settlement',
      'Kolleru Lake Villages': 'Wetland eco-tourism destination',
      'Araku Valley': 'Mountain valley with tribal culture',
      'Lambasingi': 'Hill station with scenic beauty',
      'Bheemunipatnam': 'Beach town with Dutch fort remains',
      'Ananthagiri': 'Hills and temple region',
      'Dumbriguda': 'Tribal village in Eastern Ghats',
      'Chintapalli': 'Tribal craft and forest village',
      'Paderu': 'Tribal settlement with nature trails',
      'Kothapalli': 'Traditional hill village',
      'Kumili': 'Heritage temple settlement',
      'Salur': 'Ancient temple town',
      'Bobbili': 'Historic fortress village',
      'Parvathipuram': 'Mountain village with traditional culture',
      'Srikurmam': 'Temple village on Srikurmam mountain',
      'Arasavalli': 'Sun temple heritage site',
      'Baruva': 'Coastal eco-village',
      'Mandasa': 'Heritage settlement',
      'Kondapalli': 'Toy craft village famous for wooden toys',
      'Avanigadda': 'Farming village on lagoon',
      'Pedana': 'Agricultural settlement',
      'Machilipatnam': 'Historic port city',
      'Ghantasala': 'Ancient temple site',
      'Manginapudi': 'Coastal fishing village',
      'Amaravati': 'Ancient Buddhist capital',
      'Bhattiprolu': 'Heritage Buddhist site',
      'Mangalagiri': 'Temple city on hill',
      'Tenali': 'Historic town with temples',
      'Chebrolu': 'Heritage village',
      'Kothapatnam': 'Coastal fishing village',
      'Martur': 'Historic settlement',
      'Kanigiri': 'Rural heritage village',
      'Markapuram': 'Historic town',
      'Tripurantakam': 'Temple heritage site',
      'Nelapattu': 'Bird watching sanctuary',
      'Udayagiri': 'Ancient fort and caves',
      'Mypadu': 'Coastal eco-village',
      'Sullurpeta': 'Historic town near Nellore',
      'Pulicat Lake': 'Coastal lagoon wildlife sanctuary',
      'Tirupati': 'Famous temple city on hills',
      'Nagalapuram': 'Temple heritage site',
      'Kailasakona': 'Sacred rock temple site',
      'Horsley Hills': 'Hill station with scenic beauty',
      'Palamaneru': 'Hill town with heritage temples',
      'Vellore': 'Historic fort city',
      'Gandikota': 'Canyon and fortress village',
      'Vempalli': 'Heritage settlement',
      'Lankamala': 'Heritage temple village',
      'Pullampeta': 'Historic water temple',
      'Arugonda': 'Rural heritage village',
      'Lepakshi': 'Ancient temple complex',
      'Penukonda': 'Historic fortress town',
      'Hemavathi': 'Heritage village',
      'Gooty': 'Historic fort settlement',
      'Rayadurg': 'Fort and heritage site',
      'Ahobilam': 'Hindu pilgrimage temple town',
      'Mantralayam': 'Saint shrine on river',
      'Srisailam': 'Ancient temple on hills',
      'Alampur': 'Buddhist heritage site',
      'Nandyal': 'Historic frontier town',
      'Orvakal': 'Cave and heritage site',
      // Telangana
      'Golconda': 'Ancient diamond fort city',
      'Shamirpet': 'Lake village eco-tourism',
      'Keesaragutta': 'Temple heritage site',
      'Himayatsagar': 'Water body eco-village',
      'Anantagiri Hills': 'Hill station with nature trails',
      'Vikarabad': 'Historic settlement',
      'Manjira Lake': 'Wetland eco-tourism center',
      'Chevella': 'Historic settlement near Hyderabad',
      'Medak': 'Historic fort and temple town',
      'Pocharam': 'Wildlife sanctuary village',
      'Narsapur': 'Heritage town',
      'Siddipet': 'Textile heritage town',
      'Andole': 'Historic settlement',
      'Zaheerabad': 'Historic town',
      'Jharasangam': 'Heritage settlement',
      'Naldurg': 'Historic village',
      'Warangal': 'Historic fort and temple city',
      'Ramappa': 'Ancient temple complex',
      'Palampet': 'Heritage temple village',
      'Pakhal Lake': 'Scenic water body village',
      'Eturnagaram': 'Wildlife sanctuary village',
      'Ghanpur': 'Rural eco-village',
      'Bhadrachalam': 'Temple city on river',
      'Kothagudem': 'Mining heritage town',
      'Palvoncha': 'Historic settlement',
      'Nelakondapalli': 'Fort and heritage site',
      'Yellandu': 'Mining town heritage',
      'Vemulawada': 'Temple heritage site',
      'Dharmapuri': 'Historic settlement',
      'Elgandal': 'Fort heritage site',
      'Manthani': 'Historic town',
      'Jagtial': 'Historic fort town',
      'Nizamabad': 'Historic fortress city',
      'Armoor': 'Heritage settlement',
      'Bodhan': 'Historic town',
      'Pochampad': 'Heritage village',
      'Adilabad': 'Historic fort city',
      'Utnoor': 'Tribal village heritage',
      'Kawal Tiger Reserve': 'Wildlife eco-tourism',
      'Jainath': 'Heritage settlement',
      'Nirmal': 'Craft heritage village',
      'Kuntala': 'Waterfall eco-village',
      'Panagal': 'Historic settlement',
      'Devarakonda': 'Fort heritage site',
      'Bhongir': 'Historic fort town',
      'Kolanupaka': 'Heritage village',
      'Gadwal': 'Historical fabric weaving town',
      'Jogulamba': 'Temple heritage site',
      'Kollapur': 'Heritage settlement',
      'Amrabad': 'Wildlife sanctuary village',
      'Mancherial': 'Historic town',
      'Chennur': 'Heritage settlement',
      'Bellampalli': 'Fort heritage site',
      'Mallial': 'Historic settlement',
      'Medipalli': 'Heritage village',
      'Ramagundam': 'Thermal heritage town',
    };
    return descriptions[villageName] ?? 'Village destination in South India';
  }
  
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
  
  static double _toRadians(double degree) => degree * math.pi / 180;
}

// ============================================================
// MAIN SCREEN WIDGET
// ============================================================

class TravelExploreScreen extends StatefulWidget {
  const TravelExploreScreen({super.key});

  @override
  State<TravelExploreScreen> createState() => _TravelExploreScreenState();
}

class _TravelExploreScreenState extends State<TravelExploreScreen> with TickerProviderStateMixin {
  String selectedChip = 'Discover';
  final List<String> chips = ['Discover', 'Saves', 'Restaurants'];

  // Map controller and location
  final MapController mapController = MapController();
  LatLng? currentLocation;
  LatLng? selectedMapLocation;
  bool isMapReady = false;
  String? mapError;
  bool isLoadingVillages = true;
  
  // Villages from JSON data
  List<MapVillage> allVillages = [];
  List<MapVillage> nearbyVillages = [];
  List<MapVillage> searchResults = [];
  MapVillage? selectedVillage;
  late AnimationController _popupAnimController;

  // Search functionality
  late TextEditingController searchController;
  String searchQuery = '';
  bool showSearchResults = false;
  
  // Popular Indian places for search
  final List<Map<String, dynamic>> popularPlaces = [
    {'name': 'Taj Mahal', 'location': 'Agra, Uttar Pradesh', 'lat': 27.1751, 'lng': 78.0421, 'category': 'Heritage'},
    {'name': 'Gateway of India', 'location': 'Mumbai, Maharashtra', 'lat': 18.9220, 'lng': 72.8347, 'category': 'Heritage'},
    {'name': 'Jaipur City Palace', 'location': 'Jaipur, Rajasthan', 'lat': 26.9247, 'lng': 75.8245, 'category': 'Heritage'},
    {'name': 'Varanasi Ghats', 'location': 'Varanasi, Uttar Pradesh', 'lat': 25.3209, 'lng': 82.9789, 'category': 'Heritage'},
    {'name': 'Mysore Palace', 'location': 'Mysore, Karnataka', 'lat': 12.2958, 'lng': 76.6394, 'category': 'Heritage'},
    {'name': 'Hawa Mahal', 'location': 'Jaipur, Rajasthan', 'lat': 26.9245, 'lng': 75.8232, 'category': 'Heritage'},
    {'name': 'Backwaters', 'location': 'Kerala', 'lat': 9.2848, 'lng': 76.6753, 'category': 'Eco'},
    {'name': 'Goa Beaches', 'location': 'Goa', 'lat': 15.4909, 'lng': 73.8278, 'category': 'Eco'},
    {'name': 'Darjeeling Tea Gardens', 'location': 'Darjeeling, West Bengal', 'lat': 27.0360, 'lng': 88.2605, 'category': 'Eco'},
    {'name': 'Hampi Ruins', 'location': 'Hampi, Karnataka', 'lat': 15.3350, 'lng': 76.4636, 'category': 'Heritage'},
  ];

  // Location tracking
  StreamSubscription<Position>? positionStream;
  bool isTrackingLocation = true;

  // Demo data for tour cards
  late final List<TourCardData> tours;

  // Demo data for attractions
  late final List<AttractionData> attractions;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
    
    _popupAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initializeDemoData();
    _loadVillagesData();
    _initializeLocation();
  }

  void _initializeDemoData() {
  tours = [
    // Bhubaneswar District Villages
    TourCardData(title: "Dhauli Village Heritage Tour", rating: 4.8, price: "From ₹1500 / person", imageAsset: "images/demo.jpg"),
    TourCardData(title: "Atri Hot Spring Village Wellness Tour", rating: 4.6, price: "From ₹1200 / person", imageAsset: "images/tour_2.jpg"),
    TourCardData(title: "Sadeibereni Dhokra Craft Village Tour", rating: 4.9, price: "From ₹1800 / group", imageAsset: "images/tour_3.avif"),
    TourCardData(title: "Banapur Temple & Bell Metal Craft Tour", rating: 4.7, price: "From ₹1400 / person", imageAsset: "images/tour_4.avif"),
    TourCardData(title: "Tangi Riverside Agriculture Village Tour", rating: 4.5, price: "From ₹1100 / person", imageAsset: "images/tour_5.webp"),
    TourCardData(title: "Khandagiri & Udayagiri Village Walk", rating: 4.8, price: "From ₹900 / person", imageAsset: "images/tour_6.jpg"),
    TourCardData(title: "Nandankanan Zoo Village Safari Tour", rating: 4.7, price: "From ₹1300 / adult", imageAsset: "images/tour_7.jpg"),
    TourCardData(title: "Barunei Hill Village Trekking Tour", rating: 4.6, price: "From ₹1000 / person", imageAsset: "images/tour_8.avif"),
    TourCardData(title: "Jatni Rural Village Experience Tour", rating: 4.5, price: "From ₹1200 / person", imageAsset: "images/tour_9.avif"),
    TourCardData(title: "Khurda Fort & Heritage Village Tour", rating: 4.8, price: "From ₹1600 / group", imageAsset: "images/tour_10.jpg"),
    
    // Cuttack District Villages
    TourCardData(title: "Cuttack Chandi Temple & Silver Filigree Village Tour", rating: 4.9, price: "From ₹2000 / group", imageAsset: "images/tour_11.jpeg"),
    TourCardData(title: "Niali Village Heritage & Handicraft Tour", rating: 4.6, price: "From ₹1300 / person", imageAsset: "images/tour_12.jpg"),
    TourCardData(title: "Kendrapada Village & Mangrove Eco Tour", rating: 4.7, price: "From ₹1700 / person", imageAsset: "images/tour_13.avif"),
    TourCardData(title: "Salepur Village & Agricultural Tour", rating: 4.5, price: "From ₹1100 / person", imageAsset: "images/tour_14.webp"),
    TourCardData(title: "Athagarh Tribal Village & Forest Tour", rating: 4.8, price: "From ₹1900 / group", imageAsset: "images/tour_15.jpg"),
  ];

  attractions = [
    // Khordha District Village Attractions
    AttractionData(title: "Dhauli Village", location: "Khordha District", description: "Historical village with Shanti Stupa and Ashokan rock edicts.", rating: 4.8, imageAsset: "images/attraction_1.jpg"),
    AttractionData(title: "Atri Village", location: "Khordha District", description: "Famous for therapeutic sulfur hot springs and wellness tourism.", rating: 4.6, imageAsset: "images/attraction_2.jpg"),
    AttractionData(title: "Sadeibereni Village", location: "Khordha District", description: "Renowned for Dhokra metal craft and tribal artisan workshops.", rating: 4.9, imageAsset: "images/attraction_3.jpeg"),
    AttractionData(title: "Banapur Village", location: "Khordha District", description: "Known for ancient Bhagabati Temple and bell metal work.", rating: 4.7, imageAsset: "images/attraction_4.avif"),
    AttractionData(title: "Tangi Village", location: "Khordha District", description: "Riverside agriculture hub near Chilika Lake edge.", rating: 4.5, imageAsset: "images/attraction_5.webp"),
    AttractionData(title: "Jatni Village", location: "Khordha District", description: "Scenic village with agricultural heritage and local markets.", rating: 4.4, imageAsset: "images/attraction_6.webp"),
    AttractionData(title: "Khurda Village", location: "Khordha District", description: "Historic village with Khurda Fort and freedom struggle sites.", rating: 4.6, imageAsset: "images/tt.webp"),
    
    // Cuttack District Village Attractions
    
  ];
}

  Future<void> _loadVillagesData() async {
    final villages = await VillageDataLoader.loadAllVillages();
    if (mounted) {
      setState(() {
        allVillages = villages;
        isLoadingVillages = false;
      });
    }
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    _startLocationTracking();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          mapError = "Location services are disabled. Please enable them.";
          currentLocation = const LatLng(20.2961, 85.8245); // Bhubaneswar center
          isMapReady = true;
        });
        _updateNearbyVillages();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            mapError = "Location permission denied. Using default location.";
            currentLocation = const LatLng(20.2961, 85.8245);
            isMapReady = true;
          });
          _updateNearbyVillages();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          mapError = "Location permissions permanently denied. Using default location.";
          currentLocation = const LatLng(20.2961, 85.8245);
          isMapReady = true;
        });
        _updateNearbyVillages();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        isMapReady = true;
        mapError = null;
        mapController.move(currentLocation!, 12.0);
      });
      _updateNearbyVillages();
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        mapError = "Could not get location. Showing default map.";
        currentLocation = const LatLng(20.2961, 85.8245);
        isMapReady = true;
      });
      _updateNearbyVillages();
    }
  }

  void _startLocationTracking() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (isTrackingLocation && mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          mapController.move(currentLocation!, 12.0);
        });
        _updateNearbyVillages();
      }
    });
  }

  void _updateNearbyVillages() {
    if (currentLocation == null || allVillages.isEmpty) return;
    
    // Show ALL villages from JSON (not just nearby)
    // Calculate distances for all villages
    final List<MapVillage> updatedVillages = [];
    
    for (var village in allVillages) {
      final distance = VillageDataLoader.calculateDistance(
        currentLocation!.latitude,
        currentLocation!.longitude,
        village.latitude,
        village.longitude,
      );
      
      final updatedVillage = MapVillage(
        id: village.id,
        name: village.name,
        latitude: village.latitude,
        longitude: village.longitude,
        category: village.category,
        description: village.description,
        bestTimeToVisit: village.bestTimeToVisit,
        experiences: village.experiences,
        localProducts: village.localProducts,
        images: village.images,
        distanceFromUser: distance,
        approxDistanceFromDistrictHqKm: village.approxDistanceFromDistrictHqKm,
      );
      updatedVillages.add(updatedVillage);
    }
    
    updatedVillages.sort((a, b) => (a.distanceFromUser ?? 0).compareTo(b.distanceFromUser ?? 0));
    
    setState(() {
      nearbyVillages = updatedVillages;
    });
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        showSearchResults = false;
        searchResults = [];
      } else {
        showSearchResults = true;
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    List<MapVillage> villageResults = [];
    
    // First check if query matches a district name (case-insensitive)
    String? matchedDistrict;
    for (var district in VillageDataLoader.districtVillages.keys) {
      if (district.toLowerCase().startsWith(query) || 
          district.toLowerCase().contains(query)) {
        matchedDistrict = district;
        break;
      }
    }
    
    // If a district matches, return all villages from that district
    if (matchedDistrict != null) {
      final villageNamesInDistrict = VillageDataLoader.districtVillages[matchedDistrict] ?? [];
      villageResults = allVillages
          .where((village) => villageNamesInDistrict.contains(village.name))
          .toList();
    } else {
      // Search villages by name, description, or category
      villageResults = allVillages
          .where((village) => 
            village.name.toLowerCase().contains(query) || 
            village.description.toLowerCase().contains(query) ||
            village.category.toLowerCase().contains(query))
          .toList();
    }
    
    // Search famous Indian places
    final placeResults = popularPlaces
        .where((place) => place['name'].toString().toLowerCase().contains(query) ||
                         place['location'].toString().toLowerCase().contains(query) ||
                         place['category'].toString().toLowerCase().contains(query))
        .map((place) {
          return MapVillage(
            id: 'place_${place['name']}',
            name: place['name'],
            latitude: place['lat'] as double,
            longitude: place['lng'] as double,
            category: place['category'],
            description: place['location'],
            bestTimeToVisit: 'Year-round',
            experiences: ['Must visit landmark', 'Photography', 'Cultural exploration'],
            localProducts: [],
            images: ['images/travel.png'],
            approxDistanceFromDistrictHqKm: 0,
          );
        })
        .toList();
    
    searchResults = [...villageResults, ...placeResults];
  }

  void _navigateToVillage(MapVillage village) {
    // Close search
    setState(() {
      showSearchResults = false;
      searchController.clear();
      selectedVillage = null;
    });
    
    // Move map to village
    mapController.move(LatLng(village.latitude, village.longitude), 14.0);
    
    // Show popup
    Future.delayed(const Duration(milliseconds: 300), () {
      _onMarkerTap(village);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to ${village.name}'), duration: const Duration(seconds: 1)),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      selectedMapLocation = latlng;
      selectedVillage = null;
      mapController.move(latlng, 12.0);
    });
  }

  void _centerOnUser() {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 12.0);
      setState(() {
        selectedMapLocation = null;
        selectedVillage = null;
      });
      _updateNearbyVillages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📍 Centered on your location'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _onMarkerTap(MapVillage village) {
    _popupAnimController.forward();
    setState(() {
      selectedVillage = village;
    });
    
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && selectedVillage == village) {
        _popupAnimController.reverse();
        setState(() {
          selectedVillage = null;
        });
      }
    });
  }

  void _showVillageDetails(MapVillage village) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Image and Close
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: village.markerColor.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Icon(village.categoryIcon, size: 80, color: village.markerColor),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Village Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Category
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                village.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: village.markerColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  village.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: village.markerColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      village.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Distance and Best Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Distance',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${village.distanceFromUser?.toStringAsFixed(1) ?? "?"} km',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Best Time to Visit',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                village.bestTimeToVisit,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Experiences Section
                    if (village.experiences.isNotEmpty) ...[
                      const Text(
                        'Experiences',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: village.experiences.map((exp) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    exp,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Local Products Section
                    if (village.localProducts.isNotEmpty) ...[
                      const Text(
                        'Local Products',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: village.localProducts.map((product) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: village.markerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: village.markerColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              product,
                              style: TextStyle(
                                fontSize: 11,
                                color: village.markerColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: village.markerColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVillagesBottomSheet() {
    if (nearbyVillages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No villages found in this area'), duration: Duration(seconds: 2)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'All Villages (${nearbyVillages.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: nearbyVillages.length,
                itemBuilder: (context, index) {
                  final village = nearbyVillages[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: village.markerColor.withOpacity(0.2),
                      child: Icon(village.categoryIcon, color: village.markerColor, size: 20),
                    ),
                    title: Text(
                      village.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${village.distanceFromUser?.toStringAsFixed(1) ?? '?'} km away • ${village.category}'),
                        Text(village.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(village.category),
                      backgroundColor: village.markerColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: village.markerColor, fontSize: 11),
                    ),
                    onTap: () {
                      mapController.move(LatLng(village.latitude, village.longitude), 14.0);
                      Navigator.pop(context);
                      _onMarkerTap(village);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _popupAnimController.dispose();
    positionStream?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Widget _buildCategoryLegend() {
    final categories = ['Craft', 'Eco', 'Heritage', 'Tribal'];
    final colors = [Colors.purple, Colors.green, Colors.orange, Colors.brown];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(categories.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  categories[index],
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar (Fixed at top)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search villages by name or category...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() {
                                showSearchResults = false;
                                searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.grey),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                
                // Search Results Dropdown
                if (showSearchResults && searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final village = searchResults[index];
                        return Material(
                          child: InkWell(
                            onTap: () => _navigateToVillage(village),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: village.markerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          village.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${village.category} • ${village.distanceFromUser?.toStringAsFixed(1) ?? "?"}km',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // Advanced Map section
          SizedBox(
            height: 350,
            child: Stack(
              children: [
                // Map
                if (isMapReady && currentLocation != null && !isLoadingVillages)
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 12.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onTap: _onMapTap,
                    ),
                    children: [
                      // CartoDB Light Tiles (clean and modern)
                      TileLayer(
                        urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.upyogi.service_app',
                      ),
                      
                      // User Location Marker with Pulse Effect
                      MarkerLayer(
                        markers: currentLocation != null
                            ? [
                                Marker(
                                  point: currentLocation!,
                                  width: 40,
                                  height: 40,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                    child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                                  ),
                                ),
                              ]
                            : [],
                      ),
                      
                      // Nearby Villages Markers (categorized by color)
                      MarkerLayer(
                        markers: nearbyVillages.map((village) {
                          final isSelected = selectedVillage?.id == village.id;
                          return Marker(
                            point: LatLng(village.latitude, village.longitude),
                            width: isSelected ? 50 : 40,
                            height: isSelected ? 50 : 40,
                            child: GestureDetector(
                              onTap: () => _onMarkerTap(village),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: village.markerColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: village.markerColor.withOpacity(0.4),
                                      blurRadius: isSelected ? 12 : 6,
                                      spreadRadius: isSelected ? 2 : 0,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  village.categoryIcon,
                                  color: Colors.white,
                                  size: isSelected ? 22 : 18,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // Selected Map Location Marker
                      if (selectedMapLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedMapLocation!,
                              width: 35,
                              height: 35,
                              child: ScaleTransition(
                                scale: Tween(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(parent: _popupAnimController, curve: Curves.elasticOut),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(color: Colors.green.withOpacity(0.6), blurRadius: 8)
                                    ],
                                  ),
                                  child: const Icon(Icons.add_location, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                
                // Error/Loading Overlay
                if (mapError != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade400),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange.shade800, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mapError!,
                              style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Legend
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildCategoryLegend(),
                ),

                // Loading Indicator for Villages
                if (isLoadingVillages)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 8),
                          const Text('Loading villages...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                
                // Floating Action Buttons
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Villages List Button
                      FloatingActionButton.small(
                        heroTag: 'villages',
                        onPressed: _showVillagesBottomSheet,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.list, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      // Center on User Button
                      FloatingActionButton.small(
                        heroTag: 'location',
                        onPressed: _centerOnUser,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.my_location, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Village Popup Card
                if (selectedVillage != null && isMapReady)
                  Positioned(
                    top: 60,
                    left: 16,
                    right: 16,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(parent: _popupAnimController, curve: Curves.easeOutBack),
                      ),
                      child: Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: selectedVillage!.markerColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  selectedVillage!.categoryIcon,
                                  color: selectedVillage!.markerColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Village Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      selectedVillage!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: selectedVillage!.markerColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            selectedVillage!.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: selectedVillage!.markerColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.location_on, size: 12, color: Colors.grey),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${selectedVillage!.distanceFromUser?.toStringAsFixed(1) ?? '?'} km away',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      selectedVillage!.description,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Best time: ${selectedVillage!.bestTimeToVisit}',
                                      style: const TextStyle(fontSize: 10, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showVillageDetails(selectedVillage!),
                                icon: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                                splashRadius: 20,
                              ),
                              IconButton(
                                onPressed: () => setState(() => selectedVillage = null),
                                icon: const Icon(Icons.close, size: 18),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content Below Map
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: chips.map((chip) {
                          final isSelected = selectedChip == chip;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: FilterChip(
                              label: Text(chip),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedChip = chip;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.green.shade50,
                              checkmarkColor: Colors.green,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.green : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? Colors.green : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Book a tour section
                    const Text(
                      "Book a tour for tomorrow",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tours.length,
                        itemBuilder: (context, index) {
                          final tour = tours[index];
                          return _buildTourCard(tour);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Must-see attractions section
                    const Text(
                      "Must-see attractions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: attractions.length,
                        itemBuilder: (context, index) {
                          final attraction = attractions[index];
                          return _buildAttractionCard(attraction);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(TourCardData tour) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: Colors.green.shade50,
              child: Image.asset(tour.imageAsset, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tour.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                GreenDotRating(rating: tour.rating),
                const SizedBox(height: 6),
                Text(tour.price, style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(AttractionData attraction) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: Colors.orange.shade50,
              child: Image.asset(attraction.imageAsset, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attraction.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(attraction.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Text(attraction.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                GreenDotRating(rating: attraction.rating),
              ],
            ),
          ),
        ],
      ),
    );
  }
}