import 'package:flutter/material.dart';

/// Tamil Nadu Government Exam Color Palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryNavy = Color(0xFF0D2137);
  static const Color primaryNavyLight = Color(0xFF1A3A5C);
  static const Color primaryNavyDark = Color(0xFF081626);

  // Accent Colors
  static const Color accentSaffron = Color(0xFFFF6B1A);
  static const Color accentSaffronLight = Color(0xFFFF8F4D);
  static const Color accentSaffronDark = Color(0xFFE55A0D);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FC);
  static const Color backgroundDark = Color(0xFF0A1929);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF112240);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A3050);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0D2137);
  static const Color textSecondaryLight = Color(0xFF5A6A7A);
  static const Color textPrimaryDark = Color(0xFFF0F4F8);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFE8F8F0);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDE8E8);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF3E0);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Subject Colors
  static const Color tamilSubject = Color(0xFF9B59B6);
  static const Color gsSubject = Color(0xFF2980B9);
  static const Color aptitudeSubject = Color(0xFF27AE60);

  // Performance Colors
  static const Color performanceExcellent = Color(0xFF2ECC71);
  static const Color performanceGood = Color(0xFF3498DB);
  static const Color performanceAverage = Color(0xFFF39C12);
  static const Color performancePoor = Color(0xFFE74C3C);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, Color(0xFF1B3A5C)],
  );

  static const LinearGradient saffronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentSaffron, Color(0xFFFF8F4D)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A5C), Color(0xFF0D2137)],
  );

  // Difficulty Colors
  static const Color difficultyEasy = Color(0xFF2ECC71);
  static const Color difficultyMedium = Color(0xFFF39C12);
  static const Color difficultyHard = Color(0xFFE74C3C);

  // Test Question Palette Colors
  static const Color answered = Color(0xFF2ECC71);
  static const Color unanswered = Color(0xFFBDC3C7);
  static const Color markedForReview = Color(0xFF9B59B6);
  static const Color currentQuestion = Color(0xFF3498DB);
  static const Color notVisited = Color(0xFFECF0F1);
}
