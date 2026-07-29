import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AlertTone { info, warning, danger, neutral }

/// A soft, flat banner strip used for recommendations, disclaimers,
/// and inline alerts.
class AlertStrip extends StatelessWidget {
  final IconData icon;
  final String text;
  final AlertTone tone;

  const AlertStrip({
    super.key,
    required this.icon,
    required this.text,
    this.tone = AlertTone.info,
  });

  Color _bg(AppColors colors) {
    switch (tone) {
      case AlertTone.info:
        return colors.tealWash;
      case AlertTone.warning:
        return colors.riskModerateBg;
      case AlertTone.danger:
        return colors.riskHighBg;
      case AlertTone.neutral:
        return colors.line.withValues(alpha: 0.5);
    }
  }

  Color _fg(AppColors colors) {
    switch (tone) {
      case AlertTone.info:
        return colors.tealPrimary;
      case AlertTone.warning:
        return colors.riskModerate;
      case AlertTone.danger:
        return colors.riskHigh;
      case AlertTone.neutral:
        return colors.inkSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bg = _bg(colors);
    final fg = _fg(colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(context, color: fg).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
