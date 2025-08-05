import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_app/CORE/stripe_service.dart';

class PayThroughStripeScreen extends StatelessWidget {
  const PayThroughStripeScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    
    final stripeService = Provider.of<StripePaymentService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Stripe Payment"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await stripeService.initPaymentSheet(
                amount: '1000', // Amount in cents
                currency: 'usd',
                merchantName: 'Your Merchant Name',
              );

              await stripeService.presentPaymentSheet();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
          child: Text("Pay \$10"),
        ),
      ),
    );
  }
}