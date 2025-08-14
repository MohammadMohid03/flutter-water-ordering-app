import 'package:flutter/material.dart';

class ProductCardPlaceholder extends StatelessWidget {
  const ProductCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Placeholder for the image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white, // Color must be white for shimmer to work
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for the title
                  Container(
                    width: double.infinity,
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Placeholder for the price
                  Container(
                    width: 100.0,
                    height: 18.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.transparent, size: 28),
          ],
        ),
      ),
    );
  }
}