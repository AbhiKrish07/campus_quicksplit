import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme palette
  static const Color background = Color(0xFF0F0F14);
  static const Color cardBackground = Color(0xFF181924);
  static const Color cardElevated = Color(0xFF222436);
  static const Color surfaceBorder = Color(0xFF2D3148);

  // Light Theme palette
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFEDF2F7);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightTextMuted = Color(0xFF718096);

  // Gradient colors for Hero headers and cards
  static const Color gradientStart = Color(0xFF2D1B4E);
  static const Color gradientEnd = Color(0xFF151624);
  static const Color cardGradientStart = Color(0xFF1E1F30);
  static const Color cardGradientEnd = Color(0xFF141520);

  // Accent colors
  static const Color primary = Color(0xFF7C4DFF); // Violet
  static const Color primaryLight = Color(0xFF9E77FF);
  static const Color secondary = Color(0xFF00E5FF); // Cyan/Teal accent

  // Status & Financial colors
  static const Color positive = Color(0xFF00E676); // Emerald Green (You're owed)
  static const Color positiveBg = Color(0xFF0A2E1E);
  static const Color negative = Color(0xFFFF5252); // Coral Red (You owe)
  static const Color negativeBg = Color(0xFF381418);
  static const Color neutral = Color(0xFF9096A5);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFFA0A5B5);
  static const Color textMuted = Color(0xFF6C7285);

  // Category Icon Backgrounds
  static const Color catCoffee = Color(0xFFFF9800);
  static const Color catFood = Color(0xFFFF5252);
  static const Color catShopping = Color(0xFFE91E63);
  static const Color catSub = Color(0xFF9C27B0);
  static const Color catRent = Color(0xFF3F51B5);
  static const Color catUtil = Color(0xFF00BCD4);
  static const Color catTravel = Color(0xFF009688);
  static const Color catGeneral = Color(0xFF607D8B);

  // Linear Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF35205F), Color(0xFF171828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroLightGradient = LinearGradient(
    colors: [Color(0xFF00B4DB), Color(0xFF00F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF6C5CE7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
