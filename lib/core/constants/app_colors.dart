import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C5E);
  static const Color primaryDark = Color(0xFFE04F1A);

  // Secondary / Charcoal
  static const Color secondary = Color(0xFF2E2E2E);
  static const Color secondaryLight = Color(0xFF3D3D3D);
  static const Color secondaryDark = Color(0xFF1A1A1A);

  // Background
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  static const Color card = Color(0xFF252525);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textHint = Color(0xFF666666);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Divider & Borders
  static const Color divider = Color(0xFF303030);
  static const Color border = Color(0xFF3A3A3A);
  static const Color borderFocus = Color(0xFFFF6B35);

  // Shift Status Colors
  static const Color shiftOpen = Color(0xFF2196F3);
  static const Color shiftConfirmed = Color(0xFF4CAF50);
  static const Color shiftPending = Color(0xFFFF9800);
  static const Color shiftCancelled = Color(0xFFF44336);
  static const Color shiftCompleted = Color(0xFF9E9E9E);

  // Role Colors
  static const Color manager = Color(0xFF9C27B0);
  static const Color staff = Color(0xFF00BCD4);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
