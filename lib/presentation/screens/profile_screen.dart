import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_event.dart';
import 'package:spinza/presentation/bloc/auth/auth_state.dart';
import 'dart:math' as math;

import '../widgets/custom_loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  // --- UI Animation Controllers ---
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_waveController);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut)
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Profile',
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
                      left: 30 + (index * 45) +
                          math.sin(_waveAnimation.value + index * 1.5) * 25,
                      top: 80 + (index * 90) -
                          math.cos(_waveAnimation.value + index * 0.8) * 35,
                      child: Container(
                        width: 15 + (index * 4),
                        height: 15 + (index * 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04 + (index * 0.008)),
                        ),
                      ),
                    );
                  },
                ),
            ),
            // Main content
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.authenticated) {
                  return SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _buildProfileHeader(state),
                              const SizedBox(height: 40),
                              Expanded(
                                child: _buildProfileContent(context, state),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                // Show a loader with the same theme
                return Container(
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState state) {
    return Column(
      children: [
        // Profile Avatar with glow effect
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Iconsax.user,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Welcome text
        Text(
          'Welcome Back!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.user?.displayName ?? 'User',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileInfoTile(
            icon: Iconsax.user_edit,
            title: 'Name',
            value: state.user?.displayName ?? 'N/A',
          ),
          const SizedBox(height: 20),
          _buildProfileInfoTile(
            icon: Iconsax.message,
            title: 'Email',
            value: state.user?.email ?? 'N/A',
          ),
          const SizedBox(height: 20),
          _buildProfileInfoTile(
            icon: Iconsax.calendar,
            title: 'Member Since',
            value: 'January 2025', // You can make this dynamic based on user creation date
          ),
          const SizedBox(height: 40),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Settings button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Iconsax.setting_2),
            label: const Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            onPressed: () {
              // Add settings navigation here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Logout button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Iconsax.logout),
            label: const Text(
              'LOGOUT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3C72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for the animated wave background (same as auth screen)
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