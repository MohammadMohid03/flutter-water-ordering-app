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
          child: Image.asset(imageAssetPath),
        ),
      ),
    );
  }
}