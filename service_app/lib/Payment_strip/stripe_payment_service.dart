import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripePaymentService {
  static const String _stripePublishableKey = 'pk_test_51RsRQ8BCTnOXS0aflRvlaUpkrzZM9J2mi0meUhYMy7r3IranTTbTY6UVgDFeFb1ElOnCZoAkIEQQHffAfXdtvy5U00I7XAdahh';
  static const String _stripeSecretKey = 'sk_test_51RsRQ8BCTnOXS0afQjN1SKqIsCajbi1skKH8FD8T95jbeV5aOVekZcycFEURs7qhqpfFXQftP7cJj6euu5CSvnWi00YDxQJV4l';
  static const String _paymentIntentUrl = 'https://api.stripe.com/v1/payment_intents';

  static Future<void> init() async {
    Stripe.publishableKey = _stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<String> _createPaymentIntent(double amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse(_paymentIntentUrl),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toStringAsFixed(0), // Convert to cents
          'currency': currency.toLowerCase(),
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['client_secret'];
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment intent creation failed: $e');
    }
  }

  static Future<void> makePayment(double amount, String currency) async {
    try {
      // 1. Create payment intent
      final clientSecret = await _createPaymentIntent(amount, currency);

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Kumarakom Village',
          style: ThemeMode.light,
          customerId: 'customer_id', // Optional
          customerEphemeralKeySecret: 'ephemeral_key', // Optional
        ),
      );

      // 3. Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Payment successful
      print('Payment successful!');
    } catch (e) {
      print('Payment failed: $e');
      rethrow;
    }
  }
}