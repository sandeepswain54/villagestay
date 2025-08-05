// tourist_navigation.dart
import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/material.dart';

import 'package:service_app/New_Upload/extensions.dart';
import 'package:service_app/New_Upload/firebase_service.dart' show FirebaseService;
import 'package:service_app/New_Upload/post_card.dart' show PostCard;

class TouristNavigation extends StatefulWidget {
  const TouristNavigation({super.key});

  @override
  State<TouristNavigation> createState() => _TouristNavigationState();
}

class _TouristNavigationState extends State<TouristNavigation> {
  int _currentIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();

  final List<Widget> _touristScreens = [
    const TouristHomeScreen(),
    const TouristExploreScreen(),
    const TouristProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _touristScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class TouristHomeScreen extends StatelessWidget {
  const TouristHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Tourist Home')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading posts'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final posts = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                title: post['title'],
                description: post['description'],
                imageBase64: post['image'],
                type: post['type'],
                price: post['price'],
              );
            },
          );
        },
      ),
    );
  }
}

class TouristExploreScreen extends StatelessWidget {
  const TouristExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          _buildCategoryButton(context, 'Hotels', Icons.hotel),
          _buildCategoryButton(context, 'Cabs', Icons.directions_car),
          _buildCategoryButton(context, 'Tours', Icons.tour),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(category: title.toLowerCase()),
            ),
          );
        },
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    
    return Scaffold(
      appBar: AppBar(title: Text(category.capitalize())),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getPostsByType(category),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading posts'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final posts = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                title: post['title'],
                description: post['description'],
                imageBase64: post['image'],
                type: post['type'],
                price: post['price'],
              );
            },
          );
        },
      ),
    );
  }
}

class TouristProfileScreen extends StatelessWidget {
  const TouristProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Tourist Profile Screen')),
    );
  }
}