import 'package:service_app/Hotel_Model%202/hotel.dart';



class HotelService {
  static Future<List<Hotel>> getHotels({String? city}) async {
    // Mock data - in real app, this would be API call
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    final allHotels = [
      Hotel(
        id: '1',
        name: 'Raghurajapur Heritage',
        city: 'Puri',
        location: 'Near Puri Beach',
        rating: 4.2,
        reviews: 150,
        images: ['assets/jagaa1.jpg', 'assets/jaga2.jpg'],
        coupleFriendly: true,
        acceptsLocalId: true,
        payAtHotel: true,
        pricing: {'3 Hrs': 1999, '6 Hrs': 2599, '12 Hrs': 3499},
      ),
      Hotel(
        id: '2',
        name: 'Puri Beach Resort',
        city: 'Puri',
        location: 'Beach Road',
        rating: 4.5,
        reviews: 180,
        images: ['assets/hotel3.jpeg', 'assets/hotel4.jpeg'],
        coupleFriendly: true,
        acceptsLocalId: true,
        payAtHotel: false,
        pricing: {'3 Hrs': 2299, '6 Hrs': 2999, '12 Hrs': 3999},
      ),
      // Add more hotels for different cities
    ];

    if (city != null) {
      return allHotels.where((hotel) => hotel.city.toLowerCase() == city.toLowerCase()).toList();
    }
    return allHotels;
  }

  static Future<List<String>> getCities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      "Hyderabad", "Delhi", "Gurgaon", "Bangalore", "Mysore", 
      "Mumbai", "Navi Mumbai", "Chandigarh", "Jaipur", "Chennai", 
      "Lucknow", "Puri", "Bhubaneswar"
    ];
  }
}