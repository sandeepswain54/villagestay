import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:service_app/CORE/stripe_service.dart'; // Use correct import path
import 'package:get/get.dart'; // Add GetX for navigation
import 'package:url_launcher/url_launcher.dart';

class MayfairResortDetailScreen extends StatefulWidget {
  const MayfairResortDetailScreen({super.key});

  @override
  State<MayfairResortDetailScreen> createState() => _MayfairResortDetailScreenState();
}

class _MayfairResortDetailScreenState extends State<MayfairResortDetailScreen> {
  Future<void> _handleReserveButton() async {
    final stripeService = Provider.of<StripePaymentService>(context, listen: false);
    final selectedSlot = slotOptions[selectedSlotIndex];
    final amount = selectedSlot['price'].toString();

    setState(() => _isProcessingPayment = true);

    try {
      Get.dialog( // Use GetX dialog
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await stripeService.initPaymentSheet(
        amount: amount,
        currency: 'inr',
        merchantName: 'Mayfair Resort',
      );

      await stripeService.presentPaymentSheet();
      Get.back(); // Close loading dialog

      await Get.dialog( // Use GetX dialog for confirmation
        AlertDialog(
          title: const Text('Booking Confirmed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${selectedSlot['duration']} slot booked successfully'),
              const SizedBox(height: 8),
              Text('Amount: ₹${selectedSlot['price']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(), // Use GetX to close dialog
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Close loading dialog if open

      String errorMessage = 'Payment failed. Please try again.';
      if (e.toString().contains('canceled')) errorMessage = 'Payment was canceled';

      await Get.dialog( // Use GetX dialog for error
        AlertDialog(
          title: const Text('Payment Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Get.back(), // Use GetX to close dialog
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  final ScrollController _scrollController = ScrollController();

  final List<String> propertyImages = [
    'assets/keral5.jpg',
    'assets/keral6.jpg',
    'assets/keral6.jpg',
    'assets/keral5.jpg',
  ];

  // Section keys
  final GlobalKey _amenitiesKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _ratingsKey = GlobalKey();
  final GlobalKey _policiesKey = GlobalKey();

  bool _isProcessingPayment = false;

  // Slot selection variables
  int selectedSlotIndex = 0;
  final List<Map<String, dynamic>> slotOptions = [
    {"duration": "3 Hrs", "price": 1200},
    {"duration": "6 Hrs", "price": 1800},
    {"duration": "12 Hrs", "price": 2500},
  ];

  void _showAllImages() {
    Get.bottomSheet( // Use GetX bottom sheet
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Property Images",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${propertyImages.length} images",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: propertyImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      propertyImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showPriceBreakup() {
    final selectedSlot = slotOptions[selectedSlotIndex];
    final roomPrice = (selectedSlot['price'] * 0.9).round();
    final serviceCharge = selectedSlot['price'] - roomPrice;

    Get.dialog( // Use GetX dialog
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Price Breakup",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Room price"),
                  Text("₹$roomPrice"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Service Charges"),
                  Text("₹$serviceCharge"),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Payable",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${selectedSlot['price']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancellationPolicy() {
    Get.dialog( // Use GetX dialog
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cancellation Policies",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text("• Refund will be provided only if cancellation is done 24 hours prior to selected check-in time."),
              const SizedBox(height: 8),
              const Text("• In case booking has been done within 24 hours of check-in time, the refund will be provided only if the booking is cancelled within 15 minutes from the time of booking."),
              const SizedBox(height: 8),
              const Text("• There will be no refund, If you do not show up at the hotel."),
              const SizedBox(height: 8),
              const Text("• There will be no refund if you decide to cancel the booking in the middle of your stay."),
              const SizedBox(height: 8),
              const Text("• If eligible, refund will be initiated, which will reflect in your account within 5-7 business days."),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps(String location) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch $uri'); // Use GetX snackbar
    }
  }

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showSlotSelector() {
    Get.bottomSheet( // Use GetX bottom sheet
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a Slot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(slotOptions.length, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: selectedSlotIndex,
                onChanged: (value) {
                  setState(() {
                    selectedSlotIndex = value!;
                  });
                  Get.back(); // Use GetX to close bottom sheet
                },
                title: Text(
                  "₹${slotOptions[index]['price']}  ${slotOptions[index]['duration']}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.back(); // Close bottom sheet
                _showCancellationPolicy();
              },
              child: const Text(
                "View Cancellation Policy",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kumarakom Village"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Hotel Image
          Stack(
            children: [
              Image.asset(
                'assets/keral2.jpg',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _showAllImages,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.collections, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "View all ${propertyImages.length} images",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  tabButton("INTRO", () {}),
                  tabButton("FACILITIES", () => _scrollToSection(_amenitiesKey)),
                  tabButton("LOCATION", () => _scrollToSection(_locationKey)),
                  tabButton("RATINGS", () => _scrollToSection(_ratingsKey)),
                  tabButton("RULES & POLICIES", () => _scrollToSection(_policiesKey)),
                ],
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        const Text(
                          "4.2 (180)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Kumarakom Village",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Kerala",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        featureChip(Icons.people, "Couple Friendly"),
                        featureChip(Icons.verified_user, "Accepts Local ID"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Pay At Hotel Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pay At Hotel available",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "*Wallet discount not applicable on PAH booking",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Learn More",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Referral Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Refer friends and win",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "assured 250 wallet points",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "*T&C Applied",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AMENITIES Section
                    Column(
                      key: _amenitiesKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AMENITIES",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Things that make the stay better",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        amenityItem("Air Conditioner"),
                        amenityItem("Mineral Water"),
                        amenityItem("Hot Water Geyser"),
                        amenityItem("LED TV"),
                        amenityItem("Beach View"),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View all amenities",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // LOCATION Section
                    Column(
                      key: _locationKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "LOCATION",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Where you need to go",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Kavanattinkara, Kumarakom, Kerala 686563",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Colors.grey),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _launchMaps("Kumarakom");
                          },
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.map,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                    ),
                                    child: const Text(
                                      "View map",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                    // RATINGS Section
                    Column(
                      key: _ratingsKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "RATINGS",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "What people think of it",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "4.2 Based on 180 ratings",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ratingCategory("Smooth Check-in", 4.3),
                        ratingCategory("Room Quality", 4.1),
                        ratingCategory("Hotel Surroundings", 4.5),
                        ratingCategory("Staff Behavior", 4.2),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // POLICIES Section
                    Column(
                      key: _policiesKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "RULES & POLICIES",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "What you must know",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("- Guests must present a valid ID at check-in"),
                        const Text("- Couples over 18 are welcome"),
                        const Text("- Children up to age 5 stay free"),
                        const Text("- No pets allowed"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SIMILAR HOTELS Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Similar Villages Packages",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        similarHotelCard(
                          name: "Kumarakom Village",
                          location: "Kerala",
                          acceptsLocalId: true,
                          payAtHotel: true,
                          prices: [1300, 1900, 2700],
                          imagePath: "assets/keral8.jpg",
                          rating: 4.5,
                          reviews: 8,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Fixed bottom section
          bottomSlotSection(),
        ],
      ),
    );
  }

  Widget tabButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  Widget featureChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget amenityItem(String amenity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(
            amenity,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget ratingCategory(String category, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: rating / 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget similarHotelCard({
    required String name,
    required String location,
    required bool acceptsLocalId,
    required bool payAtHotel,
    required List<int> prices,
    required String imagePath,
    required double rating,
    required int reviews,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "$rating ($reviews)",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(location, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    const Text("Couple Friendly", style: TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(width: 12),
                    const Icon(Icons.verified_user, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    const Text("Accepts Local ID", style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ),
                if (payAtHotel) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "Pay at hotel available on app",
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    priceChip("₹${prices[0]}", "3 Hour"),
                    priceChip("₹${prices[1]}", "6 Hour"),
                    priceChip("₹${prices[2]}", "12 Hour"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget priceChip(String price, String duration) {
    return Column(
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          duration,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget bottomSlotSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey!)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select a Slot",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _showSlotSelector,
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${slotOptions[selectedSlotIndex]['price']} / ${slotOptions[selectedSlotIndex]['duration']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showPriceBreakup,
                      child: const Text(
                        "View price breakup",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessingPayment ? null : _handleReserveButton,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isProcessingPayment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Reserve →",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}