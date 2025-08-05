import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:service_app/ADMIN/host_waiting_screen.dart';
import 'package:service_app/model/app_constant.dart';
import 'package:service_app/model/user_model.dart';
import 'package:service_app/views/home_screen.dart';

class UserViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
    required File profileImage,
    bool isHost = false,
    String? serviceType,
    File? govtIdImage,
    String? govtIdNumber,
  }) async {
    try {
      Get.snackbar("Please Wait", "Creating your account");
      
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = credential.user!.uid;
      
      // Upload images
      String profileUrl = await _uploadImage(profileImage, 'users/$userId/profile');
      String? govtIdUrl = isHost ? await _uploadImage(govtIdImage!, 'users/$userId/govt_id') : null;

      // Prepare user data
      Map<String, dynamic> userData = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'country': country,
        'bio': bio,
        'profileImage': profileUrl,
        'isHost': isHost,
        'registrationDate': DateTime.now(),
        if (isHost) ...{
          'serviceType': serviceType,
          'govtIdImage': govtIdUrl,
          'govtIdNumber': govtIdNumber,
          'hostStatus': 'pending', // New field for host approval
        },
      };

      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(userData);

      // Update current user
      AppConstants.currentUser.id = userId;
      AppConstants.currentUser.email = email;
      AppConstants.currentUser.firstName = firstName;
      AppConstants.currentUser.lastName = lastName;
      AppConstants.currentUser.city = city;
      AppConstants.currentUser.country = country;
      AppConstants.currentUser.bio = bio;
      AppConstants.currentUser.isHost = isHost;
      AppConstants.currentUser.displayImage = MemoryImage(profileImage.readAsBytesSync());

      // Navigate based on user type
      if (isHost) {
        Get.offAll(() => const HostWaitingScreen());
      } else {
        Get.offAll(() => const HomeScreen());
      }
      
      Get.snackbar("Success", "Account created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<String> _uploadImage(File image, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.snackbar("Please wait", "Authenticating...");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(userId).get();

      if (!userDoc.exists) throw Exception("User document not found");

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check host approval status
      if (userData['isHost'] == true && 
          (userData['hostStatus'] == null || userData['hostStatus'] == 'pending')) {
        Get.offAll(() => const HostWaitingScreen());
        return;
      }

      // Update current user
      AppConstants.currentUser.id = userId;
      AppConstants.currentUser.email = userData['email'];
      AppConstants.currentUser.firstName = userData['firstName'];
      AppConstants.currentUser.lastName = userData['lastName'];
      AppConstants.currentUser.city = userData['city'];
      AppConstants.currentUser.country = userData['country'];
      AppConstants.currentUser.bio = userData['bio'];
      AppConstants.currentUser.isHost = userData['isHost'] ?? false;

      Get.offAll(() => const HomeScreen());
      Get.snackbar("Success", "Logged in successfully");

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? 'Authentication error');
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    }
  }

  Future<void> becomeHost(String uid, UserModel currentUser, {
    required String userId,
    required String serviceType,
    required File govtIdImage,
    required String govtIdNumber,
  }) async {
    try {
      Get.snackbar("Processing", "Upgrading to host account");
      
      String govtIdUrl = await _uploadImage(govtIdImage, 'users/$userId/govt_id');

      await _firestore.collection('users').doc(userId).update({
        'isHost': true,
        'serviceType': serviceType,
        'govtIdImage': govtIdUrl,
        'govtIdNumber': govtIdNumber,
        'hostStatus': 'pending',
      });

      AppConstants.currentUser.isHost = true;
      Get.offAll(() => const HostWaitingScreen());
      Get.snackbar("Success", "Host application submitted for approval");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Email Sent", "Password reset link sent to $email",
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Reset Failed", e.message ?? "Failed to send reset email",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}