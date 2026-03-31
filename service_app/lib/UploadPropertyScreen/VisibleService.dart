import 'package:flutter/material.dart';
import 'dart:io';
import 'package:service_app/model/FormDataModel.dart';
import 'package:service_app/model/BookingModel.dart';
import 'package:service_app/config/BookingStorage.dart';
import 'package:service_app/UploadPropertyScreen/OrderPage.dart';

/// ✅ VisibleService Screen - Displays a single service with full details and booking button
class VisibleService extends StatefulWidget {
  final FormData serviceData;

  const VisibleService({
    Key? key,
    required this.serviceData,
  }) : super(key: key);

  @override
  State<VisibleService> createState() => _VisibleServiceState();
}

class _VisibleServiceState extends State<VisibleService> {
  // Form fields with default values for booking
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Validate booking form
  bool _validateForm() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a slot')),
      );
      return false;
    }
    return true;
  }

  /// Proceed to booking and payment
  void _proceedToBooking() {
    if (!_validateForm()) return;

    // Find the selected slot details
    final selectedSlotData = widget.serviceData.slots.firstWhere(
      (slot) => slot['duration'] == _selectedSlot,
      orElse: () => {'price': 0},
    );

    // Create booking record
    final booking = BookingRecord(
      id: 'BOOK_${DateTime.now().millisecondsSinceEpoch}',
      userName: _nameController.text,
      userEmail: _emailController.text,
      userPhone: _phoneController.text,
      serviceBooked: widget.serviceData.propertyName,
      selectedSlot: _selectedSlot ?? '',
      slotPrice: selectedSlotData['price'] ?? 0,
      bookingDateTime: DateTime.now(),
      paymentStatus: 'pending',
      amountPaid: 0,
      transactionId: '',
      formData: widget.serviceData.toMap(),
    );

    // Store booking in BookingStorage
    BookingStorage().addBooking(booking);

    // Navigate to OrderPage with the booking
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderPage(),
      ),
    ).then((_) {
      // Clear form after returning from payment
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _selectedSlot = null;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceData.propertyName),
        backgroundColor: Colors.purple[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Service Images
            if (widget.serviceData.imageUrls.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: widget.serviceData.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      File(widget.serviceData.imageUrls[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    );
                  },
                ),
              ),

            // ✅ Service Info Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name
                      Text(
                        'Service Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location
                      _buildInfoRow('📍 Location', widget.serviceData.location),
                      const SizedBox(height: 8),

                      // Description
                      _buildInfoRow('📝 Description', widget.serviceData.description),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Available Slots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Slots',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.serviceData.slots.map((slot) {
                    final duration = slot['duration'] ?? 'N/A';
                    final price = slot['price'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RadioListTile<String>(
                        title: Text('$duration - ₹$price'),
                        value: duration.toString(),
                        groupValue: _selectedSlot,
                        onChanged: (value) {
                          setState(() {
                            _selectedSlot = value;
                          });
                        },
                        activeColor: Colors.purple[700],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // ✅ Amenities
            if (widget.serviceData.selectedAmenities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.serviceData.selectedAmenities
                          .map((amenity) => Chip(
                        label: Text(amenity),
                        backgroundColor: Colors.purple[100],
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),

            // ✅ Booking Form Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Phone Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Book Service Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _proceedToBooking,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Book Service'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Helper widget to display info in a row
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
