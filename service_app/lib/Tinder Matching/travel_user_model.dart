class TravelUserProfile {
  final String id;
  final String name;
  final String profileImage;
  final String state;
  final String district;
  final String village;
  final int budget;
  final DateTime startDate;
  final DateTime endDate;
  final String personalityType; // Adventure, Relaxation, Cultural, Luxury, Budget
  final String description;
  final int age;
  final String gender;

  TravelUserProfile({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.state,
    required this.district,
    required this.village,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.personalityType,
    required this.description,
    required this.age,
    required this.gender,
  });

  // Check if this profile matches with another based on budget and dates
  bool isMatchWith(TravelUserProfile other) {
    return _budgetMatches(other) && _datesOverlap(other);
  }

  bool _budgetMatches(TravelUserProfile other) {
    // Consider budgets matching if they are within 20% of each other
    int difference = (budget - other.budget).abs();
    int maxAllowed = ((budget + other.budget) / 2 * 0.2).toInt();
    return difference <= maxAllowed || budget == other.budget;
  }

  bool _datesOverlap(TravelUserProfile other) {
    return !endDate.isBefore(other.startDate) &&
        !startDate.isAfter(other.endDate);
  }

  // Get travel duration in days
  int getTravelDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  // Get location string
  String getLocationString() {
    return '$village, $district, $state';
  }
}
