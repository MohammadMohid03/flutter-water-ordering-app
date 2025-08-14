import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/cart/cart_bloc.dart';
import 'package:spinza/presentation/bloc/cart/cart_event.dart';
import 'package:spinza/presentation/bloc/cart/cart_state.dart';
import 'package:spinza/presentation/screens/checkout_screen.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';
import '../widgets/smart_image.dart';
import 'dart:math' as math;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Animated wave background
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Floating bubbles
            ...List.generate(8, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 30 + (index * 50) +
                          math.sin(_waveAnimation.value + index) * 25,
                      top: 80 + (index * 80) +
                          math.cos(_waveAnimation.value + index) * 30,
                      child: Container(
                        width: 15 + (index * 3),
                        height: 15 + (index * 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Glass-morphism AppBar with checkout button
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [

                          // Title section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'Review & Checkout',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Checkout button - moved to top navigation
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, state) {
                              if (state.items.isNotEmpty) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const CheckoutScreen(),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.shopping_cart_checkout,
                                        color: Colors.white, size: 18),
                                    label: Text(
                                      'Checkout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Cart content
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BlocBuilder<CartBloc, CartState>(
                            builder: (context, state) {
                              if (state.items.isEmpty) {
                                return _buildEmptyCartState();
                              }

                              return CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  // Cart summary header
                                  SliverToBoxAdapter(
                                    child: Container(
                                      margin: EdgeInsets.all(20),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
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
                                                '${state.items.length} Items',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Ready for Checkout',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'PKR ${state.totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Cart items list
                                  SliverPadding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                          final item = state.items[index];
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0, end: 1),
                                            duration: Duration(milliseconds: 600 + (index * 100)),
                                            curve: Curves.easeOutBack,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: Container(
                                                  margin: EdgeInsets.only(bottom: 16),
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(0.2),
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
                                                  child: Row(
                                                    children: [
                                                      // Product image
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: SmartImage(
                                                            imageUrl: item.product.imageUrl,
                                                            width: 60,
                                                            height: 60,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),

                                                      SizedBox(width: 16),

                                                      // Product details
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              item.product.name,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              'PKR ${item.product.price.toStringAsFixed(2)}',
                                                              style: TextStyle(
                                                                color: Colors.white.withOpacity(0.8),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      // Quantity controls
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.white.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: IconButton(
                                                                icon: Icon(Icons.remove,
                                                                    color: Colors.white,
                                                                    size: 18),
                                                                onPressed: () => context
                                                                    .read<CartBloc>()
                                                                    .add(CartItemQuantityDecreased(item)),
                                                                constraints: BoxConstraints(
                                                                  minWidth: 32,
                                                                  minHeight: 32,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                                              child: Text(
                                                                item.quantity.toString(),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.white.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: IconButton(
                                                                icon: Icon(Icons.add,
                                                                    color: Colors.white,
                                                                    size: 18),
                                                                onPressed: () => context
                                                                    .read<CartBloc>()
                                                                    .add(CartItemQuantityIncreased(item)),
                                                                constraints: BoxConstraints(
                                                                  minWidth: 32,
                                                                  minHeight: 32,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        childCount: state.items.length,
                                      ),
                                    ),
                                  ),

                                  // Bottom spacing
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 100),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some water bottles to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < 3; i++) {
      path.reset();

      final waveHeight = 40.0 + (i * 15);
      final frequency = 0.015 + (i * 0.008);
      final phase = animationValue + (i * math.pi / 4);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height - 150 - (i * 80) +
            math.sin((x * frequency) + phase) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}