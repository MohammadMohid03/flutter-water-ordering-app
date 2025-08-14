import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:spinza/data/models/cart_item_model.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';
import 'dart:math' as math;

class OrderConfirmationScreen extends StatefulWidget {
  final List<CartItem> orderedItems;
  final double totalPrice;

  const OrderConfirmationScreen({
    super.key,
    required this.orderedItems,
    required this.totalPrice,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _cardController;
  late Animation<Offset> _cardAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _waveController = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _bounceController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _cardController = AnimationController(duration: const Duration(milliseconds: 1800), vsync: this);

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_waveController);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    _bounceAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut)
    );
    _cardAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    // Start animations with delays
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _bounceController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String itemsSummary = widget.orderedItems
        .map((item) => '${item.quantity} x ${item.product.name}')
        .join('\n');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave background
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) => CustomPaint(
                painter: WavePainter(_waveAnimation.value),
                size: Size.infinite,
              ),
            ),
            // Floating bubbles
            ...List.generate(10, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 10 + (index * 40) +
                          math.sin(_waveAnimation.value + index * 2.2) * 35,
                      top: 50 + (index * 80) -
                          math.cos(_waveAnimation.value + index * 1.5) * 45,
                      child: Container(
                        width: 12 + (index * 4),
                        height: 12 + (index * 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.02 + (index * 0.006)),
                        ),
                      ),
                    );
                  },
                ),
            ),
            // Success particles effect
            ...List.generate(15, (index) =>
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    final progress = _bounceController.value;
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 +
                          math.sin(index * 0.4) * (progress * 100),
                      top: 200 + math.cos(index * 0.4) * (progress * 80),
                      child: Opacity(
                        opacity: (1 - progress) * 0.8,
                        child: Container(
                          width: 4 + (index % 3) * 2,
                          height: 4 + (index % 3) * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildSuccessAnimation(),
                      const SizedBox(height: 30),
                      _buildSuccessMessage(),
                      const SizedBox(height: 50),
                      _buildOrderDetails(itemsSummary),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildSuccessAnimation() {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Lottie.asset(
          'assets/animations/Success.json',
          height: 120,
          repeat: false,
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Text(
          'Order Placed Successfully!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Thank you for your order! It will be delivered on the selected day.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOrderDetails(String itemsSummary) {
    return SlideTransition(
      position: _cardAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Date and Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailColumn(
                  'Date',
                  DateFormat('MMMM d, yyyy').format(DateTime.now()),
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                _buildDetailColumn(
                  'Total',
                  'PKR ${widget.totalPrice.toStringAsFixed(2)}',
                  crossAxisAlignment: CrossAxisAlignment.end,
                  isHighlighted: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Items Section
            _buildDetailColumn(
              'Items Ordered',
              itemsSummary,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(
      String title,
      String value, {
        required CrossAxisAlignment crossAxisAlignment,
        bool isHighlighted = false,
      }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: isHighlighted ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
          decoration: isHighlighted ? BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ) : null,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlighted ? 18 : 16,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: crossAxisAlignment == CrossAxisAlignment.end ? TextAlign.right : TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF1E3C72).withOpacity(0.3),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3C72),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
            ),
            child: const Text(
              'BACK TO HOME',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the animated wave background
class WavePainter extends CustomPainter {
  final double animationValue;
  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < 3; i++) {
      path.reset();
      final waveHeight = 60.0 + (i * 20);
      final frequency = 0.01 + (i * 0.005);
      final phase = animationValue + (i * math.pi / 2);
      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height - 150 - (i * 80) + math.sin((x * frequency) + phase) * waveHeight;
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