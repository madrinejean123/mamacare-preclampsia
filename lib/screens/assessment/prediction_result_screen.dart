import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/mock_data.dart';
import '../../models/risk_level.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/factor_bar.dart';

class PredictionResultScreen extends StatelessWidget {
  const PredictionResultScreen({super.key});

  static const double _riskPercent = 42;
  static const RiskLevel _level = RiskLevel.moderate;

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final verdict = _VerdictCard();
    final factors = _FactorsCard();

    return AppScaffold(
      currentRoute: '/assess',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(phone: phone),
          const SizedBox(height: AppSpacing.sectionGap),
          if (phone)
            Column(children: [verdict, const SizedBox(height: AppSpacing.cardGap), factors])
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: verdict),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(flex: 6, child: factors),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool phone;
  const _Header({required this.phone});

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assess / Result', style: AppTextStyles.caption(context)),
        const SizedBox(height: 4),
        Text('Prediction result', style: AppTextStyles.screenTitle(context)),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton(onPressed: () {}, child: const Text('Save to reports')),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).riskHigh),
          child: const Text('Refer patient →'),
        ),
      ],
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: actions),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const level = PredictionResultScreen._level;
    const percent = PredictionResultScreen._riskPercent;
    final patient = MockData.patients.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          Text(
            '${patient.name} · wk ${patient.gestationalWeek} · ${DateFormat('MMM d, y').format(DateTime.now())}',
            style: AppTextStyles.caption(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(level.label, style: AppTextStyles.riskVerdict(context, color: level.solid(AppColors.of(context)))),
          const SizedBox(height: 6),
          Text('$percent% predicted probability', style: AppTextStyles.body(context, color: AppColors.of(context).inkSoft)),
          const SizedBox(height: 26),
          const _RiskGauge(percent: percent),
          const SizedBox(height: 26),
          const AlertStrip(
            icon: Icons.favorite_border_rounded,
            text: 'Recommend BP monitoring twice weekly, repeat urine dipstick, and clinical review within 7 days. Counsel the patient on danger signs.',
          ),
        ],
      ),
    );
  }
}

class _RiskGauge extends StatelessWidget {
  final double percent;
  const _RiskGauge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final needlePos = (percent / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    child: Row(
                      children: [
                        Expanded(flex: 20, child: Container(height: 10, color: AppColors.of(context).riskLowBg)),
                        Expanded(flex: 35, child: Container(height: 10, color: AppColors.of(context).riskModerateBg)),
                        Expanded(flex: 45, child: Container(height: 10, color: AppColors.of(context).riskHighBg)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: (constraints.maxWidth * needlePos - 7).clamp(0.0, constraints.maxWidth - 14),
                    top: 12,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).riskModerate,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low <20%', style: AppTextStyles.caption(context)),
            Text('Moderate', style: AppTextStyles.caption(context)),
            Text('High >55%', style: AppTextStyles.caption(context)),
          ],
        ),
      ],
    );
  }
}

class _FactorsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why this score?', style: AppTextStyles.cardHeading(context)),
          for (var i = 0; i < MockData.sampleFactors.length; i++) ...[
            FactorBar(factor: MockData.sampleFactors[i]),
            if (i != MockData.sampleFactors.length - 1) Divider(height: 1, color: AppColors.of(context).line),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.of(context).paper,
              border: Border.all(color: AppColors.of(context).line),
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            ),
            child: Text(
              'This tool supports clinical judgement — it does not replace it. Always confirm findings with a full clinical assessment.',
              style: AppTextStyles.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}
