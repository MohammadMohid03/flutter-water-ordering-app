import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imageAssetPath;

  const FullScreenImageScreen({super.key, required this.imageAssetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Use a white icon for better contrast on the black background
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        // The InteractiveViewer is the widget that enables panning and zooming
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          // --- THIS IS THE CORRECTED PART ---
          child: imageAssetPath.startsWith('http')
          // If it's a URL from Firebase, use Image.network
              ? Image.network(
            imageAssetPath,
            // Add a loading builder for a better user experience
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            // Add an error builder in case the network image fails
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 48)),
          )
          // Otherwise, assume it's a local asset and use Image.asset
              : Image.asset(
            imageAssetPath,
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 48)),
          ),
        ),
      ),
    );
  }
}