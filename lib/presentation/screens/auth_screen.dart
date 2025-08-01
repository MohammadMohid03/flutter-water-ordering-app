import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_event.dart';
import 'package:spinza/presentation/bloc/auth/auth_state.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';
import 'package:spinza/presentation/widgets/background_container.dart'; // <-- IMPORT THE NEW WIDGET

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitLogin() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }

  void _submitSignup() {
    if (_signupFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthSignupRequested(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'An error occurred')));
          }
        },
        child: Container(
          // Reverted back to the original blue gradient
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF005BEA), Color(0xFF00C6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              // The Stack allows us to layer the form and the icons
              child: Stack(
                clipBehavior: Clip.none, // Allows the icon to render outside the stack's bounds
                alignment: Alignment.center,
                children: [
                  // --- The Main Form Container ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    // Add top margin to make space for the icon to sit on
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_isLogin ? 'Welcome Back!' : 'Create Account', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_isLogin ? 'Log in to continue' : 'Sign up to get started', style: textTheme.bodyMedium),
                          const SizedBox(height: 24),
                          if (_isLogin) _buildLoginForm() else _buildSignupForm(),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                text: _isLogin ? 'LOG IN' : 'SIGN UP',
                                isLoading: state.status == AuthStatus.loading,
                                onPressed: _isLogin ? _submitLogin : _submitSignup,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildSwitchAuthMode(textTheme),
                        ],
                      ),
                    ),
                  ),

                  // --- Water Drop Icon (Positioned on top) ---
                  Positioned(
                    top: -80, // This positions the icon halfway "inside" the container's top padding
                    child: Image.asset(
                      'assets/images/water_icon.png',
                      height: 100, // Increased size
                    ),
                  ),

                  // --- Spinza Logo (Positioned below) ---
                  Positioned(
                    bottom: -95, // Positioned relative to the bottom of the container
                    child: Image.asset(
                      'assets/images/spinza_icon.png',
                      height: 150,
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

  // --- NO CHANGES BELOW THIS LINE ---
  // All the _build... methods remain exactly the same as you provided them.

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildTextFormField(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value == null || !value.contains('@')) return 'Please enter a valid email';
                return null;
              }
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) return 'Password must be at least 6 characters';
                return null;
              }
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          _buildTextFormField(
              controller: _nameController,
              hintText: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              }
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value == null || !value.contains('@')) return 'Please enter a valid email';
                return null;
              }
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) return 'Password must be at least 6 characters';
                return null;
              }
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!)
          )
      ),
    );
  }

  Widget _buildSwitchAuthMode(TextTheme textTheme) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: RichText(
        text: TextSpan(
          style: textTheme.bodyMedium,
          children: [
            TextSpan(
              text: _isLogin ? "Don't have an account? " : "Already have an account? ",
            ),
            TextSpan(
              text: _isLogin ? 'Sign Up' : 'Log In',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}