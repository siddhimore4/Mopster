import 'package:flutter/material.dart';
import 'colors.dart';

/// Central Typography System for Mopster.
/// Headings: Elegant Serif (Warm, timeless, editorial, premium).
/// Body/UI: Modern, clean Sans-Serif (Readable, refined, purposeful).
class AppTypography {
  // Editorial Serif Family (supported natively across platforms)
  static const String serifFamily = 'serif';

  // --- Editorial Serif Headings ---
  static TextStyle headingHero({
    Color color = AppColors.darkCharcoal,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = -0.5,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.22,
    );
  }

  static TextStyle headingLarge({
    Color color = AppColors.darkCharcoal,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = -0.4,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.25,
    );
  }

  static TextStyle headingMedium({
    Color color = AppColors.darkCharcoal,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = -0.3,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.3,
    );
  }

  static TextStyle headingSmall({
    Color color = AppColors.darkCharcoal,
    double fontSize = 15.5,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = -0.2,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.3,
    );
  }

  // --- Clean Sans-Serif for Body, Inputs, Labels & Buttons ---
  static TextStyle bodyLarge({
    Color color = AppColors.darkCharcoal,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodyMedium({
    Color color = AppColors.mutedGreyText,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle bodySmall({
    Color color = AppColors.mutedGreyText,
    double fontSize = 11.5,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.35,
    );
  }

  static TextStyle labelBold({
    Color color = AppColors.darkCharcoal,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 0.3,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle buttonText({
    Color color = Colors.white,
    double fontSize = 14.5,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.2,
    );
  }
}
