import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/model/FormDataModel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:service_app/UploadPropertyScreen/hotellistscreen2.dart';
import 'package:service_app/UploadPropertyScreen/VisibleService.dart';
import 'package:service_app/config/BookingStorage.dart';

class UploadPropertyScreen extends StatefulWidget {
  const UploadPropertyScreen({super.key});

  @override
  State<UploadPropertyScreen> createState() => _UploadPropertyScreenState();
}

class _UploadPropertyScreenState extends State<UploadPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];
  final List<Map<String, dynamic>> _slots = [
    {"duration": "3 Hrs", "price": ""},
    {"duration": "6 Hrs", "price": ""},
    {"duration": "12 Hrs", "price": ""},
  ];
  final List<String> _amenities = ["AC", "WiFi", "TV", "Parking", "Pool"];
  final List<bool> _selectedAmenities = [false, false, false, false, false];

  // ✅ Added: List to store submitted services locally
  final List<FormData> _submittedServices = [];

  // State variables
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _currentUploadPhase;

  Future<void> _pickImages() async {
    if (_isUploading) return;

    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // ✅ Modified: Save images to local storage instead of Firebase
  Future<List<String>> _saveImagesToLocal() async {
    List<String> localImagePaths = [];
    setState(() {
      _currentUploadPhase = "Saving images locally (0/${_images.length})";
      _uploadProgress = 0.0;
    });

    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/service_app_images');
      
      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      for (int i = 0; i < _images.length; i++) {
        try {
          final imageFile = _images[i];
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final localPath = '${imagesDir.path}/$fileName';
          
          // Copy image to local directory
          await imageFile.copy(localPath);
          localImagePaths.add(localPath);

          setState(() {
            _uploadProgress = (i + 1) / _images.length;
            _currentUploadPhase =
                "Saving images locally (${i + 1}/${_images.length})";
          });

          debugPrint('✅ Image saved locally: $localPath');
        } catch (e) {
          debugPrint('Error saving image $i: $e');
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Error in _saveImagesToLocal: $e');
      rethrow;
    }
    return localImagePaths;
  }

  // ✅ Modified: Save form data locally and clear form
  Future<void> _submitForm() async {
    if (_isUploading) return;
    
    // ✅ Added: Validate all required fields before submission
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Added: Validate that at least one slot has a price
    bool hasValidSlots = _slots.any((slot) {
      int price = int.tryParse(slot['price']?.toString() ?? '0') ?? 0;
      return price > 0;
    });

    if (!hasValidSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please enter at least one valid pricing slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentUploadPhase = "Starting upload...";
    });

    try {
      // ✅ Modified: Save images to local storage instead of Firebase
      List<String> imageUrls = [];
      setState(() => _currentUploadPhase = "Saving images locally...");

      if (_images.isNotEmpty) {
        try {
          imageUrls = await _saveImagesToLocal();
        } catch (imageError) {
          debugPrint('Image save failed: $imageError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚠️ Images save failed. Continuing without images...',
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
          imageUrls = [];
        }
      }

      // Process amenities
      setState(() => _currentUploadPhase = "Processing amenities...");
      final selectedAmenities = <String>[];
      for (int i = 0; i < _amenities.length; i++) {
        if (_selectedAmenities[i]) selectedAmenities.add(_amenities[i]);
      }

      // Validate and convert slots
      setState(() => _currentUploadPhase = "Processing pricing slots...");
      final validatedSlots =
          _slots.map((slot) {
            return {
              'duration': slot['duration'].toString(),
              'price': int.tryParse(slot['price']?.toString() ?? '0') ?? 0,
            };
          }).toList();

      // ✅ Added: Create FormData object with all form data
      setState(() => _currentUploadPhase = "Preparing form data...");
      final formData = FormData(
        propertyName: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        slots: validatedSlots,
        selectedAmenities: selectedAmenities,
      );

      setState(() {
        _uploadProgress = 0.9;
        _currentUploadPhase = "Processing...";
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // ✅ Modified: Store the service locally
      setState(() {
        _submittedServices.add(formData);
        _uploadProgress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // ✅ Modified: Clear form fields and navigate to VisibleService
      _nameController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _images.clear();
      _slots.forEach((slot) => slot['price'] = '');
      _selectedAmenities.fillRange(0, _selectedAmenities.length, false);

      // Show success and navigate to VisibleService
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Service added! Check details on next screen.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to VisibleService to display the submitted service
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisibleService(serviceData: formData),
        ),
      ).then((_) {
        // Refresh page when returning
        if (mounted) setState(() {});
      });
    } catch (e, stack) {
      debugPrint('Upload error: $e');
      debugPrint('Stack trace: $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload failed: ${e.toString()}'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _currentUploadPhase = null;
        });
      }
    }
  }

  /// ✅ Build notifications section showing recent bookings
  Widget _buildBookingsNotificationSection() {
    final allBookings = BookingStorage().getAllBookings();
    
    if (allBookings.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the last 5 bookings
    final recentBookings = allBookings.length > 5
        ? allBookings.sublist(allBookings.length - 5)
        : allBookings;

    return Card(
      elevation: 3,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Recent Bookings (${allBookings.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentBookings.asMap().entries.map((entry) {
              final booking = entry.value;
              final bookingTime = booking.bookingDateTime;
              final timeString =
                  '${bookingTime.day}/${bookingTime.month}/${bookingTime.year} ${bookingTime.hour}:${bookingTime.minute.toString().padLeft(2, '0')}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            booking.userName[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              booking.serviceBooked,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Service'),
        actions: [
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[200],
              ),
            ),
          // ✅ Added: View Services button
          if (_submittedServices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Badge(
                  label: Text(_submittedServices.length.toString()),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HotelListScreen2(
                                submittedServices: _submittedServices,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list, color: Colors.white),
                    label: const Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isUploading
          ? _buildUploadProgress()
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Added: Notifications section showing recent bookings
                  _buildBookingsNotificationSection(),
                  if (BookingStorage().getAllBookings().isNotEmpty)
                    const SizedBox(height: 20),

                  // Image Upload Section
                  const Text(
                    'Service Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _images.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _images.length) {
                        return Stack(
                          children: [
                            Image.file(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => setState(
                                  () => _images.removeAt(index),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, size: 40),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // Property Details
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),

                  // Pricing Slots
                  const SizedBox(height: 20),
                  const Text(
                    'Pricing Slots',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ..._slots.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            entry.value['duration'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price (₹)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged:
                                  (value) => _slots[idx]['price'] = value,
                              validator: (value) {
                                if (value!.isEmpty) return 'Required';
                                if (int.tryParse(value) == null) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Amenities
                  const SizedBox(height: 20),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amenities.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return FilterChip(
                        label: Text(entry.value),
                        selected: _selectedAmenities[idx],
                        onSelected: (bool value) {
                          setState(
                            () => _selectedAmenities[idx] = value,
                          );
                        },
                        selectedColor: Colors.purple.withOpacity(0.2),
                        checkmarkColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: _selectedAmenities[idx]
                              ? Colors.purple
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  // Submit Button
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isUploading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.add),
                      label: Text(
                        _isUploading
                            ? 'Uploading...'
                            : 'ADD SERVICE',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
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
            ),
          ),
    );
  }

  Widget _buildUploadProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[200],
            strokeWidth: 8,
          ),
          const SizedBox(height: 20),
          Text(
            _currentUploadPhase ?? 'Uploading...',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_uploadProgress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
