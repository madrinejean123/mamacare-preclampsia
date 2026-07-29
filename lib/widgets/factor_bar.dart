import 'package:flutter/material.dart';

import '../models/factor.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A SHAP-style factor row: feature + value, signed contribution,
/// and a thin colored bar (red/amber = risk-raising, green = protective).
class FactorBar extends StatelessWidget {
  final Factor factor;

  const FactorBar({super.key, required this.factor});

  @override
  Widget build(BuildContext context) {
    final color = factor.isRisk ? AppColors.of(context).riskHigh : AppColors.of(context).riskLow;
    final magnitude = factor.contribution.abs().clamp(0.0, 1.0);
    final sign = factor.contribution >= 0 ? '+' : '−';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(factor.label, style: AppTextStyles.body(context, color: AppColors.of(context).ink).copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(factor.value, style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              Text(
                '$sign${(magnitude * 100).round()}%',
                style: AppTextStyles.label(context, color: color).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(height: 5, width: constraints.maxWidth, color: AppColors.of(context).line),
                    Container(
                      height: 5,
                      width: constraints.maxWidth * magnitude,
                      color: color,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
