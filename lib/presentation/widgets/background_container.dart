import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final String? imagePath;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final String finalImagePath = imagePath ?? 'assets/images/main.png';

    return Container(
      child: Stack(
        children: [
          // Layer 1: The background image
          Image.asset(
            finalImagePath,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),

          // Layer 2: A semi-transparent overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // --- THIS IS THE NEW PART ---
          // Layer 3 (Optional): A central watermark icon
          Center(
            child: Opacity(
              opacity: 0.1, // Makes the icon faint like a watermark
              child: Image.asset(
                'assets/images/watermark.png',
                width: MediaQuery.of(context).size.width * 0.6, // 60% of screen width
              ),
            ),
          ),
          // --- END OF NEW PART ---

          // Layer 4: The actual screen content
          child,
        ],
      ),
    );
  }
}