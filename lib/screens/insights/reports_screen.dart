import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'This month';

  static const _referrals = [
    (patient: 'Grace Achieng', facility: 'Mulago NRH', date: 'Jul 26', status: 'accepted'),
    (patient: 'Sarah Namuli', facility: 'Mulago NRH', date: 'Jul 25', status: 'pending'),
    (patient: 'Betty Auma', facility: 'Kawempe HC IV', date: 'Jul 18', status: 'accepted'),
    (patient: 'Doreen Apio', facility: 'Kawempe HC IV', date: 'Jul 12', status: 'accepted'),
  ];

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
          _MetricsRow(phone: phone),
          const SizedBox(height: AppSpacing.cardGap),
          if (phone)
            const Column(
              children: [_DistributionCard(), SizedBox(height: AppSpacing.cardGap), _ReferralsCard(referrals: _referrals)],
            )
          else
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: _DistributionCard()),
                  SizedBox(width: AppSpacing.cardGap),
                  Expanded(flex: 6, child: _ReferralsCard(referrals: _referrals)),
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

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download_outlined, size: 16), label: const Text('Export CSV')),
        ElevatedButton(onPressed: () {}, child: const Text('Print summary')),
      ],
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          crumb,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: periodSelector),
          const SizedBox(height: 10),
          actions,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: crumb),
        periodSelector,
        const SizedBox(width: 12),
        actions,
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final bool phone;
  const _MetricsRow({required this.phone});

  @override
  Widget build(BuildContext context) {
    if (phone) {
      return const Column(
        children: [
          MetricCard(label: 'Assessments run', value: '142', delta: '18% vs June'),
          SizedBox(height: AppSpacing.cardGap),
          MetricCard(label: 'Detection precision (audited)', value: '81%'),
          SizedBox(height: AppSpacing.cardGap),
          MetricCard(label: 'Avg. weeks gained', value: '4.6'),
        ],
      );
    }

    return const Row(
      children: [
        Expanded(child: MetricCard(label: 'Assessments run', value: '142', delta: '18% vs June')),
        SizedBox(width: AppSpacing.cardGap),
        Expanded(child: MetricCard(label: 'Detection precision (audited)', value: '81%')),
        SizedBox(width: AppSpacing.cardGap),
        Expanded(child: MetricCard(label: 'Avg. weeks gained', value: '4.6')),
      ],
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard();

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
          Text('Risk distribution · July', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 20),
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
                        PieChartSectionData(value: 68, color: AppColors.of(context).riskLow, radius: 22, showTitle: false),
                        PieChartSectionData(value: 24, color: AppColors.of(context).riskModerate, radius: 22, showTitle: false),
                        PieChartSectionData(value: 8, color: AppColors.of(context).riskHigh, radius: 22, showTitle: false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendRow(color: AppColors.of(context).riskLow, label: 'Low', value: '68%'),
                    const SizedBox(height: 10),
                    _LegendRow(color: AppColors.of(context).riskModerate, label: 'Moderate', value: '24%'),
                    const SizedBox(height: 10),
                    _LegendRow(color: AppColors.of(context).riskHigh, label: 'High', value: '8%'),
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
  final List referrals;
  const _ReferralsCard({required this.referrals});

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
          for (final r in referrals) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${r.patient} → ${r.facility}', style: AppTextStyles.bodySmall(context, color: AppColors.of(context).ink), overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    '${r.date} · ${r.status}',
                    style: AppTextStyles.caption(context, 
                      color: r.status == 'accepted' ? AppColors.of(context).riskLow : AppColors.of(context).riskModerate,
                    ),
                  ),
                ],
              ),
            ),
            if (r != referrals.last) Divider(height: 1, color: AppColors.of(context).line),
          ],
        ],
      ),
    );
  }
}
