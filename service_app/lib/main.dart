import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:service_app/ADMIN/host_waiting_screen.dart';
import 'package:service_app/CORE/stripe_service.dart';
import 'package:service_app/Chat_Bot/chat_provider.dart';
import 'package:service_app/Chat_Bot/chat_service.dart';
import 'package:service_app/model/app_constant.dart';
import 'package:service_app/model/user_model.dart';
import 'package:service_app/views/home_screen.dart';
import 'package:service_app/views/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show splash screen immediately
  runApp(const SplashScreen());
  
  // Initialize everything in background
  await _initializeApp();
  
  // After initialization, run the main app
  runApp(
    MultiProvider(
      providers: [
        Provider<StripePaymentService>(create: (_) => StripePaymentService()),
        ChangeNotifierProvider(create: (_) => ChatProvider( GroqService())),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    // Load .env file with timeout
    await dotenv.load(fileName: ".env").timeout(const Duration(seconds: 5));
  } catch (e) {
    print('Error loading .env: $e');
  }
  
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  try {
    await StripePaymentService.initialize();
    print('Stripe initialized successfully');
  } catch (e) {
    print('Stripe initialization error: $e');
  }
  
  AppConstants.currentUser = UserModel();
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF5C815E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Village Stay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Village Stay',
      theme: ThemeData(
        primaryColor: const Color(0xFF5C815E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C815E)),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Add a small delay to ensure everything is loaded
      await Future.delayed(const Duration(milliseconds: 500));
      
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          
          if (userData['isHost'] == true &&
              (userData['hostStatus'] == null ||
                  userData['hostStatus'] == 'pending')) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HostWaitingScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Initialization failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAuthState,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}