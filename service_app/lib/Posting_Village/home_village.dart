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

import 'package:service_app/Tinder%20Matching/PlanTripScreen.dart'; // Add this import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════
            // HERO SECTION WITH GREETING & BACKGROUND
            // ═══════════════════════════════════════
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/ty1.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header with notification and profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello Traveler! 👋",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Main Heading
                    Text(
                      "Ready For Your Next Amazing Adventure Trip Today?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Quick Action Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePlacesScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(Icons.location_on, size: 20),
                        label: Text(
                          "Explore Nearby",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════
            // SEARCH BAR
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search place, city...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.tune, color: Colors.white, size: 20),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════
            // CATEGORY CHIPS
            // ═══════════════════════════════════════
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _categoryChip('🏖️ Beach', true),
                  _categoryChip('⛰️ Mountains', false),
                  _categoryChip('🌲 Forest', false),
                  _categoryChip('🏛️ Heritage', false),
                  _categoryChip('🎪 Events', false),
                ],
              ),
            ),

            SizedBox(height: 28),

            // ═══════════════════════════════════════
            // POPULAR CHOICE PLACES SECTION
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular Choice Places",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultsScreen(query: 'all'),
                        ),
                      );
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Popular Places Cards
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _placeCard(
                    'assets/odisha.jpg',
                    'Odisha Paradise',
                    'East Coast',
                    '/odisha',
                    context,
                  ),
                  _placeCard(
                    'assets/hi1.jpg',
                    'Kerala Backwaters',
                    'South India',
                    '/kerala',
                    context,
                  ),
                  _placeCard(
                    'assets/hi.jpg',
                    'Sikkim Hills',
                    'North-East',
                    '/sikkim',
                    context,
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            // ═══════════════════════════════════════
            // FEATURED TRIP CARD (On Going)
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/ty2.avif',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "On Going",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_outward,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Magical Village Tour",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Odisha, India",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════
            // TRAVEL BUDDY SECTION
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.purple[50],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/ty2.avif',
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Find Travel Buddy",
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Connect & explore together",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlanTripScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Match Now",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
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

            SizedBox(height: 24),

            // ═══════════════════════════════════════
            // OFFERS SECTION
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Special Offers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 12),

            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _offerCard('assets/yu.jpg'),
                  _offerCard('assets/yu2.jpg'),
                  _offerCard('assets/yu3.jpg'),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════
            // BENEFITS GRID
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Why Choose Us",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
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
                  _benefitCard('assets/ty3.jpg', 'Authentic Stays', 'Local & genuine'),
                  _benefitCard('assets/ty4.jpg', 'Safe Travel', 'Verified & secure'),
                  _benefitCard('assets/ty5.jpg', 'Local Culture', 'Immersive experience'),
                  _benefitCard('assets/ty6.jpg', '24/7 Support', 'Always here for you'),
                ],
              ),
            ),

            SizedBox(height: 32),

            // ═══════════════════════════════════════
            // BOTTOM CTA SECTION
            // ═══════════════════════════════════════
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50).withOpacity(0.1),
                    Color(0xFF45a049).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF4CAF50).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Discover Authentic Villages",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Experience genuine local life & culture",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════

  /// Category Chip Widget
  Widget _categoryChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF4CAF50) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Popular Place Card Widget
  Widget _placeCard(
    String image,
    String title,
    String location,
    String route,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(query: title),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_outward,
                  color: Color(0xFF4CAF50),
                  size: 16,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Benefit Card Widget
  Widget _benefitCard(String image, String title, String desc) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
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
                colors: [Colors.black26, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Offer Card Widget
  Widget _offerCard(String image) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
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

