import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme palette
  static const Color background = Color(0xFF0F172A); // Slate dark
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color cardElevated = Color(0xFF334155);
  static const Color surfaceBorder = Color(0xFF475569);

  // Light Theme palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);

  // Electric Blue Palette (Matching Image 3 Splitwise Showcase)
  static const Color primary = Color(0xFF2563EB); // Electric Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color electricBlue = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue accent

  // Status & Financial colors
  static const Color positive = Color(0xFF10B981); // Emerald Green (You're owed)
  static const Color positiveBg = Color(0xFF064E3B);
  static const Color negative = Color(0xFFEF4444); // Coral Red (You owe)
  static const Color negativeBg = Color(0xFF7F1D1D);
  static const Color neutral = Color(0xFF94A3B8);

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  // Category Icon Backgrounds
  static const Color catCoffee = Color(0xFFF59E0B);
  static const Color catFood = Color(0xFFEF4444);
  static const Color catShopping = Color(0xFFEC4899);
  static const Color catSub = Color(0xFF8B5CF6);
  static const Color catRent = Color(0xFF3B82F6);
  static const Color catUtil = Color(0xFF06B6D4);
  static const Color catTravel = Color(0xFF10B981);
  static const Color catGeneral = Color(0xFF64748B);

  // Linear Gradients matching Image 3 Splitwise Mockup
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroLightGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
