import 'package:flutter/material.dart';

class AppColors {
  // Primary background colors
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF161616);
  static const Color surfaceLight = Color(0xFF222222);

  // Accent colors
  static const Color teal = Color(0xFF00E5FF);
  static const Color orange = Color(0xFFFF9100);
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textGrey = Color(0xFF757575);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);

  // Glow effects
  static BoxShadow tealGlow = BoxShadow(
    color: teal.withValues(alpha: 0.3),
    blurRadius: 10,
    spreadRadius: 2,
  );

  static BoxShadow orangeGlow = BoxShadow(
    color: orange.withValues(alpha: 0.3),
    blurRadius: 10,
    spreadRadius: 2,
  );
}
