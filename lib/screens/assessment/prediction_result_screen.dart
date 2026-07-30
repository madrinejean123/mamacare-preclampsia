import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/prediction_result.dart';
import '../../models/risk_level.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';

class PredictionResultScreen extends StatelessWidget {
  final PredictionResult? result;
  const PredictionResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    if (result == null) {
      return AppScaffold(
        currentRoute: '/assess',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No prediction result yet', style: AppTextStyles.screenTitle(context)),
              const SizedBox(height: 12),
              Text(
                'Run a new assessment to see a screening result here.',
                style: AppTextStyles.body(context, color: AppColors.of(context).inkSoft),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/assess'),
                child: const Text('Start a new assessment'),
              ),
            ],
          ),
        ),
      );
    }

    final phone = isPhone(context);
    final verdict = _VerdictCard(result: result);
    final factors = _FactorsCard(result: result);

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
  final PredictionResult result;
  const _VerdictCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final level = result.level;
    final percent = result.percent;
    final week = result.gestationalWeek;

    final caption = [
      if (result.patientName != null) result.patientName!,
      if (week != null) 'wk $week',
      DateFormat('MMM d, y').format(DateTime.now()),
    ].join(' · ');

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
            caption,
            style: AppTextStyles.caption(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(level.label, style: AppTextStyles.riskVerdict(context, color: level.solid(AppColors.of(context)))),
          const SizedBox(height: 6),
          Text('${percent.toStringAsFixed(1)}% predicted probability', style: AppTextStyles.body(context, color: AppColors.of(context).inkSoft)),
          const SizedBox(height: 26),
          _RiskGauge(percent: percent),
          const SizedBox(height: 26),
          AlertStrip(
            icon: Icons.favorite_border_rounded,
            text: level.description,
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
                        Expanded(flex: 30, child: Container(height: 10, color: AppColors.of(context).riskLowBg)),
                        Expanded(flex: 40, child: Container(height: 10, color: AppColors.of(context).riskModerateBg)),
                        Expanded(flex: 30, child: Container(height: 10, color: AppColors.of(context).riskHighBg)),
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
            Text('Low <30%', style: AppTextStyles.caption(context)),
            Text('Moderate', style: AppTextStyles.caption(context)),
            Text('High >70%', style: AppTextStyles.caption(context)),
          ],
        ),
      ],
    );
  }
}

class _FactorsCard extends StatelessWidget {
  final PredictionResult result;
  const _FactorsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final input = result.input;
    final markers = <String, String>{
      'Maternal age': '${input.maternalAge.toStringAsFixed(0)} years',
      'BMI': input.bmi.toStringAsFixed(1),
      'Blood pressure': '${input.systolicBp.toStringAsFixed(0)}/${input.diastolicBp.toStringAsFixed(0)} mmHg',
      'Hemoglobin': '${input.hemoglobinLevel.toStringAsFixed(1)} g/dL',
      'Platelet count': '${input.plateletCount.toStringAsFixed(0)} ×10³/µL',
      'Creatinine': '${input.creatinineLevel.toStringAsFixed(2)} mg/dL',
    };
    final history = <String>[
      if (input.previousPreeclampsia) 'Previous preeclampsia',
      if (input.gestationalDiabetes) 'Gestational diabetes',
      if (input.chronicHypertension) 'Chronic hypertension',
      if (input.familyHistory) 'Family history',
      if (input.smoking) 'Smoking',
      if (input.alcohol) 'Alcohol',
      if (input.physicalActivity) 'Regular physical activity',
      if (input.employmentStatus) 'Employed',
    ];

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
          Text('Clinical markers used', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 4),
          Text(
            'The exact values submitted to the screening model for this result.',
            style: AppTextStyles.caption(context),
          ),
          const SizedBox(height: 16),
          for (final entry in markers.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key, style: AppTextStyles.body(context))),
                  Text(entry.value, style: AppTextStyles.body(context, color: AppColors.of(context).ink).copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.of(context).line),
          ],
          const SizedBox(height: 12),
          Text('History & lifestyle', style: AppTextStyles.label(context)),
          const SizedBox(height: 8),
          history.isEmpty
              ? Text('None reported', style: AppTextStyles.body(context, color: AppColors.of(context).inkSoft))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final h in history)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).paper,
                          border: Border.all(color: AppColors.of(context).line),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(h, style: AppTextStyles.caption(context)),
                      ),
                  ],
                ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.of(context).paper,
              border: Border.all(color: AppColors.of(context).line),
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            ),
            child: Text(
              'This tool supports clinical judgement. It does not replace it. Always confirm findings with a full clinical assessment.',
              style: AppTextStyles.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}
