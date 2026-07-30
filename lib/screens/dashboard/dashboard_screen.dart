import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/patient.dart';
import '../../models/stats.dart';
import '../../services/patient_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/risk_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<(List<Patient>, ClinicStats)> _future;

  @override
  void initState() {
    super.initState();
    final service = PatientService();
    _future = (service.fetchPatients(), service.fetchStats()).wait;
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(phone: phone),
          const SizedBox(height: AppSpacing.sectionGap),
          FutureBuilder<(List<Patient>, ClinicStats)>(
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
                  text: 'Could not load dashboard data: ${snapshot.error}',
                );
              }
              final (patients, stats) = snapshot.data!;
              final attention = [...patients]..sort((a, b) => b.riskPercent.compareTo(a.riskPercent));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricsRow(phone: phone, stats: stats),
                  const SizedBox(height: AppSpacing.cardGap),
                  _ContentRow(
                    phone: phone,
                    chart: _AssessmentsChartCard(weekly: stats.weeklyAssessments),
                    attention: _AttentionCard(patients: attention.take(4).toList()),
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
  const _Header({required this.phone});

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mulago Antenatal Clinic', style: AppTextStyles.caption(context)),
        const SizedBox(height: 4),
        Text('Good morning', style: AppTextStyles.screenTitle(context)),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/assess'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New assessment'),
        ),
      ],
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 16), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: title),
        actions,
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
      MetricCard(label: 'Active patients', value: '${stats.activePatients}'),
      MetricCard(label: 'Assessments this week', value: '${stats.assessmentsThisWeek}'),
      MetricCard(label: 'High-risk flagged', value: '${stats.highRiskCount}', valueColor: AppColors.of(context).riskHigh),
      const MetricCard(label: 'Referrals sent', value: 'Not tracked yet'),
    ];

    if (phone) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.cardGap,
        crossAxisSpacing: AppSpacing.cardGap,
        childAspectRatio: 1.0,
        children: cards,
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

class _ContentRow extends StatelessWidget {
  final bool phone;
  final Widget chart;
  final Widget attention;

  const _ContentRow({required this.phone, required this.chart, required this.attention});

  @override
  Widget build(BuildContext context) {
    if (phone) {
      return Column(
        children: [chart, const SizedBox(height: AppSpacing.cardGap), attention],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 7, child: chart),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(flex: 5, child: attention),
        ],
      ),
    );
  }
}

class _AssessmentsChartCard extends StatelessWidget {
  final List<WeekBucket> weekly;
  const _AssessmentsChartCard({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Risk assessments · last 8 weeks',
                  style: AppTextStyles.cardHeading(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('weekly', style: AppTextStyles.caption(context)),
            ],
          ),
          SizedBox(height: phone ? 16 : 20),
          SizedBox(
            height: phone ? 200 : 230,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('W${value.toInt() + 1}', style: AppTextStyles.caption(context)),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < weekly.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (weekly[i].low + weekly[i].moderate + weekly[i].high).toDouble(),
                          width: phone ? 16 : 22,
                          borderRadius: BorderRadius.circular(4),
                          rodStackItems: [
                            BarChartRodStackItem(0, weekly[i].low.toDouble(), AppColors.of(context).riskLow),
                            BarChartRodStackItem(weekly[i].low.toDouble(), (weekly[i].low + weekly[i].moderate).toDouble(), AppColors.of(context).riskModerate),
                            BarChartRodStackItem((weekly[i].low + weekly[i].moderate).toDouble(),
                                (weekly[i].low + weekly[i].moderate + weekly[i].high).toDouble(), AppColors.of(context).riskHigh),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            children: [
              _LegendDot(color: AppColors.of(context).riskLow, label: 'Low'),
              _LegendDot(color: AppColors.of(context).riskModerate, label: 'Moderate'),
              _LegendDot(color: AppColors.of(context).riskHigh, label: 'High'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final List<Patient> patients;
  const _AttentionCard({required this.patients});

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
          Text('Needs attention today', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 14),
          if (patients.isEmpty)
            Text('No patients yet.', style: AppTextStyles.bodySmall(context, color: AppColors.of(context).inkSoft))
          else
            for (final p in patients) ...[
              InkWell(
                onTap: () => context.go('/patients/${p.id}'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.of(context).tealLight,
                        child: Text(p.initials, style: AppTextStyles.caption(context, color: AppColors.of(context).tealPrimary).copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('${p.name} · wk ${p.gestationalWeek}', style: AppTextStyles.bodySmall(context, color: AppColors.of(context).ink), overflow: TextOverflow.ellipsis),
                      ),
                      RiskBadge(level: p.riskLevel, percent: p.riskPercent),
                    ],
                  ),
                ),
              ),
              if (p != patients.last) Divider(height: 1, color: AppColors.of(context).line),
            ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/patients'),
              child: const Text('View all patients'),
            ),
          ),
        ],
      ),
    );
  }
}
