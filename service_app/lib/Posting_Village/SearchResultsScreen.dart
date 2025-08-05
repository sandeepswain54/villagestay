import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:service_app/Odisha/hy.dart';
import 'package:service_app/Odisha/puri1.dart';
import 'package:service_app/Odisha/puri2.dart';
import 'package:service_app/Odisha/puri3.dart';
import 'package:service_app/Odisha/puri4.dart';
import 'package:service_app/Odisha/puri5.dart';
import 'package:service_app/Odisha/puri7.dart';
import 'package:service_app/Posting_Village/hotel_detail_screen.dart';
import 'package:service_app/Posting_Village/village_extension.dart';
import 'package:service_app/Telangana/tel.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

   SearchResultsScreen({super.key, required this.query});

  // Define hotel data
  final List<Map<String, dynamic>> hotels = [
    {
      'name': 'Raghurajapur Heritage',
      'location': 'Mahalaxmi Race Course, South Mumbai',
      'rating': '3.8 (220)',
      'offer': 'Get 10% OFF with wallet',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1679', '3 Hrs'),
        ('₹2180', '6 Hrs'),
        ('₹2999', '12 Hrs'),
      ],
      'destination': PuriHotelDetailScreen(),
    },
    {
      'name': 'Puri Beach Resort',
      'location': 'Puri, Odisha',
      'rating': '4.2 (150)',
      'offer': 'Free breakfast included',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1999', '3 Hrs'),
        ('₹2599', '6 Hrs'),
        ('₹3499', '12 Hrs'),
      ],
      'destination': PuriHotelDetailScreen(),
    },
    {
      'name': 'Konark View Hotel',
      'location': 'Odisha',
      'rating': '4.5 (180)',
      'offer': 'Weekend special 15% OFF',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹2299', '3 Hrs'),
        ('₹2999', '6 Hrs'),
        ('₹3999', '12 Hrs'),
      ],
      'destination': HolidayResortDetailScreen(),
    },
    {
      'name': 'Pochampally Village',
      'location': 'Hyderabad, Telangana',
      'rating': '4.1 (195)',
      'offer': 'tie & dye textile',
      'images': [
        'assets/tel.jpg',
        'assets/tel2.jpg',
        'assets/tel3.jpg',
        'assets/tel4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': Tel(),
    },

     {
      'name': 'Grand',
      'location': 'Sikkim',
      'rating': '4.1 (195)',
      'offer': 'Early bird discount 20%',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
      {
      'name': 'Grand',
      'location': 'Sikkim',
      'rating': '4.1 (195)',
      'offer': 'Early bird discount 20%',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
      {
      'name': 'Grand',
      'location': 'Sikkim',
      'rating': '4.1 (195)',
      'offer': 'Early bird discount 20%',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
    {
      'name': 'Shamirpet Village',
      'location': 'Hyderabad, Telangana',
      'rating': '4.1 (195)',
      'offer': 'Lake & deer park',
      'images': [
        'assets/tel12.webp',
        'assets/tel13.avif',
        'assets/tel14.webp',
        'assets/tel15.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
    {
      'name': 'Ananthagiri Village',
      'location': 'Hyderabad, Telangana',
      'rating': '4.1 (195)',
      'offer': ' Coffee & hill views',
      'images': [
        'assets/tel6.jpg',
        'assets/tel7.jpg',
        'assets/tel8.jpg',
        'assets/tel8.jpg',
      ],
      'priceOptions': [
        ('₹10k', '3 Days'),
        ('₹18K', '5 Days'),
        ('₹25K', '7 Days'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
     {
      'name': 'Grand',
      'location': 'Punjab',
      'rating': '4.1 (195)',
      'offer': 'Early bird discount 20%',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
     {
      'name': 'Grand',
      'location': 'Punjab',
      'rating': '4.1 (195)',
      'offer': 'Early bird discount 20%',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
     {
      'name': 'Grand',
      'location': 'Punjab',
      'rating': '4.1 (195)',
      'offer': 'Early bird discount 20%',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹1899', '3 Hrs'),
        ('₹2399', '6 Hrs'),
        ('₹3299', '12 Hrs'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
    {
      'name': 'Nalgonda Village',
      'location': 'Hyderabad, Telangana',
      'rating': '4.1 (195)',
      'offer': 'Ancient Buddhist sites',
      'images': [
        'assets/tel9.jpg',
        'assets/tel10.webp',
        'assets/tel11.webp',
        'assets/tel11.webp',
      ],
      'priceOptions': [
        ('₹12k', '3 Days'),
        ('₹20K', '5 Days'),
        ('₹28K', '7 Days'),
      ],
      'destination': SeaPearlHotelDetailScreen(),
    },
    {
      'name': 'Chilika Lake Retreat',
      'location': 'Balakuda, Odisha',
      'rating': '4.3 (210)',
      'offer': 'Complimentary spa access',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹2499', '3 Hrs'),
        ('₹3199', '6 Hrs'),
        ('₹4299', '12 Hrs'),
      ],
      'destination': MayfairResortDetailScreen(),
    },

    {
      'name': 'Kumarakom Village',
      'location': 'Kerala',
      'rating': '4.3 (210)',
      'offer': 'Complimentary spa access',
      'images': [
        'assets/keral.jpg',
        'assets/keral2.jpg',
        'assets/keral3.jpg',
        'assets/keral4.jpg',
      ],
      'priceOptions': [
        ('₹2499', '3 Hrs'),
        ('₹3199', '6 Hrs'),
        ('₹4299', '12 Hrs'),
      ],
      'destination': MayfairResortDetailScreen(),
    },

    
    {
      'name': 'Vypin Village',
      'location': 'Kerala',
      'rating': '4.3 (50)',
      'offer': 'Beaches and fishing',
      'images': [
        'assets/keral15.jpg',
        'assets/keral16.jpg',
        'assets/keral17.jpg',
        'assets/keral17.jpg',
      ],
      'priceOptions': [
        ('₹2499', '3 Hrs'),
        ('₹3199', '6 Hrs'),
        ('₹4299', '12 Hrs'),
      ],
      'destination': MayfairResortDetailScreen(),
    },

    
    {
      'name': 'Aranmula Village',
      'location': 'Kerala',
      'rating': '4.3 (210)',
      'offer': 'Complimentary spa access',
      'images': [
        'assets/keral10.jpg',
        'assets/keral11.jpg',
        'assets/keral12.jpg',
        'assets/keral13.jpg',
      ],
      'priceOptions': [
        ('₹2499', '3 Hrs'),
        ('₹3199', '6 Hrs'),
        ('₹4299', '12 Hrs'),
      ],
      'destination': MayfairResortDetailScreen(),
    },

    
    {
      'name': 'Kumarakom',
      'location': 'Kerala',
      'rating': '4.3 (210)',
      'offer': 'Complimentary spa access',
      'images': [
        'assets/keral.jpg',
        'assets/keral2.jpg',
        'assets/keral3.jpg',
        'assets/keral4.jpg',
      ],
      'priceOptions': [
        ('₹2499', '3 Hrs'),
        ('₹3199', '6 Hrs'),
        ('₹4299', '12 Hrs'),
      ],
      'destination': MayfairResortDetailScreen(),
    },
    {
      'name': 'Gopalpur Sea View',
      'location': 'Ranchi, Jharkhand',
      'rating': '4.7 (175)',
      'offer': 'Honeymoon package available',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',
      ],
      'priceOptions': [
        ('₹2799', '3 Hrs'),
        ('₹3599', '6 Hrs'),
        ('₹4799', '12 Hrs'),
      ],
      'destination': ToshaliSandsDetailScreen(),
    },{
      'name': 'hyderbad',
      'location': 'Telangana',
      'rating': '3.8 (220)',
      'offer': 'Get 10% OFF with wallet',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',],

         'destination':PuriHotelDetailScreen(),

    },

    {
      'name': 'hyderbad',
      'location': 'Telangana',
      'rating': '3.8 (220)',
      'offer': 'Get 10% OFF with wallet',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',],

         'destination':PuriHotelDetailScreen(),

    },
    {
      'name': 'ikat',
      'location': 'Himachal',
      'rating': '3.8 (220)',
      'offer': 'Get 10% OFF with wallet',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',],

         'destination':PuriHotelDetailScreen(),

    }
    ,{
      'name': 'Himachal',
      'location': 'Rajasthan',
      'rating': '3.8 (220)',
      'offer': 'Get 10% OFF with wallet',
      'images': [
        'assets/jagaa1.jpg',
        'assets/jaga2.jpg',
        'assets/jaga3.jpg',
        'assets/jaga4.jpg',],

         'destination':PuriHotelDetailScreen(),

    }
  ];

  @override
  Widget build(BuildContext context) {
    // Filter hotels based on the search query
    final filteredHotels = hotels.where((hotel) {
      return hotel['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
             hotel['location'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search Results for "$query"'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filteredHotels.isEmpty
              ? [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No hotels found for "$query"',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ),
                ]
              : filteredHotels.map((hotel) {
                  return Column(
                    children: [
                      _buildHotelListing(
                        context,
                        images: hotel['images'],
                        rating: hotel['rating'],
                        offer: hotel['offer'],
                        name: hotel['name'],
                        location: hotel['location'],
                        priceOptions: hotel['priceOptions'],
                      ).onTap(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => hotel['destination']),
                        );
                      }),
                      SizedBox(height: 30),
                    ],
                  );
                }).toList(),
        ),
      ),
    );
  }

  // Reusable Hotel Listing Widget (same as in your original code)
  Widget _buildHotelListing(
    BuildContext context, {
    required List<String> images,
    required String rating,
    required String offer,
    required String name,
    required String location,
    required List<(String, String)> priceOptions,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                aspectRatio: 16 / 9,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
              items: images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.orange, size: 18),
                    SizedBox(width: 6),
                    Text(
                      offer,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  featureIcon(Icons.people, "Couple Friendly"),
                  featureIcon(Icons.verified_user, "Accepts Local ID"),
                  featureIcon(Icons.payment, "Pay at Hotel"),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: priceOptions.map((option) {
                  return priceOption(option.$1, option.$2);
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  // Feature Icon Widget
  Widget featureIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple, size: 28),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Price Option Widget
  Widget priceOption(String price, String duration) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            price,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            duration,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}