import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale for MamaPreCare.
/// Fraunces (serif) = display face for titles, big numbers, the risk verdict.
/// Inter (sans) = everything else.
///
/// Every helper takes [context] so default text colors resolve against the
/// active light/dark [AppColors] palette. Pass [color] to override.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _fraunces({
    required double size,
    required FontWeight weight,
    required Color color,
    FontStyle style = FontStyle.normal,
    double? height,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
      height: height,
    );
  }

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display / serif
  static TextStyle riskVerdict(BuildContext context, {Color? color}) => _fraunces(
        size: 42,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).ink,
        height: 1.1,
      );

  static TextStyle screenTitle(BuildContext context, {Color? color}) => _fraunces(
        size: 24,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).ink,
        height: 1.25,
      );

  static TextStyle metricNumber(BuildContext context, {Color? color}) => _fraunces(
        size: 30,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).ink,
        height: 1.15,
      );

  static TextStyle cardHeading(BuildContext context, {Color? color}) => _fraunces(
        size: 18,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).ink,
        height: 1.3,
      );

  static TextStyle logo(BuildContext context, {Color? color}) => _fraunces(
        size: 20,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).tealPrimary,
      );

  static TextStyle heroHeadline(BuildContext context, {Color? color}) => _fraunces(
        size: 42,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).ink,
        height: 1.15,
      );

  static TextStyle heroHeadlineItalic(BuildContext context, {Color? color}) =>
      _fraunces(
        size: 42,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).tealMid,
        style: FontStyle.italic,
        height: 1.15,
      );

  // Body / sans
  static TextStyle body(BuildContext context, {Color? color}) => _inter(
        size: 15,
        weight: FontWeight.w400,
        color: color ?? AppColors.of(context).ink,
        height: 1.55,
      );

  static TextStyle bodySmall(BuildContext context, {Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w400,
        color: color ?? AppColors.of(context).inkSoft,
        height: 1.5,
      );

  static TextStyle label(BuildContext context, {Color? color}) => _inter(
        size: 13,
        weight: FontWeight.w500,
        color: color ?? AppColors.of(context).inkSoft,
      );

  static TextStyle caption(BuildContext context, {Color? color}) => _inter(
        size: 12,
        weight: FontWeight.w500,
        color: color ?? AppColors.of(context).inkMute,
      );

  static TextStyle tableHeader(BuildContext context, {Color? color}) => _inter(
        size: 12,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).inkMute,
        letterSpacing: 0.6,
      );

  static TextStyle button(BuildContext context, {Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).card,
      );

  static TextStyle link(BuildContext context, {Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w600,
        color: color ?? AppColors.of(context).tealPrimary,
      );
}
