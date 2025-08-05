import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddBlogPost extends StatefulWidget {
  @override
  _AddBlogPostState createState() => _AddBlogPostState();
}

class _AddBlogPostState extends State<AddBlogPost> {
  final TextEditingController _textController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, // compress image
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_textController.text.isEmpty && _image == null) {
      Fluttertoast.showToast(msg: "Please enter text or select image");
      return;
    }

    String? base64Image;
    if (_image != null) {
      final bytes = await _image!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    await FirebaseFirestore.instance.collection('micro_blogs').add({
      'text': _textController.text.trim(),
      'image': base64Image,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Fluttertoast.showToast(msg: "Post uploaded!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Blog Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(hintText: "Share your experience..."),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 150)
                : SizedBox.shrink(),
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text("Pick Image"),
            ),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
