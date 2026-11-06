import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep space / futuristic navy background
  static const Color background = Color(0xFF060B14);
  static const Color backgroundSecondary = Color(0xFF0A1322);
  static const Color surface = Color(0xFF0C1B2E);
  static const Color surfaceLight = Color(0xFF13243B);

  // Neon Cyan / Electric Blue accents
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDark = Color(0xFF00B4D8);
  static const Color cyanGlow = Color(0x6600E5FF);
  static const Color cyanBorder = Color(0x3300E5FF);

  // Status & indicators
  static const Color green = Color(0xFF00E676);
  static const Color amber = Color(0xFFFFB300);
  static const Color red = Color(0xFFFF5252);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8EA9C7);
  static const Color textMuted = Color(0xFF536A84);
  static const Color darkText = Color(0xFF04101E);

  // Borders & Dividers
  static const Color borderSubtle = Color(0x1A00E5FF);
  static const Color glassFill = Color(0x990C1A2E);
  static const Color inputFill = Color(0xFF081423);
}

class AppTypography {
  // Primary brand / display headings
  static TextStyle display({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.5,
  }) => GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );

  // Futuristic digital display (KPI numbers, telemetry, EV stats, capsule badges)
  static TextStyle digital({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = 1.0,
  }) => GoogleFonts.orbitron(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );

  // Headings & Section Titles
  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.3,
  }) => GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );

  // Body text, subtitles, and labels
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
    double letterSpacing = 0.2,
    double? height,
  }) => GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // Button text & uppercase tech actions
  static TextStyle button({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.darkText,
    double letterSpacing = 1.6,
  }) => GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.cyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.cyanDark,
        surface: AppColors.surface,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
    );
  }
}
