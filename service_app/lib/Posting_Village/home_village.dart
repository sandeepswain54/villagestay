import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:service_app/DATE&%20Booking/city_search_delegate.dart' show CitySearchDelegate;
import 'package:service_app/DATE&%20Booking/city_selection.dart';
import 'package:service_app/DATE&%20Booking/date_selection.dart';
import 'package:service_app/Hotel_Model%202/hotel.dart';
import 'package:service_app/NearBy/village_explorer_screen.dart';
import 'package:service_app/Odisha/hy.dart';
import 'package:service_app/Odisha/puri1.dart';
import 'package:service_app/Odisha/puri2.dart';
import 'package:service_app/Odisha/puri3.dart';
import 'package:service_app/Odisha/puri4.dart';
import 'package:service_app/Odisha/puri5.dart';
import 'package:service_app/Odisha/puri7.dart';
import 'package:service_app/PLACES_POST/home_places_screen.dart';
import 'package:service_app/Posting_Village/SearchResultsScreen.dart';
import 'package:service_app/Posting_Village/hotel_detail_screen.dart';
import 'package:service_app/Posting_Village/village_extension.dart';
import 'dart:convert';

import 'package:service_app/Tinder%20Matching/PlanTripScreen.dart';
import 'package:service_app/Travel%20Tinder%20Match/travelhome.dart'; // Add this import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            Stack(
              children: [
                Image.asset(
                  'assets/ty1.jpg', // Replace with top banner image
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      
                      SizedBox(height: 10),
                      Text(
                        "Welcome to Village Stay",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                    
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePlacesScreen(), // Navigate to TravelHomeScreen
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          "Check Nearby Locations",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Search Bar
          // Search Bar - Modified to open city selection
// In your HomePage class, modify the search bar widget:
// In HomePage class, replace the search bar widget with:
// In HomePage class, replace the search bar widget with:
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
  child: GestureDetector(
    onTap: () async {
      final result = await showSearch<String>(
        context: context,
        delegate: CitySearchDelegate(),
      );

      if (result != null && result.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(query: result),
          ),
        );
      }
    },
    child: AbsorbPointer(
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search city, state, or hotel...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    ),
  ),
),

            SizedBox(height: 20),

            // Cities Row
         // In HomePage class, update the Cities Row ListView:
SizedBox(
  height: 100,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 16),
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: 'Odisha'),
            ),
          );
        },
        child: cityCard('assets/odisha.jpg', 'Odisha'),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: 'Kerala'),
            ),
          );
        },
        child: cityCard('assets/hi1.jpg', 'Kerala'),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: 'Sikkim'),
            ),
          );
        },
        child: cityCard('assets/hi.jpg', 'Sikkim'),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: 'Hyderabad'),
            ),
          );
        },
        child: cityCard('assets/hi2.jpg', 'Telangana'),
      ),
        GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: 'Punjab'),
            ),
          );
        },
        child: cityCard('assets/hi3.jpg', 'Punjab'),
      ),
        GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: 'Hyderabad'),
            ),
          );
        },
        child: cityCard('assets/hy.png', 'View All'),
      ),
    ],
  ),
),

            SizedBox(height: 20),

            // Relax Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.purple[50],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/ty2.avif', // Replace with sleeping person image
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Find Your Travel Buddy",
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Connect with like-minded travelers and explore the world together.",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                   Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanTripScreen(), // Your PlanTrip screen
      ),
    );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Click to Match"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Offers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Check out these offers",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Offers Horizontal Scroll
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  offerCard('assets/yu.jpg'),
                  offerCard('assets/yu2.jpg'),
                  offerCard('assets/yu3.jpg'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Benefits Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Benefits of Village Stay",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  benefitCard('assets/ty3.jpg', 'Home Stays',
                      'Experience authentic local living with cozy, affordable stays.'),
                  benefitCard('assets/ty4.jpg', 'Cab Services',
                      'Reliable and comfortable rides to your destinations.'),
                  benefitCard('assets/ty5.jpg', 'Cultural Events',
                      'Immerse yourself in vibrant traditions and local celebrations.'),
                  benefitCard('assets/ty6.jpg', 'Travel Guide',
                      'Personalized assistance to make your journey hassle-free.'),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Hourly Hotels Stays Section
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Stay Local & Live Authentic",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your Gateway to Authentic Village Life",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // City Card Widget
  Widget cityCard(String image, String title) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Offer Card Widget
  Widget offerCard(String image) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Benefit Card Widget
  Widget benefitCard(String image, String title, String desc) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  SizedBox(height: 5),
                  Text(desc,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New Screen for Odisha
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Odisha"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Hotel Listing - Raghurajapur Heritage
            _buildHotelListing(
              context,
              images: [
                'assets/jagaa1.jpg',
                'assets/jaga2.jpg',
                'assets/jaga3.jpg',
                'assets/jaga4.jpg',
              ],
              rating: "3.8 (220)",
              offer: "Get 10% OFF with wallet",
              name: "Raghurajapur Heritage",
              location: "Mahalaxmi Race Course, South Mumbai",
              priceOptions: [
                ("₹1679", "3 Hrs"),
                ("₹2180", "6 Hrs"),
                ("₹2999", "12 Hrs"),
              ],
            ).onTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HotelDetailScreen(hotel: Hotel(id: '', name: '', location: '', city: '', reviews: 0, rating: 0,  pricing: {}, images: [], coupleFriendly: true, acceptsLocalId: true, payAtHotel: true), hotelName: '', 
              images: [], reviewCount: 0, address: '',
               amenities: [], description: '', rating: 0, priceOptions: [],),),
              );
            }),
            
            SizedBox(height: 30),
            
            // Second Hotel Listing - Puri Beach Resort
            _buildHotelListing(
              context,
              images: [
                'assets/jagaa1.jpg',
                'assets/jaga2.jpg',
                'assets/jaga3.jpg',
                'assets/jaga4.jpg',
              ],
              rating: "4.2 (150)",
              offer: "Free breakfast included",
              name: "Puri Beach Resort",
              location: "Puri, Odisha",
              priceOptions: [
                ("₹1999", "3 Hrs"),
                ("₹2599", "6 Hrs"),
                ("₹3499", "12 Hrs"),
              ],
            ).onTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HotelDetailScreen(hotel: Hotel(id: '', name: '', location: '', city: '', reviews: 0, rating: 0,  pricing: {}, images: [], coupleFriendly: true, acceptsLocalId: true, payAtHotel: true), hotelName: '', 
              images: [], reviewCount: 0, address: '',
               amenities: [], description: '', rating: 0, priceOptions: [],),),
              );
            }),
            
            SizedBox(height: 30),
            
            // Third Hotel Listing - Konark View Hotel
            _buildHotelListing(
              context,
              images: [
                'assets/jagaa1.jpg',
                'assets/jaga2.jpg',
                'assets/jaga3.jpg',
                'assets/jaga4.jpg',
              ],
              rating: "4.5 (180)",
              offer: "Weekend special 15% OFF",
              name: "Mumbai City",
              location: "mumbai",
              priceOptions: [
                ("₹2299", "3 Hrs"),
                ("₹2999", "6 Hrs"),
                ("₹3999", "12 Hrs"),
              ],
            ).onTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HotelDetailScreen(hotel: Hotel(id: '', name: '', location: '', city: '', reviews: 0, rating: 0,  pricing: {}, images: [], coupleFriendly: true, acceptsLocalId: true, payAtHotel: true), hotelName: '', 
              images: [], reviewCount: 0, address: '',
               amenities: [], description: '', rating: 0, priceOptions: [],),
              ));
            }),

            SizedBox(height: 30),

            // Fourth Hotel Listing - Bhubaneswar Grand
            _buildHotelListing(
              context,
              images: [
                'assets/jagaa1.jpg',
                'assets/jaga2.jpg',
                'assets/jaga3.jpg',
                'assets/jaga4.jpg',
              ],
              rating: "4.1 (195)",
              offer: "Early bird discount 20%",
              name: "Bhubaneswar",
              location: "Central Bhubaneswar",
              priceOptions: [
                ("₹1899", "3 Hrs"),
                ("₹2399", "6 Hrs"),
                ("₹3299", "12 Hrs"),
              ],
            ).onTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SeaPearlHotelDetailScreen()),
              );
            }),

            SizedBox(height: 30),

            // Fifth Hotel Listing - Chilika Lake Retreat
            _buildHotelListing(
              context,
              images: [
                'assets/jagaa1.jpg',
                'assets/jaga2.jpg',
                'assets/jaga3.jpg',
                'assets/jaga4.jpg',
              ],
              rating: "4.3 (210)",
              offer: "Complimentary spa access",
              name: "pune",
              location: "mumbai",
              priceOptions: [
                ("₹2499", "3 Hrs"),
                ("₹3199", "6 Hrs"),
                ("₹4299", "12 Hrs"),
              ],
            ).onTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MayfairResortDetailScreen()),
              );
            }),

            SizedBox(height: 30),

            // Sixth Hotel Listing - Gopalpur Sea View
            _buildHotelListing(
              context,
              images: [
                'assets/jagaa1.jpg',
                'assets/jaga2.jpg',
                'assets/jaga3.jpg',
                'assets/jaga4.jpg',
              ],
              rating: "4.7 (175)",
              offer: "Honeymoon package available",
              name: "ranchi",
              location: "ranchi,jharkhand",
              priceOptions: [
                ("₹2799", "3 Hrs"),
                ("₹3599", "6 Hrs"),
                ("₹4799", "12 Hrs"),
              ],
            ).onTap(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ToshaliSandsDetailScreen()),
              );
            }),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Reusable Hotel Listing Widget
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
                aspectRatio: 16/9,
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

