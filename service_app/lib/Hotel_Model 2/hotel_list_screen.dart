import 'package:flutter/material.dart';
import 'package:service_app/Hotel_Model%202/hotel.dart';
import 'package:service_app/Hotel_Model%202/hotel_service.dart';
import 'package:service_app/Posting_Village/hotel_detail_screen.dart';


class HotelListScreen extends StatelessWidget {
  final String city;
  final DateTime date;
  final String time;

  const HotelListScreen({
    super.key,
    required this.city,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hotels in $city")),
      body: FutureBuilder<List<Hotel>>(
        future: HotelService.getHotels(city: city),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hotels found'));
          }

          final hotels = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return _buildHotelCard(context, hotel);
            },
          );
        },
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailScreen(hotel: hotel, hotelName: '', 
              images: [], reviewCount: 0, address: '',
               amenities: [], description: '', rating: 0, priceOptions: [],),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  hotel.images.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.rating} (${hotel.reviews})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hotel.location,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (hotel.coupleFriendly) ...[
                        _buildFeatureChip(Icons.people, "Couple Friendly"),
                        const SizedBox(width: 8),
                      ],
                      if (hotel.acceptsLocalId) ...[
                        _buildFeatureChip(Icons.verified_user, "Accepts Local ID"),
                        const SizedBox(width: 8),
                      ],
                      if (hotel.payAtHotel) 
                        _buildFeatureChip(Icons.payment, "Pay at Hotel"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceOption('₹${hotel.pricing['3 Hrs']}', '3 Hrs'),
                      _buildPriceOption('₹${hotel.pricing['6 Hrs']}', '6 Hrs'),
                      _buildPriceOption('₹${hotel.pricing['12 Hrs']}', '12 Hrs'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.purple[50],
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPriceOption(String price, String duration) {
    return Column(
      children: [
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(duration, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}