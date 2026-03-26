import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/views/vendor_screens/pending_approval_screen.dart';
import 'dart:io';

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

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    setState(() {
      _currentUploadPhase = "Uploading images (0/${_images.length})";
      _uploadProgress = 0.0;
    });

    for (int i = 0; i < _images.length; i++) {
      try {
        final imageFile = _images[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = FirebaseStorage.instance.ref().child(
          'hotel_images/$fileName',
        );

        final uploadTask = ref.putFile(imageFile);
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          setState(() {
            _uploadProgress =
                (i + taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) /
                _images.length;
            _currentUploadPhase =
                "Uploading images (${i + 1}/${_images.length})";
          });
        });

        await uploadTask;
        final downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        debugPrint('Error uploading image $i: $e');
        rethrow;
      }
    }
    return imageUrls;
  }

  Future<void> _submitForm() async {
    if (_isUploading) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 3 images')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentUploadPhase = "Starting upload...";
    });

    try {
      // 1. Upload images to Firebase Storage
      setState(() => _currentUploadPhase = "Preparing image upload...");
      final imageUrls = await _uploadImages();

      // 2. Process amenities
      setState(() => _currentUploadPhase = "Processing amenities...");
      final selectedAmenities = <String>[];
      for (int i = 0; i < _amenities.length; i++) {
        if (_selectedAmenities[i]) selectedAmenities.add(_amenities[i]);
      }

      // 3. Validate and convert slots
      setState(() => _currentUploadPhase = "Processing pricing slots...");
      final validatedSlots =
          _slots.map((slot) {
            return {
              'duration': slot['duration'].toString(),
              'price': int.tryParse(slot['price']?.toString() ?? '0') ?? 0,
            };
          }).toList();

      // 4. Prepare Firestore document
      setState(() => _currentUploadPhase = "Preparing data...");
      final propertyData = {
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrls': imageUrls,
        'slots': validatedSlots,
        'amenities': selectedAmenities,
        'rating': 4.2,
        'reviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 5. Upload to Firestore with pending status
      setState(() {
        _currentUploadPhase = "Uploading to database...";
        _uploadProgress = 0.9;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final pendingData = {
        ...propertyData,
        'status': 'pending',
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('pending_properties')
          .add(pendingData);

      setState(() => _uploadProgress = 1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to Pending Approval Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => PendingApprovalScreen(
                propertyId: docRef.id,
                propertyName: _nameController.text.trim(),
              ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Upload error: $e');
      debugPrint('Stack trace: $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: ${e.toString()}')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Property'),
        actions: [
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[200],
              ),
            ),
        ],
      ),
      body:
          _isUploading
              ? _buildUploadProgress()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Section
                      const Text(
                        'Property Images (Min 3)',
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
                                    onPressed:
                                        () => setState(
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
                          labelText: 'Property Name',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
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
                        children:
                            _amenities.asMap().entries.map((entry) {
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
                                  color:
                                      _selectedAmenities[idx]
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
                          icon:
                              _isUploading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.cloud_upload),
                          label: Text(
                            _isUploading ? 'Uploading...' : 'SUBMIT PROPERTY',
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
