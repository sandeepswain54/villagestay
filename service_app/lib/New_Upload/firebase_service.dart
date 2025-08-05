// firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload post with image URL (you'll need to convert image to base64 or use another service)
  Future<void> uploadPost({
    required String title,
    required String description,
    required String imageBase64,
    required String type,
    required double price,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore.collection('posts').add({
        'title': title,
        'description': description,
        'image': imageBase64, // Store as base64 string
        'type': type, // e.g., 'hotel', 'cab', 'tour'
        'price': price,
        'hostId': user.uid,
        'hostEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error uploading post: $e');
      rethrow;
    }
  }

  // Get all posts
  Stream<QuerySnapshot> getPosts() {
    return _firestore.collection('posts').orderBy('createdAt', descending: true).snapshots();
  }

  // Get posts by type
  Stream<QuerySnapshot> getPostsByType(String type) {
    return _firestore
        .collection('posts')
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}