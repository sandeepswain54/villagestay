import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/views/vendor_screens/host_pending_approval_screen.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _serviceTypeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();
  final _govtIdController = TextEditingController();

  File? _profileImage;
  File? _govtIdImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isProfile) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(image.path);
        } else {
          _govtIdImage = File(image.path);
        }
      });
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null || _govtIdImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both profile and ID images'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Create Firebase Auth account
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String userId = credential.user!.uid;

      // 2. Upload profile and ID images to Firebase Storage (with fallback)
      String profileUrl = '';
      String idUrl = '';

      try {
        profileUrl = await _uploadImage(
          _profileImage!,
          'sellers/$userId/profile.jpg',
        );
      } catch (e) {
        debugPrint('Profile image upload failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note: Profile image upload failed, continuing...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      try {
        idUrl = await _uploadImage(
          _govtIdImage!,
          'sellers/$userId/govt_id.jpg',
        );
      } catch (e) {
        debugPrint('ID image upload failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note: ID image upload failed, continuing...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // 3. Prepare seller data
      final sellerData = {
        'userId': userId,
        'email': _emailController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'serviceType': _serviceTypeController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileImage': profileUrl,
        'govtIdImage': idUrl,
        'govtIdNumber': _govtIdController.text.trim(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // 4. Save to sellers collection with pending status
      final docRef = await FirebaseFirestore.instance
          .collection('sellers')
          .add(sellerData);

      if (!mounted) return;

      // 5. Redirect to Pending Approval Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => HostPendingApprovalScreen(
                sellerId: docRef.id,
                firstName: _firstNameController.text.trim(),
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _uploadImage(File image, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      debugPrint('Uploading image to: $path');

      final uploadTask = ref.putFile(image);
      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to $path: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Host')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(labelText: 'Service Type'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (value) => value!.contains('@') ? null : 'Invalid email',
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator:
                    (value) =>
                        value!.length >= 6 ? null : 'Minimum 6 characters',
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'About Your Service',
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _govtIdController,
                decoration: const InputDecoration(
                  labelText: 'Government ID Number',
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Profile Photo'),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                _profileImage == null
                                    ? const Icon(Icons.add_a_photo, size: 50)
                                    : Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Government ID'),
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                _govtIdImage == null
                                    ? const Icon(Icons.credit_card, size: 50)
                                    : Image.file(
                                      _govtIdImage!,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit Application'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
