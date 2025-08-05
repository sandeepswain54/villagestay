import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';  // Add Provider
import 'package:service_app/ADMIN/host_waiting_screen.dart';
import 'package:service_app/CORE/stripe_service.dart';
import 'package:service_app/model/app_constant.dart';
import 'package:service_app/model/user_model.dart';
import 'package:service_app/views/home_screen.dart';
import 'package:service_app/views/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Stripe
  await StripePaymentService.initialize();

  // Initialize current user
  AppConstants.currentUser = UserModel();

  runApp(
    MultiProvider(
      providers: [
        Provider<StripePaymentService>(  // Provide StripeService globally
          create: (_) => StripePaymentService(),
        ),
      ],
      child: MyApp(),  // Your main app widget
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // Using GetX for navigation
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const Login();
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                // Check host approval status
                if (userData['isHost'] == true &&
                    (userData['hostStatus'] == null || userData['hostStatus'] == 'pending')) {
                  return const HostWaitingScreen();
                }

                return const HomeScreen();
              },
            );
          }
          return const Login();
        },
      ),
    );
  }
}