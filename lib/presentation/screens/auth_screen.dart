import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_event.dart';
import 'package:spinza/presentation/bloc/auth/auth_state.dart';
import 'package:spinza/presentation/widgets/custom_toast.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  // --- UI Animation Controllers ---
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // --- Form Controllers & State ---
  bool _isLogin = true; // To switch between Login and Sign Up
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_waveController);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validate the form first
    if (_formKey.currentState?.validate() ?? false) {
      if (_isLogin) {
        // Dispatch Login Event
        context.read<AuthBloc>().add(AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ));
      } else {
        // Dispatch Sign Up Event
        context.read<AuthBloc>().add(AuthSignupRequested(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure) {
            showCustomToast(context, state.errorMessage ?? 'An error occurred');
          }
        },
        child: Container(
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
              // Floating bubbles code restored
              ...List.generate(6, (index) =>
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Positioned(
                        left: 50 + (index * 60) +
                            math.sin(_waveAnimation.value + index * 2) * 20, // Varied motion
                        top: 100 + (index * 100) -
                            math.cos(_waveAnimation.value + index) * 40, // Varied motion
                        child: Container(
                          width: 20 + (index * 5),
                          height: 20 + (index * 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05 + (index * 0.01)), // Varied opacity
                          ),
                        ),
                      );
                    },
                  ),
              ),
              // --- END OF FIX ---
              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogoAndTitle(),
                            const SizedBox(height: 50),
                            _buildFormContainer(context),
                            const SizedBox(height: 30),
                            _buildAuthSwitch(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.water_drop, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: Text(
            _isLogin ? 'Welcome Back' : 'Create Account',
            key: ValueKey(_isLogin), // Key is important for AnimatedSwitcher
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
          ),
        ),
        Text(
          _isLogin ? 'Sign in to continue' : 'Get started with Spinza',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildFormContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: !_isLogin ?
              Column(
                children: [
                  _buildTextFormField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (val) => (val?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ) : const SizedBox.shrink(),
            ),
            _buildTextFormField(
              controller: _emailController,
              hintText: 'Email Address',
              icon: Icons.email_outlined,
              validator: (val) => !(val?.contains('@') ?? false) ? 'Please enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (val) => (val?.length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state.status == AuthStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3C72),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                      _isLogin ? 'SIGN IN' : 'SIGN UP',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withOpacity(0.8)),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAuthSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLogin = !_isLogin;
            });
          },
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
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