import 'package:flutter/material.dart';

class AppColors {
  // --- Gen-Z Inspired Lifestyle Palette ---
  static const Color electricLime = Color(0xFFC7F464);
  static const Color electricLimeDark = Color(0xFFA8DE3D);
  static const Color freshMint = Color(0xFFDDF7E3);
  static const Color forestGreen = Color(0xFF174D3B);
  static const Color forestGreenDark = Color(0xFF0F3629);
  static const Color forestGreenLight = Color(0xFFE8F6EE);
  static const Color deepCharcoal = Color(0xFF202720);
  static const Color warmCream = Color(0xFFFAF8F1);
  static const Color pureWhite = Colors.white;
  static const Color mutedGrey = Color(0xFF777D76);
  static const Color softBorder = Color(0xFFE5E9E2);

  // --- Mapped Aliases for Seamless Backward Compatibility ---
  static const Color primaryMint = forestGreen;
  static const Color primaryMintDark = forestGreenDark;
  static const Color primaryMintLight = forestGreenLight;
  static const Color accentSoftGreen = freshMint;
  static const Color accentPill = electricLime;

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F9F6); // Soft organic off-white
  static const Color cardBackground = Colors.white;
  static const Color surfaceMuted = Color(0xFFF0F4EF);

  // Typography - Charcoal & Muted Slate
  static const Color charcoal = deepCharcoal;
  static const Color textSecondary = mutedGrey;
  static const Color textMuted = Color(0xFF9EA39D);

  // Borders & Dividers
  static const Color borderLight = softBorder;
  static const Color divider = Color(0xFFEDF2EB);

  // Status Colors (Refined Organic Tone)
  static const Color statusConfirmed = Color(0xFF15803D); // Emerald Green
  static const Color statusPending = Color(0xFFD97706);   // Warm Amber
  static const Color statusCancelled = Color(0xFFDC2626); // Crisp Crimson
  static const Color statusCompleted = Color(0xFF2563EB); // Cobalt Blue
}
