import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/data/models/order_model.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/bloc/order/order_bloc.dart';
import 'package:spinza/presentation/bloc/order/order_event.dart';
import 'package:spinza/presentation/bloc/order/order_state.dart';
import 'package:spinza/presentation/screens/order_confirmation_screen.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';
import 'dart:math' as math;

class OrderScreen extends StatefulWidget {
  final Product product;
  const OrderScreen({super.key, required this.product});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // --- Form Controllers ---
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _addressController = TextEditingController();
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.product.price;
    _quantityController.addListener(_updateTotalPrice);

    // Initialize animations
    _waveController = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_waveController);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  void _updateTotalPrice() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = widget.product.price * quantity;
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          AppStrings.confirmOrder,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
            ...List.generate(8, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 20 + (index * 50) +
                          math.sin(_waveAnimation.value + index * 1.8) * 30,
                      top: 60 + (index * 100) -
                          math.cos(_waveAnimation.value + index * 1.2) * 40,
                      child: Container(
                        width: 18 + (index * 3),
                        height: 18 + (index * 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.03 + (index * 0.007)),
                        ),
                      ),
                    );
                  },
                ),
            ),
            // Main content
            BlocListener<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is OrderSuccess) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => OrderConfirmationScreen(
                        orderedItems: state.orderedItems,
                        totalPrice: state.totalPrice,
                      ),
                    ),
                        (route) => route.isFirst,
                  );
                } else if (state is OrderFailure) {
                  _showErrorSnackBar(context, state.message);
                }
              },
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildProductHeader(),
                            const SizedBox(height: 40),
                            _buildQuantitySection(),
                            const SizedBox(height: 30),
                            _buildAddressSection(),
                            const SizedBox(height: 40),
                            _buildTotalSection(),
                            const SizedBox(height: 50),
                            _buildConfirmButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.quantity,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: AppStrings.quantity,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.numbers, color: Colors.white.withOpacity(0.8)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty || int.tryParse(value) == 0) {
                  return 'Please enter a quantity greater than 0';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: TextFormField(
              controller: _addressController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Enter your full delivery address',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.8)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a delivery address';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.total,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            'PKR ${_totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final isLoading = state is OrderInProgress;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : () {
              if (_formKey.currentState!.validate()) {
                print("DEBUG: This button's logic needs to be refactored for the cart system.");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3C72),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
            ),
            child: isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3C72)),
              ),
            )
                : const Text(
              AppStrings.confirmOrder,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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