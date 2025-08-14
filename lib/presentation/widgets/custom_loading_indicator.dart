import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double size;
  const CustomLoadingIndicator({super.key, this.size = 150.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: size,
        height: size,
      ),
    );
  }
}