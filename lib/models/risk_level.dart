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

  static RiskLevel fromPercent(double percent) {
    if (percent >= 55) return RiskLevel.high;
    if (percent >= 20) return RiskLevel.moderate;
    return RiskLevel.low;
  }
}
