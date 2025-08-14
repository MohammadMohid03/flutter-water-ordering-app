import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/cart/cart_bloc.dart';
import 'package:spinza/presentation/bloc/cart/cart_state.dart';
import 'package:spinza/presentation/bloc/order/order_bloc.dart';
import 'package:spinza/presentation/bloc/order/order_event.dart';
import 'package:spinza/presentation/bloc/order/order_state.dart';
import 'package:spinza/presentation/screens/order_confirmation_screen.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';
import 'package:spinza/data/models/cart_item_model.dart';
import 'dart:math' as math;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // --- Form Controllers ---
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // For the delivery day dropdown
  String? _selectedDay;
  final List<String> _deliveryDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
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
                      left: 25 + (index * 45) +
                          math.sin(_waveAnimation.value + index * 1.6) * 25,
                      top: 70 + (index * 95) -
                          math.cos(_waveAnimation.value + index * 1.1) * 35,
                      child: Container(
                        width: 16 + (index * 3),
                        height: 16 + (index * 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.03 + (index * 0.006)),
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
                            _buildDeliveryAddressSection(),
                            const SizedBox(height: 30),
                            _buildDeliveryDaySection(),
                            const SizedBox(height: 30),
                            _buildPaymentMethodSection(),
                            const SizedBox(height: 100), // Space for bottom button
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
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your house number and street',
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter an address' : null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter your city',
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a city' : null,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField('Delivering only in Ghotki'),
        ],
      ),
    );
  }

  Widget _buildDeliveryDaySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Preferred Delivery Day',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdownFormField(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                  Icons.payment_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPaymentMethodTile(),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFormField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: _selectedDay,
        hint: Text(
          'Choose a delivery day',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        dropdownColor: const Color(0xFF1E3C72),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.8)),
        items: _deliveryDays.map((String day) {
          return DropdownMenuItem<String>(
            value: day,
            child: Text(
              day,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDay = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a day' : null,
      ),
    );
  }

  Widget _buildPaymentMethodTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: const ListTileThemeData(
            textColor: Colors.white,
          ),
        ),
        child: RadioListTile<String>(
          title: const Text(
            'Cash on Delivery',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          subtitle: Text(
            'Pay when your order arrives',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          value: 'Cash on Delivery',
          groupValue: 'Cash on Delivery',
          onChanged: (value) {},
          activeColor: Colors.white,
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.money_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
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
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final isLoading = orderState is OrderInProgress;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<OrderBloc>().add(CreateOrder(
                          items: cartState.items,
                          address: _addressController.text,
                          city: _cityController.text,
                          deliveryDay: _selectedDay!,
                          paymentMethod: 'Cash on Delivery',
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3C72),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
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
                      'PLACE ORDER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
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