import 'package:flutter/material.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/screens/product_detail_screen.dart';
import 'package:spinza/presentation/widgets/smart_image.dart';

class GridProductCard extends StatelessWidget {
  final Product product;

  const GridProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      // --- THIS IS THE CHANGE ---
      // We wrap the Card in a Container to apply a gradient border,
      // and make the Card itself transparent.
      child: Card(
        elevation: 0, // Remove shadow for a flatter look
        color: Colors.transparent, // Make the card background transparent
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Add a subtle border to define the card's edges
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SmartImage( // <-- Use the new widget
                imageUrl: product.imageUrl,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PKR ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}