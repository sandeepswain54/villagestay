// post_card.dart
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:service_app/New_Upload/extensions.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageBase64;
  final String type;
  final double price;

  const PostCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageBase64,
    required this.type,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display image from base64 string
          imageBase64.isNotEmpty
              ? Image.memory(
                  base64Decode(imageBase64),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: 200,
                  child: const Icon(Icons.image, size: 50),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    type.capitalize(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}