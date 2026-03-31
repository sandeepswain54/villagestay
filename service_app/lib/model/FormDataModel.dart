// ✅ MODEL: FormData - Holds all form submission data
class FormData {
  final String propertyName;
  final String location;
  final String description;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> slots;
  final List<String> selectedAmenities;

  FormData({
    required this.propertyName,
    required this.location,
    required this.description,
    required this.imageUrls,
    required this.slots,
    required this.selectedAmenities,
  });

  // Helper method to convert to JSON for storage if needed
  Map<String, dynamic> toMap() {
    return {
      'propertyName': propertyName,
      'location': location,
      'description': description,
      'imageUrls': imageUrls,
      'slots': slots,
      'selectedAmenities': selectedAmenities,
    };
  }

  @override
  String toString() {
    return 'FormData(name: $propertyName, location: $location, amenities: ${selectedAmenities.length})';
  }
}
