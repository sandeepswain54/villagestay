enum VillageCategory {
  discover,
  saved,
  tribal,
  craft,
  eco,
}

extension VillageCategoryExtension on VillageCategory {
  String get displayName {
    switch (this) {
      case VillageCategory.discover:
        return 'Discover';
      case VillageCategory.saved:
        return 'Saved';
      case VillageCategory.tribal:
        return 'Tribal';
      case VillageCategory.craft:
        return 'Craft';
      case VillageCategory.eco:
        return 'Eco';
    }
  }

  /// Get the icon name for this category
  String get iconName {
    switch (this) {
      case VillageCategory.discover:
        return 'explore';
      case VillageCategory.saved:
        return 'favorite';
      case VillageCategory.tribal:
        return 'groups';
      case VillageCategory.craft:
        return 'palette';
      case VillageCategory.eco:
        return 'eco';
    }
  }

  /// Get the color code for this category
  String get colorHex {
    switch (this) {
      case VillageCategory.discover:
        return '#4CAF50';
      case VillageCategory.saved:
        return '#FF5252';
      case VillageCategory.tribal:
        return '#FF9800';
      case VillageCategory.craft:
        return '#9C27B0';
      case VillageCategory.eco:
        return '#00BCD4';
    }
  }
}

/// Helper class to get a VillageCategory from a string (e.g., from JSON)
class VillageCategoryHelper {
  /// Convert string to VillageCategory enum
  /// If the string doesn't match any category, returns null or defaults to discover
  static VillageCategory? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final lowerValue = value.toLowerCase();
    for (var category in VillageCategory.values) {
      if (category.name == lowerValue) {
        return category;
      }
    }
    return null;
  }

  /// Check if a village's category matches the filter
  /// DISCOVER shows all villages
  /// SAVED is handled separately (requires SharedPreferences check)
  /// Others match exact category name
  static bool matches(String villageCategory, VillageCategory filterCategory) {
    if (filterCategory == VillageCategory.discover) {
      return true; // Show all villages
    }
    
    if (filterCategory == VillageCategory.saved) {
      return true; // Handled separately in UI
    }
    
    return villageCategory.toLowerCase() == filterCategory.displayName.toLowerCase();
  }

  /// Get all available categories as display list
  static List<VillageCategory> getAllCategories() {
    return VillageCategory.values;
  }
}
