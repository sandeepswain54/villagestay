import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:service_app/model/FormDataModel.dart';
import 'package:service_app/model/BookingModel.dart';
import 'package:service_app/config/BookingStorage.dart';
// ✅ Added: Import OrderPage for navigation after booking
import 'package:service_app/UploadPropertyScreen/OrderPage.dart';

// ✅ Modified: Changed from StatelessWidget to StatefulWidget to handle form data
class HotelListScreen2 extends StatefulWidget {
  // ✅ Added: formData parameter to accept data from form
  final FormData? formData;
  // ✅ Added: submittedServices parameter to accept list of services
  final List<FormData>? submittedServices;

  const HotelListScreen2({
    super.key,
    this.formData,
    this.submittedServices,
  });

  @override
  State<HotelListScreen2> createState() => _HotelListScreen2State();
}

class _HotelListScreen2State extends State<HotelListScreen2> {
  // ✅ Added: State to manage user input for booking
  String? _selectedSlot;
  int? _selectedSlotPrice;
  bool _isProcessingBooking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: 
          // ✅ Modified: Show submitted services if available, otherwise form data
          widget.submittedServices != null && widget.submittedServices!.isNotEmpty
              ? _buildSubmittedServicesList(context, widget.submittedServices!)
              : widget.formData != null
                  ? _buildFormDataDisplay(context)
                  : _buildHotelListFromFirebase(context),
    );
  }

  // ✅ Added: Display all submitted services in a list
  Widget _buildSubmittedServicesList(BuildContext context, List<FormData> services) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Added: Summary header
          Card(
            elevation: 2,
            color: Colors.purple.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Services',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        services.length.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.list_alt,
                    size: 48,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // ✅ Added: List all services
          ...services.asMap().entries.map((entry) {
            int index = entry.key + 1;
            FormData service = entry.value;
            return _buildSubmittedServiceCard(context, service, index);
          }).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ Added: Build card for each submitted service
  Widget _buildSubmittedServiceCard(BuildContext context, FormData service, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          if (service.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.file(
                File(service.imageUrls[0]),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 60, color: Colors.grey),
            ),

          // Service Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index badge and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        service.propertyName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.purple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing
                const Text(
                  'Available Slots:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: service.slots.map((slot) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${slot['duration']} - ₹${slot['price']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Amenities
                if (service.selectedAmenities.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Amenities:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: service.selectedAmenities.map((amenity) {
                      return Chip(
                        label: Text(
                          amenity,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.purple.withOpacity(0.2),
                        labelStyle: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),

                // Book Service Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Book Service'),
                    onPressed: () => _showBookingSheet(context, service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  // ✅ Added: Show booking sheet to select slot and book
  void _showBookingSheet(BuildContext context, FormData service) {
    String? selectedSlot;
    int? selectedPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Service Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...service.slots.map((slot) {
                int price = slot['price'] is int
                    ? slot['price']
                    : int.tryParse(slot['price'].toString()) ?? 0;
                String duration = slot['duration']?.toString() ?? 'Unknown';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selectedSlot == duration
                            ? Colors.purple
                            : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    selected: selectedSlot == duration,
                    selectedTileColor: Colors.purple.withOpacity(0.1),
                    title: Text(duration),
                    trailing: Text(
                      '₹$price',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      setSheetState(() {
                        selectedSlot = duration;
                        selectedPrice = price;
                      });
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Proceed to Booking'),
                  onPressed: selectedSlot == null
                      ? null
                      : () {
                        Navigator.pop(context);
                        _proceedToBooking(context, service, selectedSlot!, selectedPrice!);
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Added: Proceed to booking
  void _proceedToBooking(
    BuildContext context,
    FormData service,
    String selectedSlot,
    int slotPrice,
  ) {
    final bookingId = '${DateTime.now().millisecondsSinceEpoch}';
    final booking = BookingRecord(
      id: bookingId,
      userName: 'User ${bookingId.substring(0, 6)}', // Simple user ID
      userEmail: 'user@example.com',
      userPhone: '9876543210',
      serviceBooked: service.propertyName,
      selectedSlot: selectedSlot,
      slotPrice: slotPrice,
      bookingDateTime: DateTime.now(),
      paymentStatus: 'pending',
      amountPaid: slotPrice.toDouble(),
      transactionId: '',
      formData: service.toMap(),
    );

    BookingStorage().addBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Booking created! Proceeding to payment...'),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderPage(newBooking: booking),
        ),
      );
    });
  }

  // ✅ Added: New method to display form data in clean, attractive UI
  Widget _buildFormDataDisplay(BuildContext context) {
    final formData = widget.formData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📋 Section 1: User Info & Service Header
          // ✅ Added: Service card with image
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                if (formData.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: formData.imageUrls[0],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 60, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
                
                // Service Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        formData.propertyName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formData.location,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        formData.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 💰 Section 2: Pricing & Slot Selection
          // ✅ Added: Pricing options with selection
          _buildSectionHeader('Pricing Options', Icons.local_offer),
          const SizedBox(height: 12),
          
          // ✅ Added: Slot selection with tap to select
          Column(
            children: formData.slots.map((slot) {
              int slotPrice = slot['price'] is int ? slot['price'] : int.tryParse(slot['price'].toString()) ?? 0;
              String duration = slot['duration']?.toString() ?? 'Unknown';
              String slotId = duration; // Use duration as unique ID
              bool isSelected = _selectedSlot == slotId;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSlot = slotId;
                    _selectedSlotPrice = slotPrice;
                  });
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected
                      ? Colors.purple.withOpacity(0.15)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.purple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: Colors.purple,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                duration,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹$slotPrice',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.purple),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 🏥 Section 3: Amenities
          // ✅ Added: Display amenities with icons
          if (formData.selectedAmenities.isNotEmpty) ...[
            _buildSectionHeader('Amenities', Icons.verified),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: formData.selectedAmenities.map((amenity) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAmenityIcon(amenity),
                          color: Colors.purple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amenity,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // 🖼️ Section 4: Gallery (if multiple images)
          // ✅ Added: Additional images display
          if (formData.imageUrls.length > 1) ...[
            _buildSectionHeader('Gallery', Icons.photo_library),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: formData.imageUrls.length - 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: formData.imageUrls[index + 1],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ✅ Added: Book Service Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isProcessingBooking
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.check_circle),
              label: Text(
                _isProcessingBooking
                    ? 'Processing Booking...'
                    : 'Book Service',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _selectedSlot == null
                  ? null
                  : () => _handleBooking(context, formData),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ✅ Added: Handle booking process
  Future<void> _handleBooking(BuildContext context, FormData formData) async {
    if (_selectedSlot == null) {
      _showErrorSnackBar('Please select a service duration');
      return;
    }

    setState(() => _isProcessingBooking = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // ✅ Added: Create booking record
      final bookingId = '${DateTime.now().millisecondsSinceEpoch}';
      final booking = BookingRecord(
        id: bookingId,
        userName: currentUser?.displayName ?? 'User',
        userEmail: currentUser?.email ?? 'unknown@email.com',
        userPhone: 'Not provided', // Will be collected later or from user profile
        serviceBooked: formData.propertyName,
        selectedSlot: _selectedSlot!,
        slotPrice: _selectedSlotPrice ?? 0,
        bookingDateTime: DateTime.now(),
        paymentStatus: 'pending',
        amountPaid: (_selectedSlotPrice ?? 0).toDouble(),
        transactionId: '',
        formData: formData.toMap(),
      );

      // ✅ Added: Store booking in global storage
      BookingStorage().addBooking(booking);

      if (!mounted) return;

      // ✅ Added: Show success message
      _showSuccessSnackBar('✅ Booking created! Proceeding to payment...');

      // ✅ Added: Navigate to OrderPage
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderPage(newBooking: booking),
          ),
        );
      }
    } catch (e) {
      debugPrint('Booking error: $e');
      _showErrorSnackBar('Booking failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessingBooking = false);
      }
    }
  }

  // ✅ Added: Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ✅ Added: Map amenities to icons
  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'ac':
        return Icons.air;
      case 'wifi':
        return Icons.wifi;
      case 'tv':
        return Icons.tv;
      case 'parking':
        return Icons.directions_car;
      case 'pool':
        return Icons.pool;
      default:
        return Icons.check_circle;
    }
  }

  // ✅ Added: Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ Added: Helper method to show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ Kept: Existing Firebase hotel list display (for backward compatibility)
  Widget _buildHotelListFromFirebase(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hotels')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hotels found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final hotel = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: hotel['imageUrls'] != null && hotel['imageUrls'].isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: hotel['imageUrls'][0],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    )
                    : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.hotel, size: 40),
                    ),
                title: Text(
                  hotel['name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotel['location'] ?? 'No Location'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel['rating']?.toStringAsFixed(1) ?? '0.0'} (${hotel['reviews'] ?? 0})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelDetailScreen(hotelId: doc.id),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class HotelDetailScreen extends StatelessWidget {
  final String hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Hotel Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotels')
            .doc(hotelId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Hotel not found'));
          }

          final hotel = snapshot.data!.data() as Map<String, dynamic>;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                if (hotel['imageUrls'] != null && hotel['imageUrls'].isNotEmpty)
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: hotel['imageUrls'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: hotel['imageUrls'][index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.hotel, size: 60, color: Colors.grey),
                    ),
                  ),

                // Hotel Info
                const SizedBox(height: 16),
                Text(
                  hotel['name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      hotel['location'] ?? 'No Location',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  hotel['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16),
                ),

                // Rating
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${hotel['rating']?.toStringAsFixed(1) ?? '0.0'} (${hotel['reviews'] ?? 0} reviews)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                // Pricing
                const SizedBox(height: 24),
                const Text(
                  'Pricing Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(hotel['slots'] as List?)?.map((slot) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(slot['duration']?.toString() ?? ''),
                    trailing: Text(
                      '₹${slot['price']?.toString() ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )) ?? [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No pricing information available'),
                  ),
                ],

                // Amenities
                const SizedBox(height: 24),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (hotel['amenities'] as List?)?.map((amenity) => Chip(
                    label: Text(amenity?.toString() ?? ''),
                    backgroundColor: Colors.purple[100],
                  )).toList() ?? [
                    const Chip(label: Text('No amenities listed')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}