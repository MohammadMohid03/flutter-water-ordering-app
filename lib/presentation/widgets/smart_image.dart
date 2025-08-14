import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      // It's a network image from Firebase Storage
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Add a loading indicator for network images
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image_outlined)),
      );
    } else {
      // It's a local asset image
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }
  }
}