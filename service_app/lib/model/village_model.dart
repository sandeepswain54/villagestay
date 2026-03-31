class Village {
  final String villageName;
  final String category;
  final String shortDescription;
  final List<String> images;
  final List<String> experiences;
  final List<String> localProducts;
  final List<String> revenueStreams;
  final String bestTimeToVisit;
  final int approxDistanceFromDistrictHqKm;

  Village({
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

  // Convert JSON to Village object
  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      villageName: json['village_name'] ?? '',
      category: json['category'] ?? '',
      shortDescription: json['short_description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      experiences: List<String>.from(json['experiences'] ?? []),
      localProducts: List<String>.from(json['local_products'] ?? []),
      revenueStreams: List<String>.from(json['revenue_streams'] ?? []),
      bestTimeToVisit: json['best_time_to_visit'] ?? '',
      approxDistanceFromDistrictHqKm: json['approx_distance_from_district_hq_km'] ?? 0,
    );
  }

  // Convert Village object to JSON
  Map<String, dynamic> toJson() {
    return {
      'village_name': villageName,
      'category': category,
      'short_description': shortDescription,
      'images': images,
      'experiences': experiences,
      'local_products': localProducts,
      'revenue_streams': revenueStreams,
      'best_time_to_visit': bestTimeToVisit,
      'approx_distance_from_district_hq_km': approxDistanceFromDistrictHqKm,
    };
  }

  @override
  String toString() => 'Village(name: $villageName, category: $category)';
}

class VillageData {
  final String district;
  final List<Village> villages;

  VillageData({
    required this.district,
    required this.villages,
  });

  // Convert JSON to VillageData object
  factory VillageData.fromJson(Map<String, dynamic> json) {
    var villagesJson = json['villages'] as List<dynamic>;
    List<Village> villagesList =
        villagesJson.map((v) => Village.fromJson(v as Map<String, dynamic>)).toList();

    return VillageData(
      district: json['district'] ?? '',
      villages: villagesList,
    );
  }

  // Convert VillageData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'district': district,
      'villages': villages.map((v) => v.toJson()).toList(),
    };
  }

  @override
  String toString() => 'VillageData(district: $district, villagesCount: ${villages.length})';
}

// Helper class for parsing the entire villages.json file
class VillagesDataSet {
  final List<VillageData> districtData;

  VillagesDataSet({required this.districtData});

  factory VillagesDataSet.fromJson(List<dynamic> jsonList) {
    List<VillageData> data =
        jsonList.map((d) => VillageData.fromJson(d as Map<String, dynamic>)).toList();
    return VillagesDataSet(districtData: data);
  }

  @override
  String toString() => 'VillagesDataSet(districts: ${districtData.length})';
}
