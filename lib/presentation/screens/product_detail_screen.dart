import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/bloc/cart/cart_bloc.dart';
import 'package:spinza/presentation/bloc/cart/cart_event.dart';
import 'package:spinza/presentation/screens/full_screen_image_screen.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';
import '../widgets/smart_image.dart';
import 'dart:math' as math;

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _buttonScaleAnimation = Tween<double>(begin: 1, end: 0.95)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    context.read<CartBloc>().add(CartItemAdded(widget.product));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.water_drop, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('${widget.product.name} added to cart! 💧'),
            ],
          ),
          backgroundColor: Color(0xFF1E3C72),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF4FC3F7),
              Color(0xFF29B6F6),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Product Image Section
            Positioned(      // <--- Positioned is now the direct child of the Stack
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.55,
              child: FadeTransition( // <--- FadeTransition is now inside
                opacity: _fadeAnimation,
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FullScreenImageScreen(
                              imageAssetPath: widget.product.imageUrl),
                        ));
                      },
                      child: Hero(
                        tag: 'product_image_${widget.product.id}',
                        child: Stack(
                          children: [
                            // Product image
                            SmartImage(
                              imageUrl: widget.product.imageUrl,
                              width: double.infinity,
                            ),

                            // Glass overlay effect
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Custom Back Button
            Positioned(      // <--- Positioned is now the direct child of the Stack
              top: 20,
              left: 20,
              child: SafeArea( // <--- SafeArea is now inside, padding the button correctly
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),

            // Draggable Details Sheet with Glass-morphism
            SlideTransition(
              position: _slideAnimation,
              child: DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.5,
                maxChildSize: 0.85,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Content
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24.0),
                            children: [
                              // Product Title with animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 600),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: Text(
                                        widget.product.name,
                                        style: textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3C72),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 8),

                              // Premium badge
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF4FC3F7),
                                            Color(0xFF29B6F6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF4FC3F7).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.water_drop, color: Colors.white, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            'Premium Quality',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 20),

                              // Product Description
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 1000),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4FC3F7).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Color(0xFF4FC3F7).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          widget.product.description,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: Colors.grey.shade700,
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 24),

                              // Features section
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 1200),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Features',
                                            style: textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E3C72),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          _buildFeatureItem(Icons.water_drop, '100% Pure Water'),
                                          _buildFeatureItem(Icons.verified, 'Quality Certified'),
                                          _buildFeatureItem(Icons.local_shipping, 'Fast Delivery'),
                                          _buildFeatureItem(Icons.eco, 'Eco-Friendly'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 24),

                              // Price Section
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 1400),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1E3C72).withOpacity(0.1),
                                              Color(0xFF4FC3F7).withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color(0xFF4FC3F7).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Price',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  'PKR ${widget.product.price.toStringAsFixed(2)}',
                                                  style: textTheme.headlineSmall?.copyWith(
                                                    color: Color(0xFF1E3C72),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF4FC3F7).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.attach_money,
                                                color: Color(0xFF1E3C72),
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 120), // Space for bottom button
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Add to Cart Button
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        child: ScaleTransition(
          scale: _buttonScaleAnimation,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF4FC3F7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4FC3F7).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _handleAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.addToCart.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4FC3F7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF1E3C72),
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}