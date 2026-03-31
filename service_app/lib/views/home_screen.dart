import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:service_app/Chat_Bot/chat_screen.dart';
import 'package:service_app/GreenDot/nearby.dart';
import 'package:service_app/Posting_Village/home_village.dart';
import 'package:service_app/SHOPING/home_shop.dart';
import 'package:service_app/views/Host_Screens/booking.dart';
import 'package:service_app/model/Screens_home/acccount_screen.dart';
import 'package:service_app/OpenStreet/openstreet.dart';
import 'package:service_app/NearBy/nearby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selelectedIndex = 0;
  bool _showUnreadBadge = true;

  final List<String> screenTitles = [
    'Home',
    'Upload',
    'Profile',
    'Nearby',
    
  ];

  final List<Widget> screens = [
    HomePage(),
    Openstreet(),
     AccountScreen(),
    TravelExploreScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFF967BB6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          screenTitles[selelectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: selelectedIndex,
        children: screens,
      ),
      floatingActionButton: selelectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                setState(() => _showUnreadBadge = false);
                Get.to(() => ChatScreen()); // Uses provider globally
              },
              backgroundColor: Colors.blue[600],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.chat_bubble, color: Colors.white, size: 30),
                  if (_showUnreadBadge)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.save_rounded, "Upload", 1),
              _buildNavItem(Icons.location_searching_sharp, "Nearby", 3),
              _buildNavItem(Icons.person, "Profile", 2),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selelectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selelectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.purple : Colors.black),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
            ]
          ],
        ),
      ),
    );
  }
}
