import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the light and dark [ThemeData] for MamaSafe. Both register an
/// [AppColors] ThemeExtension so screens can read the active palette via
/// `AppColors.of(context)`.
class AppTheme {
  AppTheme._();

  static ThemeData _build(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.paper,
      extensions: [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.tealPrimary,
        brightness: brightness,
        primary: colors.tealPrimary,
        surface: colors.paper,
      ),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.inter(fontSize: 15, color: colors.ink, height: 1.55),
        bodySmall: GoogleFonts.inter(fontSize: 14, color: colors.inkSoft, height: 1.5),
      ),
      dividerColor: colors.line,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: colors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.tealPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.inkMute,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.card,
          foregroundColor: colors.ink,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
          side: BorderSide(color: colors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.tealPrimary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.tealPrimary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(fontSize: 15, color: colors.inkMute),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: colors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: colors.tealMid, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: colors.line),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.card,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            borderSide: BorderSide(color: colors.line),
          ),
        ),
      ),
    );
  }

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);
}
