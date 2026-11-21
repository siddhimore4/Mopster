import 'package:flutter/material.dart';

/// Central Design System Color Palette for Mopster.
/// Aesthetic Direction: Premium, minimal, elegant, modern, nature-inspired lifestyle brand.
class AppColors {
  // --- Core Palette ---
  static const Color primaryForestGreen = Color(0xFF183D2B); // Deep Forest Green (#183D2B)
  static const Color secondarySage = Color(0xFFA8B5A0);      // Muted Sage Green (#A8B5A0)
  static const Color accentOlive = Color(0xFF8B956B);        // Soft Olive (#8B956B)
  static const Color mainBackground = Color(0xFFF5F1E8);     // Warm Cream (#F5F1E8)
  static const Color ivoryCard = Color(0xFFFFFCF6);          // Soft Ivory (#FFFCF6)
  static const Color lightBeige = Color(0xFFEAE4D8);         // Light Beige (#EAE4D8)
  static const Color darkCharcoal = Color(0xFF292C27);       // Dark Charcoal (#292C27)
  static const Color mutedGreyText = Color(0xFF77786F);      // Muted Grey (#77786F)

  // --- Brand Semantic Mappings ---
  static const Color forestGreen = primaryForestGreen;
  static const Color forestGreenDark = Color(0xFF10281D);
  static const Color forestGreenLight = Color(0xFFE8EFE5);   // Gentle Sage tint wash
  static const Color deepCharcoal = darkCharcoal;
  static const Color warmCream = mainBackground;
  static const Color pureWhite = ivoryCard;
  static const Color mutedGrey = mutedGreyText;
  static const Color softBorder = Color(0xFFE2DDD2);         // Natural warm border
  static const Color softBorderStrong = Color(0xFFD3CCC0);

  // Surfaces & Backgrounds
  static const Color background = mainBackground;
  static const Color cardBackground = ivoryCard;
  static const Color secondaryBackground = lightBeige;
  static const Color surfaceMuted = lightBeige;

  // Harmonized Natural Accents (eliminating harsh neons)
  static const Color freshMint = Color(0xFFE8EFE5);          // Muted Sage Wash
  static const Color electricLime = accentOlive;             // Soft Olive Accent
  static const Color electricLimeDark = Color(0xFF758055);

  // Backward Compatibility Aliases
  static const Color primaryMint = forestGreen;
  static const Color primaryMintDark = forestGreenDark;
  static const Color primaryMintLight = forestGreenLight;
  static const Color accentSoftGreen = secondarySage;
  static const Color accentPill = accentOlive;

  // Typography
  static const Color charcoal = darkCharcoal;
  static const Color textPrimary = darkCharcoal;
  static const Color textSecondary = mutedGreyText;
  static const Color textMuted = Color(0xFF93948A);

  // Borders & Dividers
  static const Color borderLight = softBorder;
  static const Color divider = Color(0xFFEAE4D8);

  // Status Colors (Refined Earth & Organic Tones)
  static const Color statusConfirmed = Color(0xFF183D2B);    // Deep Forest Green
  static const Color statusPending = Color(0xFF9E722A);      // Warm Earthy Amber
  static const Color statusCancelled = Color(0xFFA84236);    // Muted Terracotta Red
  static const Color statusCompleted = Color(0xFF2D5C43);    // Natural Forest Leaf
}
