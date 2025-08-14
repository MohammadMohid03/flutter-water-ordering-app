import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:spinza/presentation/screens/cart_screen.dart';
import 'package:spinza/presentation/screens/product_list_screen.dart';
import 'package:spinza/presentation/screens/client_order_history_screen.dart';
import 'package:spinza/presentation/screens/profile_screen.dart';
import 'dart:math' as math;

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _rippleController;
  late AnimationController _iconController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _iconAnimation;

  static const List<Widget> _widgetOptions = <Widget>[
    ProductListScreen(),
    CartScreen(),
    ClientOrderHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _rippleController, curve: Curves.easeOut));

    _iconAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _iconController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Trigger animations
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });

      _iconController.forward().then((_) {
        _iconController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: _widgetOptions.elementAt(_selectedIndex),

      // Custom floating bottom navigation bar
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3C72).withOpacity(0.9),
              Color(0xFF2A5298).withOpacity(0.9),
              Color(0xFF4FC3F7).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1E3C72).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              // Animated ripple effect
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: (_selectedIndex * (MediaQuery.of(context).size.width - 40) / 4) +
                        ((MediaQuery.of(context).size.width - 40) / 8) - 25,
                    top: 10,
                    child: Container(
                      width: 50 * _rippleAnimation.value,
                      height: 50 * _rippleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1 * (1 - _rippleAnimation.value)),
                      ),
                    ),
                  );
                },
              ),

              // Navigation items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Iconsax.home, 'Home'),
                  _buildNavItem(1, Iconsax.shopping_cart, 'Cart'),
                  _buildNavItem(2, Iconsax.receipt_1, 'Orders'),
                  _buildNavItem(3, Iconsax.user, 'Profile'),
                ],
              ),

              // Floating water drop indicator
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (_selectedIndex * (MediaQuery.of(context).size.width - 40) / 4) +
                    ((MediaQuery.of(context).size.width - 40) / 8) - 15,
                top: 3,
                child: Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? _iconAnimation.value : 1.0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                          size: 20,
                        ),

                        // Water drop effect for selected item
                        if (isSelected)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 2),

            // Label with fade animation
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.7,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative glass-morphism version
class GlassNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<GlassNavigationBar> createState() => _GlassNavigationBarState();
}

class _GlassNavigationBarState extends State<GlassNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      height: 75,
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
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle wave animation in background
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: MiniWavePainter(_waveAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Navigation content
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGlassNavItem(0, Iconsax.home, 'Home'),
                _buildGlassNavItem(1, Iconsax.shopping_cart, 'Cart'),
                _buildGlassNavItem(2, Iconsax.receipt_1, 'Orders'),
                _buildGlassNavItem(3, Iconsax.user, 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassNavItem(int index, IconData icon, String label) {
    final isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.7),
              size: 22,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniWavePainter extends CustomPainter {
  final double animationValue;

  MiniWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 10.0;
    final frequency = 0.02;
    final phase = animationValue;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 3) {
      final y = size.height - 30 + math.sin((x * frequency) + phase) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}