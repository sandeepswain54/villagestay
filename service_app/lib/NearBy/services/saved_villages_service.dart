import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_app/model/village_model.dart';

/// Service to manage saved/liked villages using SharedPreferences
class SavedVillagesService {
  static const String _savedVillagesKey = 'saved_villages';

  /// Save a village to favorites
  static Future<bool> saveVillage(Village village) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing saved villages
      final savedVillages = await getSavedVillages();
      
      // Check if already saved
      final isAlreadySaved = savedVillages.any(
        (v) => v.villageName.toLowerCase() == village.villageName.toLowerCase(),
      );
      
      if (isAlreadySaved) {
        return false; // Already saved
      }
      
      // Add new village
      savedVillages.add(village);
      
      // Convert to JSON list and save
      final jsonList = savedVillages.map((v) => v.toJson()).toList();
      return await prefs.setString(_savedVillagesKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving village: $e');
      return false;
    }
  }

  /// Remove a village from favorites
  static Future<bool> removeVillage(String villageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing saved villages
      final savedVillages = await getSavedVillages();
      
      // Remove the village
      savedVillages.removeWhere(
        (v) => v.villageName.toLowerCase() == villageName.toLowerCase(),
      );
      
      // Save updated list
      final jsonList = savedVillages.map((v) => v.toJson()).toList();
      return await prefs.setString(_savedVillagesKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error removing village: $e');
      return false;
    }
  }

  /// Get all saved villages
  static Future<List<Village>> getSavedVillages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedVillagesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Village.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting saved villages: $e');
      return [];
    }
  }

  /// Check if a village is saved
  static Future<bool> isVillageSaved(String villageName) async {
    try {
      final savedVillages = await getSavedVillages();
      return savedVillages.any(
        (v) => v.villageName.toLowerCase() == villageName.toLowerCase(),
      );
    } catch (e) {
      print('Error checking if village is saved: $e');
      return false;
    }
  }

  /// Get count of saved villages
  static Future<int> getSavedVillagesCount() async {
    try {
      final savedVillages = await getSavedVillages();
      return savedVillages.length;
    } catch (e) {
      print('Error getting saved villages count: $e');
      return 0;
    }
  }

  /// Clear all saved villages
  static Future<bool> clearAllSavedVillages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_savedVillagesKey);
    } catch (e) {
      print('Error clearing saved villages: $e');
      return false;
    }
  }

  /// Batch save multiple villages
  static Future<bool> saveMultipleVillages(List<Village> villages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing saved villages
      final savedVillages = await getSavedVillages();
      
      // Add new villages (avoid duplicates)
      for (var village in villages) {
        final isAlreadySaved = savedVillages.any(
          (v) => v.villageName.toLowerCase() == village.villageName.toLowerCase(),
        );
        
        if (!isAlreadySaved) {
          savedVillages.add(village);
        }
      }
      
      // Convert to JSON list and save
      final jsonList = savedVillages.map((v) => v.toJson()).toList();
      return await prefs.setString(_savedVillagesKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving multiple villages: $e');
      return false;
    }
  }
}
