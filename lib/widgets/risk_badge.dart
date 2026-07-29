import 'package:flutter/material.dart';

import '../models/risk_level.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Pill badge showing a risk level and optional percentage.
/// Soft background with the solid risk color as text.
class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final double? percent;

  const RiskBadge({super.key, required this.level, this.percent});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = percent != null
        ? '${level.label} · ${percent!.round()}%'
        : level.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: level.soft(colors),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        text,
        style: AppTextStyles.label(context, color: level.solid(colors)).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
