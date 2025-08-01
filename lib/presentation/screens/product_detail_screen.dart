import 'package:flutter/material.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/screens/full_screen_image_screen.dart';
import 'package:spinza/presentation/screens/order_screen.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(product.name, style: TextStyle(color: Colors.white,fontSize: 22,
          fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: Stack(
        children: [
          // --- Layer 1: The Watermark ---
          Center(
            child: Opacity(
              opacity: 0.08, // Keep your desired opacity
              child: ColorFiltered( // <--- WRAP Image.asset WITH ColorFiltered
                colorFilter: ColorFilter.mode(
                  Color(0xFF0072BC), // <--- YOUR DESIRED BLUE COLOR (adjust opacity if needed)
                  BlendMode.srcIn,     // This blend mode will tint the non-transparent parts of your image
                ),
                child: Image.asset(
                  'assets/images/watermark.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  // You might not need to set the color property on Image.asset directly
                  // if ColorFiltered is handling it, unless your image has multiple colors
                  // and you only want to affect specific parts (which is more complex).
                ),
              ),
            ),
          ),
          // --- Layer 2: The Product Details ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => FullScreenImageScreen(imageAssetPath: product.imageUrl),
                          ));
                        },
                        child: Hero(
                          tag: product.imageUrl,
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white, // Solid white background for the image
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: Colors.grey.shade200)
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.asset(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey[600]);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(product.name, style: textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      Text(
                        'PKR ${product.price.toStringAsFixed(2)}',
                        style: textTheme.bodyLarge?.copyWith(fontSize: 28, color: Colors.blue.shade700),
                      ),
                      const SizedBox(height: 16),
                      Text(product.description, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: AppStrings.orderNow,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OrderScreen(product: product),
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}