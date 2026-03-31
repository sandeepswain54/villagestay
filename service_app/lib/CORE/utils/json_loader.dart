import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:service_app/model/village_model.dart';

/// Service to load and parse villages.json from assets
class VillagesJsonLoader {
  static const String _villageJsonPath = 'assets/villages.json';

  /// Load villages data from JSON file
  /// Returns a list of VillageData for each district
  static Future<List<VillageData>> loadVillages() async {
    try {
      final jsonString = await rootBundle.loadString(_villageJsonPath);
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      
      // Parse the JSON list into VillageData objects
      final villagesDataSet = VillagesDataSet.fromJson(jsonData);
      
      return villagesDataSet.districtData;
    } catch (e) {
      print('Error loading villages JSON: $e');
      rethrow;
    }
  }

  /// Get all villages from a specific district
  static Future<List<Village>> getVillagesByDistrict(String district) async {
    try {
      final allVillageData = await loadVillages();
      
      // Find the matching district (case-insensitive)
      final districtData = allVillageData.firstWhere(
        (data) => data.district.toLowerCase() == district.toLowerCase(),
        orElse: () => VillageData(district: district, villages: []),
      );
      
      return districtData.villages;
    } catch (e) {
      print('Error getting villages for district $district: $e');
      return [];
    }
  }

  /// Get all available districts
  static Future<List<String>> getAllDistricts() async {
    try {
      final allVillageData = await loadVillages();
      return allVillageData.map((data) => data.district).toList();
    } catch (e) {
      print('Error getting all districts: $e');
      return [];
    }
  }

  /// Get a specific village from a district
  static Future<Village?> getVillageByName(
    String districtName,
    String villageName,
  ) async {
    try {
      final villages = await getVillagesByDistrict(districtName);
      
      return villages.firstWhere(
        (v) => v.villageName.toLowerCase() == villageName.toLowerCase(),
        orElse: () => throw Exception('Village not found'),
      );
    } catch (e) {
      print('Error getting village $villageName: $e');
      return null;
    }
  }

  /// Get all unique categories from all villages
  static Future<List<String>> getAllCategories() async {
    try {
      final allVillageData = await loadVillages();
      final categories = <String>{};
      
      for (var districtData in allVillageData) {
        for (var village in districtData.villages) {
          categories.add(village.category);
        }
      }
      
      return categories.toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  /// Get villages from a district filtered by category
  static Future<List<Village>> getVillagesByDistrictAndCategory(
    String district,
    String category,
  ) async {
    try {
      final villages = await getVillagesByDistrict(district);
      
      if (category.toLowerCase() == 'discover' || category.isEmpty) {
        return villages; // Return all villages
      }
      
      return villages
          .where((v) => v.category.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      print('Error filtering villages: $e');
      return [];
    }
  }
}
