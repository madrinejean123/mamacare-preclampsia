import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum RiskLevel { low, moderate, high }

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.high:
        return 'High';
    }
  }

  Color solid(AppColors colors) {
    switch (this) {
      case RiskLevel.low:
        return colors.riskLow;
      case RiskLevel.moderate:
        return colors.riskModerate;
      case RiskLevel.high:
        return colors.riskHigh;
    }
  }

  Color soft(AppColors colors) {
    switch (this) {
      case RiskLevel.low:
        return colors.riskLowBg;
      case RiskLevel.moderate:
        return colors.riskModerateBg;
      case RiskLevel.high:
        return colors.riskHighBg;
    }
  }

  /// Mirrors the interpretation text from the screening model's own tool,
  /// so the wording matches regardless of where the result is shown.
  String get description {
    switch (this) {
      case RiskLevel.low:
        return 'Clinical profile is consistent with normal pregnancy.';
      case RiskLevel.moderate:
        return 'Patient shows several clinical indicators. Increased monitoring is recommended.';
      case RiskLevel.high:
        return 'High correlation with historical preeclampsia cases. Immediate specialist review recommended.';
    }
  }

  /// Matches the screening model's own category boundaries (api.py's
  /// categorize()) — kept in sync so a patient's badge never disagrees
  /// with the category shown on their own assessment result.
  static RiskLevel fromPercent(double percent) {
    if (percent >= 70) return RiskLevel.high;
    if (percent >= 30) return RiskLevel.moderate;
    return RiskLevel.low;
  }
}
