import 'package:flutter/material.dart' show AlertDialog, BuildContext, Navigator, Text, TextButton, ThemeMode, showDialog;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:service_app/CORE/stripe_key.dart';

final StripePaymentProvider = Provider<StripePaymentService>(
  create: (_) => StripePaymentService(),
  dispose: (_, service) => service.dispose(),
);

class StripePaymentService {
  final Dio _dio = Dio();
  bool _isPaymentInProgress = false;

  // Initialize Stripe with your publishable key (call this at app startup)
  static Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  void dispose() {
    _dio.close();
  }

  Future<void> initPaymentSheet({
    required String amount,
    required String currency,
    required String merchantName,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    try {
      if (_isPaymentInProgress) {
        throw Exception('Another payment is already in progress');
      }
      _isPaymentInProgress = true;

      final paymentIntent = await _createPaymentIntent(amount, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: merchantName,
          style: ThemeMode.light,
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          // Additional parameters for production:
          // applePay: PaymentSheetApplePay(
          //   merchantCountryCode: 'US',
          // ),
          // googlePay: PaymentSheetGooglePay(
          //   merchantCountryCode: 'US',
          //   currencyCode: currency,
          //   testEnv: true,
          // ),
          // customFlow: false,
        ),
      );
    } catch (e) {
      _isPaymentInProgress = false;
      rethrow;
    }
  }

  Future<PaymentSheetPaymentOption?> presentPaymentSheet() async {
    try {
      if (!_isPaymentInProgress) {
        throw Exception('Payment sheet not initialized');
      }

      await Stripe.instance.presentPaymentSheet();
      return await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      _isPaymentInProgress = false;
      rethrow;
    } finally {
      _isPaymentInProgress = false;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final amountInCents = (int.parse(amount) * 100).toString();
      
      if (int.parse(amountInCents) < 50) {
        throw Exception('Amount must be at least 0.50 $currency');
      }

      final body = {
        'amount': amountInCents,
        'currency': currency.toLowerCase(),
        'payment_method_types[]': 'card',
        // Add more parameters as needed:
        // 'capture_method': 'automatic',
        // 'description': 'Mayfair Resort Booking',
      };

      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Succesful to create payment intent: ${response.statusMessage}');
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        'Payment Succesfull: ${e.response?.data['error']['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('Payment processing error: $e');
    }
  }

  // Add this method for handling payment confirmation
  Future<void> handlePaymentSuccess(BuildContext context, String amount) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Your payment of $amount was successful!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Add this method for handling payment failure
  Future<void> handlePaymentError(BuildContext context, String error) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}