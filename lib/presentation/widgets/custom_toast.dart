import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// This is a helper function, not a widget. It can be called from anywhere.
void showCustomToast(BuildContext context, String message, {bool isError = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // The content of the toast
      content: Row(
        children: [
          Icon(
            isError ? Iconsax.warning_2 : Iconsax.tick_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      // Styling of the toast container
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating, // Makes it float above the bottom nav bar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
    ),
  );
}