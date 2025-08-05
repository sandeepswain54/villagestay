import 'package:flutter/material.dart';
import 'package:service_app/Hotel_Model%202/hotel.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailScreen extends StatefulWidget {

  
  const HotelDetailScreen({super.key, required Hotel hotel, required String hotelName, required List<String> images, required int reviewCount, required double rating, required String address, required List<String> amenities, required String description, required List<Map<String, String>> priceOptions});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}



class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final ScrollController _scrollController = ScrollController();


final List<String> propertyImages = [ // ADD THIS LIST
    'assets/hotel3.jpeg',
    'assets/hotel4.jpeg',
    'assets/hotel5.jpeg',
    'assets/hotel6.jpeg',
    // Add all your hotel images here
  ];


  // ADD THIS NEW METHOD
void _showAllImages() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
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
                  Text(
                    "Property Images",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${propertyImages.length} images",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      );
    },
  );
}

void _showPriceBreakup() {
  final selectedSlot = slotOptions[selectedSlotIndex];
  final roomPrice = (selectedSlot['price'] * 0.9).round(); // 90% of total
  final serviceCharge = selectedSlot['price'] - roomPrice; // 10% of total

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price Breakup",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Price Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Room price"),
                  Text("₹$roomPrice"),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Service Charges"),
                  Text("₹$serviceCharge"),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Payable",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${selectedSlot['price']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Inside your stateful widget
int selectedSlotIndex = 0;
final List<Map<String, dynamic>> slotOptions = [
  {"duration": "3 Hrs", "price": 1044},
  {"duration": "6 Hrs", "price": 1461},
  {"duration": "12 Hrs", "price": 2142},
];


void _showCancellationPolicy() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Cancellation Policies",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              // Policy Texts
              Text("• Refund will be provided only if cancellation is done 24 hours prior to selected check-in time."),
              SizedBox(height: 8),
              Text("• In case booking has been done within 24 hours of check-in time, the refund will be provided only if the booking is cancelled within 15 minutes from the time of booking."),
              SizedBox(height: 8),
              Text("• There will be no refund, If you do not show up at the hotel."),
              SizedBox(height: 8),
              Text("• There will be no refund if you decide to cancel the booking in the middle of your stay."),
              SizedBox(height: 8),
              Text("• If eligible, refund will be initiated, which will reflect in your account within 5-7 business days."),
            ],
          ),
        ),
      );
    },
  );
}


  // Section keys
  final GlobalKey _amenitiesKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _ratingsKey = GlobalKey();
  final GlobalKey _policiesKey = GlobalKey();

  Future<void> _launchMaps(String location) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hotel Details"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Hotel Image
         // WITH this:
Stack(
  children: [
    Image.asset(
      'assets/jagaa1.jpg',
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.collections, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                "View all ${propertyImages.length} images",
                style: TextStyle(
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


          // Scrollable content above fixed section
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
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "3.8 (220)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Hotel City Avenue",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Mahalaxmi Race Course, South Mumbai, Mumbai",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        featureChip(Icons.people, "Couple Friendly"),
                        featureChip(Icons.verified_user, "Accepts Local ID"),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Pay At Hotel Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pay At Hotel available",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "*Wallet discount not applicable on PAH booking",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
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
                    SizedBox(height: 16),

                    // Referral Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( 
                            "Refer friends and win",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "assured 250 wallet points",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "*T&C Applied",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // AMENITIES Section
                    Column(
                      key: _amenitiesKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AMENITIES",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Things that make the stay better",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        amenityItem("Air Conditioner"),
                        amenityItem("Water"),
                        amenityItem("Hot Water Geyser"),
                        amenityItem("TV"),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "View all amenities",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // LOCATION Section
                    Column(
                      key: _locationKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LOCATION",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Where you need to go",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Hotel City Avenue, fortune vue, Maulana Azad Road, Saat Rasta, 800 meters from Mahalaxmi railway station east behind moonlight restaurant, Mumbai, Maharashtra 400011",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(height: 1, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _launchMaps("Raghurajapur, Odisha");
                          },
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.map,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                    ),
                                    child: Text(
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
                        SizedBox(height: 24),
                      ],
                    ),

                    // RATINGS Section
                    Column(
                      key: _ratingsKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RATINGS",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "What people think of it",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "3.8 Based on 220 ratings",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),
                        ratingCategory("Smooth Check-in", 4.1),
                        ratingCategory("Room Quality", 3.9),
                        ratingCategory("Hotel Surroundings", 4.0),
                        ratingCategory("Staff Behavior", 4.2),
                      ],
                    ),
                    SizedBox(height: 24),

                    // POLICIES Section
                    Column(
                      key: _policiesKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RULES & POLICIES",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "What you must know",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("- Guests must present a valid ID at check-in"),
                        Text("- Couples over 18 are welcome"),
                        Text("- Children up to age 5 stay free"),
                      ],
                    ),
                    SizedBox(height: 24),

                    // SIMILAR HOTELS Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Similar Hotels",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        similarHotelCard(
                          name: "Brill Manner Residency",
                          location: "Sector 5, Salt Lake",
                          acceptsLocalId: true,
                          payAtHotel: true,
                          prices: [1120, 1343, 1791],
                          imagePath: "assets/hotel2.jpeg",
                          rating: 4.6,
                          reviews: 6,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Fixed Select a Slot Section
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
          style: TextStyle(
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.purple, size: 16),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple,
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
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
            amenity,
            style: TextStyle(
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
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: rating / 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "$rating ($reviews)",
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
                Text(name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(location,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text("Couple Friendly",
                        style: TextStyle(fontSize: 12, color: Colors.black87)),
                    SizedBox(width: 12),
                    Icon(Icons.verified_user,
                        size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text("Accepts Local ID",
                        style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ),
                if (payAtHotel) ...[
                  SizedBox(height: 8),
                  Text(
                    "Pay at hotel available on app",
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
                SizedBox(height: 12),
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
        Text(price,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(duration, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

Widget bottomSlotSection() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey[300]!)),
      boxShadow: [
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
        // "Select a Slot" header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Select a Slot",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down, size: 20),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: _showSlotSelector,
            ),
          ],
        ),
        
        // Main content container
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // Price and duration row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${slotOptions[selectedSlotIndex]['price']} / ${slotOptions[selectedSlotIndex]['duration']}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showPriceBreakup,
                    child: Text(
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
              
              SizedBox(height: 12),
              
              // Reserve button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
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
// Function to show the slot selection modal
void _showSlotSelector() {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a Slot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(slotOptions.length, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: selectedSlotIndex,
                onChanged: (value) {
                  setState(() {
                    selectedSlotIndex = value!;
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  "₹${slotOptions[index]['price']}  ${slotOptions[index]['duration']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            SizedBox(height: 10),
          TextButton(
  onPressed: () {
    Navigator.pop(context);
    _showCancellationPolicy();
  },
  child: Text(
    "View Cancellation Policy",
    style: TextStyle(color: Colors.blue, fontSize: 16),
  ),
),

          ],
        ),
      );
    },
  );
}}