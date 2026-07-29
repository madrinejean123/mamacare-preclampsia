import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';

/// Multi-step form progress indicator.
/// Web/tablet: "1 · Patient — 2 · Measurements — ..." with a teal top rule
/// on completed/current steps.
/// Phone: collapses to "Step 2 of 4" with a thin progress bar.
class StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;

  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (isPhone(context)) {
      final progress = (currentIndex + 1) / steps.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${currentIndex + 1} of ${steps.length} · ${steps[currentIndex]}',
            style: AppTextStyles.label(context, color: AppColors.of(context).tealPrimary),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.of(context).line,
              valueColor: AlwaysStoppedAnimation(AppColors.of(context).tealMid),
            ),
          ),
        ],
      );
    }

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.of(context).tealMid : AppColors.of(context).line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${i + 1} · ${steps[i]}',
                  style: AppTextStyles.label(context, 
                    color: isActive ? AppColors.of(context).tealPrimary : AppColors.of(context).inkMute,
                  ).copyWith(fontWeight: isActive ? FontWeight.w600 : FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
