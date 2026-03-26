class TripModel {
  final String id;
  final String name;
  final String profileImage;
  final String description;
  final int budget;
  final DateTime startDate;
  final DateTime endDate;
  final String state;
  final String district;
  final String village;
  final String personalityType;
  final int age;
  final String gender;
  final List<String> imagePaths;

  TripModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.description,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.state,
    required this.district,
    required this.village,
    required this.personalityType,
    required this.age,
    required this.gender,
    required this.imagePaths,
  });

  // Check if this trip matches with another
  bool isMatchWith(TripModel other) {
    return _budgetMatches(other) && _datesOverlap(other);
  }

  bool _budgetMatches(TripModel other) {
    int difference = (budget - other.budget).abs();
    int maxAllowed = ((budget + other.budget) / 2 * 0.2).toInt();
    return difference <= maxAllowed;
  }

  bool _datesOverlap(TripModel other) {
    return !endDate.isBefore(other.startDate) &&
        !startDate.isAfter(other.endDate);
  }

  String getLocation() => '$village, $district, $state';

  int getTravelDays() => endDate.difference(startDate).inDays + 1;
}
