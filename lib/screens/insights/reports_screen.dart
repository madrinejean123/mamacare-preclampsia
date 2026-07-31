import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/stats.dart';
import '../../services/patient_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'This month';
  late Future<ClinicStats> _future;

  @override
  void initState() {
    super.initState();
    _future = PatientService().fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/reports',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(phone: phone, period: _period, onPeriodChanged: (v) => setState(() => _period = v)),
          const SizedBox(height: AppSpacing.sectionGap),
          FutureBuilder<ClinicStats>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return AlertStrip(
                  icon: Icons.error_outline_rounded,
                  tone: AlertTone.danger,
                  text: 'Could not load report data: ${snapshot.error}',
                );
              }
              final stats = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricsRow(phone: phone, stats: stats),
                  const SizedBox(height: AppSpacing.cardGap),
                  if (phone)
                    Column(
                      children: [
                        _DistributionCard(stats: stats),
                        const SizedBox(height: AppSpacing.cardGap),
                        const _ReferralsCard(),
                      ],
                    )
                  else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: _DistributionCard(stats: stats)),
                          const SizedBox(width: AppSpacing.cardGap),
                          const Expanded(flex: 6, child: _ReferralsCard()),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool phone;
  final String period;
  final ValueChanged<String> onPeriodChanged;

  const _Header({required this.phone, required this.period, required this.onPeriodChanged});

  @override
  Widget build(BuildContext context) {
    final crumb = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insights / Reports', style: AppTextStyles.caption(context)),
        const SizedBox(height: 4),
        Text('Reports and analytics', style: AppTextStyles.screenTitle(context)),
      ],
    );

    final periodSelector = Container(
      height: AppSpacing.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.of(context).card,
          value: period,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.of(context).inkMute),
          style: AppTextStyles.body(context),
          items: const ['This week', 'This month', 'This quarter']
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) {
            if (v != null) onPeriodChanged(v);
          },
        ),
      ),
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          crumb,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: periodSelector),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: crumb),
        periodSelector,
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final bool phone;
  final ClinicStats stats;
  const _MetricsRow({required this.phone, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(label: 'Assessments run', value: '${stats.totalAssessments}'),
      const MetricCard(label: 'Detection precision (audited)', value: 'Not tracked yet'),
      const MetricCard(label: 'Avg. weeks gained', value: 'Not tracked yet'),
    ];

    if (phone) {
      return Column(
        children: [
          for (final c in cards) ...[c, const SizedBox(height: AppSpacing.cardGap)],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: AppSpacing.cardGap),
        ],
      ],
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final ClinicStats stats;
  const _DistributionCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final low = stats.riskDistribution['low'] ?? 0;
    final moderate = stats.riskDistribution['moderate'] ?? 0;
    final high = stats.riskDistribution['high'] ?? 0;
    final total = low + moderate + high;
    String pct(int n) => total == 0 ? '0%' : '${(n / total * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk distribution (current)', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 20),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No assessments yet.', style: AppTextStyles.bodySmall(context, color: AppColors.of(context).inkSoft)),
            )
          else
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 46,
                        sections: [
                          PieChartSectionData(value: low.toDouble(), color: AppColors.of(context).riskLow, radius: 22, showTitle: false),
                          PieChartSectionData(value: moderate.toDouble(), color: AppColors.of(context).riskModerate, radius: 22, showTitle: false),
                          PieChartSectionData(value: high.toDouble(), color: AppColors.of(context).riskHigh, radius: 22, showTitle: false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendRow(color: AppColors.of(context).riskLow, label: 'Low', value: pct(low)),
                      const SizedBox(height: 10),
                      _LegendRow(color: AppColors.of(context).riskModerate, label: 'Moderate', value: pct(moderate)),
                      const SizedBox(height: 10),
                      _LegendRow(color: AppColors.of(context).riskHigh, label: 'High', value: pct(high)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall(context, color: AppColors.of(context).ink)),
        const SizedBox(width: 8),
        Text(value, style: AppTextStyles.label(context)),
      ],
    );
  }
}

class _ReferralsCard extends StatelessWidget {
  const _ReferralsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent referrals', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 10),
          AlertStrip(
            icon: Icons.info_outline_rounded,
            text: 'Referral tracking isn\'t built yet. There\'s no referrals table in the database. '
                'The "Refer patient" button on a result screen doesn\'t record anything today.',
          ),
        ],
      ),
    );
  }
}
