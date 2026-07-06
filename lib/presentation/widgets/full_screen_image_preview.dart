import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:velocity_x/velocity_x.dart';

class FullScreenImagePreview extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImagePreview({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: _buildImage(imageUrls[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageVal) {
    if (imageVal.isEmpty) return const Icon(Icons.broken_image, color: Colors.white, size: 50);

    if (imageVal.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageVal,
        fit: BoxFit.contain,
        placeholder: (context, url) => const CircularProgressIndicator().centered(),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageVal),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
      );
    } catch (e) {
      return const Icon(Icons.error, color: Colors.white);
    }
  }
}
