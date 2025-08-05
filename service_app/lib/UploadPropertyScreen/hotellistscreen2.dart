import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HotelListScreen2 extends StatelessWidget {
  const HotelListScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Hotels'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotels')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hotels found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final hotel = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: hotel['imageUrls'] != null && hotel['imageUrls'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: hotel['imageUrls'][0],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.hotel, size: 40),
                        ),
                  title: Text(
                    hotel['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel['location'] ?? 'No Location'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${hotel['rating']?.toStringAsFixed(1) ?? '0.0'} (${hotel['reviews'] ?? 0})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelDetailScreen(hotelId: doc.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HotelDetailScreen extends StatelessWidget {
  final String hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Hotel Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotels')
            .doc(hotelId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Hotel not found'));
          }

          final hotel = snapshot.data!.data() as Map<String, dynamic>;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                if (hotel['imageUrls'] != null && hotel['imageUrls'].isNotEmpty)
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: hotel['imageUrls'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: hotel['imageUrls'][index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.hotel, size: 60, color: Colors.grey),
                    ),
                  ),

                // Hotel Info
                const SizedBox(height: 16),
                Text(
                  hotel['name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      hotel['location'] ?? 'No Location',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  hotel['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16),
                ),

                // Rating
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${hotel['rating']?.toStringAsFixed(1) ?? '0.0'} (${hotel['reviews'] ?? 0} reviews)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                // Pricing
                const SizedBox(height: 24),
                const Text(
                  'Pricing Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(hotel['slots'] as List?)?.map((slot) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(slot['duration']?.toString() ?? ''),
                    trailing: Text(
                      '₹${slot['price']?.toString() ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )) ?? [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No pricing information available'),
                  ),
                ],

                // Amenities
                const SizedBox(height: 24),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (hotel['amenities'] as List?)?.map((amenity) => Chip(
                    label: Text(amenity?.toString() ?? ''),
                    backgroundColor: Colors.purple[100],
                  ))?.toList() ?? [
                    const Chip(label: Text('No amenities listed')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}