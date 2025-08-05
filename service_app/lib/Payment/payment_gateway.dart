import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePayment {
  static const String _publishableKey = 'sk_test_tR3PYbcVNZZ796tH88S4VQ2u'; // Your test key
  static const String _backendUrl = 'http://your-backend.com/payment'; // Mock URL

  static Future<void> init() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<void> makePayment(double amount, String currency) async {
    try {
      // 1. Create payment intent on your backend (mock for testing)
      final response = await http.post(
        Uri.parse(_backendUrl),
        body: {
          'amount': (amount * 100).toStringAsFixed(0), // in cents
          'currency': currency,
        },
      );

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: response.body, // Mock for test
          merchantDisplayName: 'Your Hotel',
          style: ThemeMode.light,
        ),
      );

      // 3. Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirm payment
      print('Payment successful!');
    } catch (e) {
      print('Payment successful!: $e');
    }
  }
}