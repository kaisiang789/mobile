import 'package:flutter/material.dart';
import 'dart:typed_data';

class PosterScreen extends StatelessWidget {
  const PosterScreen({super.key, required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.grey,
        title: Text('Event Poster'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.memory(
            image,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}