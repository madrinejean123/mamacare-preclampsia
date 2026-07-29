import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A single stat card: caption, big Fraunces number, optional delta line.
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool deltaUp;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaUp = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption(context)),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.metricNumber(context, color: valueColor ?? colors.ink)),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  deltaUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 13,
                  color: colors.tealMid,
                ),
                const SizedBox(width: 2),
                Text(delta!, style: AppTextStyles.label(context, color: colors.tealMid)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
