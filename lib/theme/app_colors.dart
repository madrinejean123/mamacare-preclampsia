import 'package:flutter/material.dart';

/// Brand and semantic color tokens for MamaSafe, as a ThemeExtension so the
/// whole app can switch between [light] and [dark] at runtime.
/// Access via `AppColors.of(context)` inside any build method — never
/// reference [light] or [dark] directly from widget code.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color tealDark;
  final Color tealPrimary;
  final Color tealMid;
  final Color tealLight;
  final Color tealWash;

  final Color ink;
  final Color inkSoft;
  final Color inkMute;

  final Color paper;
  final Color card;
  final Color line;

  final Color riskLow;
  final Color riskLowBg;
  final Color riskModerate;
  final Color riskModerateBg;
  final Color riskHigh;
  final Color riskHighBg;

  const AppColors({
    required this.tealDark,
    required this.tealPrimary,
    required this.tealMid,
    required this.tealLight,
    required this.tealWash,
    required this.ink,
    required this.inkSoft,
    required this.inkMute,
    required this.paper,
    required this.card,
    required this.line,
    required this.riskLow,
    required this.riskLowBg,
    required this.riskModerate,
    required this.riskModerateBg,
    required this.riskHigh,
    required this.riskHighBg,
  });

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  static const AppColors light = AppColors(
    tealDark: Color(0xFF083B32),
    tealPrimary: Color(0xFF0D5C4D),
    tealMid: Color(0xFF188066),
    tealLight: Color(0xFFDCEFE7),
    tealWash: Color(0xFFEEF7F3),
    ink: Color(0xFF22302C),
    inkSoft: Color(0xFF5B6B66),
    inkMute: Color(0xFF8CA09A),
    paper: Color(0xFFFAFAF6),
    card: Color(0xFFFFFFFF),
    line: Color(0xFFE3E9E5),
    riskLow: Color(0xFF4C8F35),
    riskLowBg: Color(0xFFEAF3E1),
    riskModerate: Color(0xFFC07A12),
    riskModerateBg: Color(0xFFFBF0DB),
    riskHigh: Color(0xFFB93E33),
    riskHighBg: Color(0xFFFAE7E4),
  );

  static const AppColors dark = AppColors(
    tealDark: Color(0xFF083B32),
    tealPrimary: Color(0xFF20A084),
    tealMid: Color(0xFF34B892),
    tealLight: Color(0xFF16332D),
    tealWash: Color(0xFF112420),
    ink: Color(0xFFF2F6F4),
    inkSoft: Color(0xFFB6C6C0),
    inkMute: Color(0xFF80968E),
    paper: Color(0xFF0C1613),
    card: Color(0xFF162420),
    line: Color(0xFF2A3A34),
    riskLow: Color(0xFF7BC85A),
    riskLowBg: Color(0xFF1C2F19),
    riskModerate: Color(0xFFE3A83E),
    riskModerateBg: Color(0xFF352712),
    riskHigh: Color(0xFFE2695C),
    riskHighBg: Color(0xFF371A16),
  );

  @override
  AppColors copyWith({
    Color? tealDark,
    Color? tealPrimary,
    Color? tealMid,
    Color? tealLight,
    Color? tealWash,
    Color? ink,
    Color? inkSoft,
    Color? inkMute,
    Color? paper,
    Color? card,
    Color? line,
    Color? riskLow,
    Color? riskLowBg,
    Color? riskModerate,
    Color? riskModerateBg,
    Color? riskHigh,
    Color? riskHighBg,
  }) {
    return AppColors(
      tealDark: tealDark ?? this.tealDark,
      tealPrimary: tealPrimary ?? this.tealPrimary,
      tealMid: tealMid ?? this.tealMid,
      tealLight: tealLight ?? this.tealLight,
      tealWash: tealWash ?? this.tealWash,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkMute: inkMute ?? this.inkMute,
      paper: paper ?? this.paper,
      card: card ?? this.card,
      line: line ?? this.line,
      riskLow: riskLow ?? this.riskLow,
      riskLowBg: riskLowBg ?? this.riskLowBg,
      riskModerate: riskModerate ?? this.riskModerate,
      riskModerateBg: riskModerateBg ?? this.riskModerateBg,
      riskHigh: riskHigh ?? this.riskHigh,
      riskHighBg: riskHighBg ?? this.riskHighBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      tealDark: Color.lerp(tealDark, other.tealDark, t)!,
      tealPrimary: Color.lerp(tealPrimary, other.tealPrimary, t)!,
      tealMid: Color.lerp(tealMid, other.tealMid, t)!,
      tealLight: Color.lerp(tealLight, other.tealLight, t)!,
      tealWash: Color.lerp(tealWash, other.tealWash, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkMute: Color.lerp(inkMute, other.inkMute, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      card: Color.lerp(card, other.card, t)!,
      line: Color.lerp(line, other.line, t)!,
      riskLow: Color.lerp(riskLow, other.riskLow, t)!,
      riskLowBg: Color.lerp(riskLowBg, other.riskLowBg, t)!,
      riskModerate: Color.lerp(riskModerate, other.riskModerate, t)!,
      riskModerateBg: Color.lerp(riskModerateBg, other.riskModerateBg, t)!,
      riskHigh: Color.lerp(riskHigh, other.riskHigh, t)!,
      riskHighBg: Color.lerp(riskHighBg, other.riskHighBg, t)!,
    );
  }
}
