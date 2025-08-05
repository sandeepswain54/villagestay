import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/New_Upload/extensions.dart';
import 'dart:convert';
import 'package:service_app/New_Upload/firebase_service.dart' show FirebaseService;
import 'package:service_app/New_Upload/post_card.dart' show PostCard;

class HostNavigation extends StatelessWidget {
  const HostNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const HostHomeScreen(); // Default to showing the home screen
  }
}

class HostHomeScreen extends StatelessWidget {
  const HostHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HostUploadScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HostProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading your posts'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final posts = snapshot.data!.docs;
          final currentUser = FirebaseAuth.instance.currentUser?.uid;
          
          // Filter posts by current host
          final hostPosts = posts.where((post) => post['hostId'] == currentUser).toList();
          
          return ListView.builder(
            itemCount: hostPosts.length,
            itemBuilder: (context, index) {
              final post = hostPosts[index];
              return PostCard(
                title: post['title'],
                description: post['description'],
                imageBase64: post['image'],
                type: post['type'],
                price: post['price'],
              );
            },
          );
        },
      ),
    );
  }
}

class HostUploadScreen extends StatefulWidget {
  const HostUploadScreen({super.key});

  @override
  State<HostUploadScreen> createState() => _HostUploadScreenState();
}

class _HostUploadScreenState extends State<HostUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedType;
  String? _imageBase64;
  bool _isUploading = false;

  final List<String> _types = ['hotel', 'cab', 'tour', 'restaurant', 'other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await FirebaseService().uploadPost(
        title: _titleController.text,
        description: _descriptionController.text,
        imageBase64: _imageBase64!,
        type: _selectedType!,
        price: double.parse(_priceController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully')),
      );

      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _imageBase64 = null;
        _selectedType = null;
      });

      // Return to home screen after successful upload
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading post: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.capitalize()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _imageBase64 == null
                  ? ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Select Image'),
                    )
                  : Image.memory(
                      base64Decode(_imageBase64!),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HostProfileScreen extends StatelessWidget {
  const HostProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(child: Text('Host Profile Screen')),
    );
  }
}