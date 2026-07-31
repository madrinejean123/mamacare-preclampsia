import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/patient_me.dart';
import '../../services/auth_service.dart';
import '../../services/patient_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/theme_toggle_button.dart';

/// The patient's own view — deliberately not AppScaffold. A patient never
/// sees the clinic sidebar (Patients list, New assessment, other patients'
/// data); this is a single, self-contained read-only page.
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late Future<PatientMeView> _future;

  @override
  void initState() {
    super.initState();
    _future = PatientService().fetchMyPatientView();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final phone = isPhone(context);

    return Scaffold(
      backgroundColor: colors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(phone ? 16 : 32),
                    child: FutureBuilder<PatientMeView>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return AlertStrip(
                            icon: Icons.error_outline_rounded,
                            tone: AlertTone.danger,
                            text: 'Could not load your record: ${snapshot.error}',
                          );
                        }
                        return _Content(view: snapshot.data!, phone: phone);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      color: colors.tealDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.favorite, color: colors.tealPrimary, size: 15),
          ),
          const SizedBox(width: 10),
          Text('MamaPreCare', style: AppTextStyles.logo(context, color: Colors.white).copyWith(fontSize: 17)),
          const Spacer(),
          ThemeToggleButton(color: Colors.white.withValues(alpha: 0.85)),
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await AuthService.instance.logout();
              if (context.mounted) context.go('/');
            },
            icon: Icon(Icons.logout_rounded, color: Colors.white.withValues(alpha: 0.85), size: 20),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final PatientMeView view;
  final bool phone;
  const _Content({required this.view, required this.phone});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final edd = view.edd != null ? DateFormat('MMM d, y').format(view.edd!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, ${view.name.split(' ').first}', style: AppTextStyles.screenTitle(context)),
        const SizedBox(height: 6),
        Text(
          [
            if (view.gestationalWeek != null) 'Week ${view.gestationalWeek}',
            if (edd != null) 'Due $edd',
          ].join(' · '),
          style: AppTextStyles.bodySmall(context),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.tealWash,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.favorite_border_rounded, color: colors.tealPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  view.statusMessage,
                  style: AppTextStyles.body(context, color: colors.ink).copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        if (view.vitals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.all(color: colors.line),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Text(
              'No check-ins recorded yet. Your care team will add these after your next visit.',
              style: AppTextStyles.bodySmall(context, color: colors.inkSoft),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.all(color: colors.line),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Blood pressure at your visits', style: AppTextStyles.cardHeading(context)),
                const SizedBox(height: 18),
                SizedBox(
                  height: phone ? 200 : 230,
                  child: LineChart(
                    LineChartData(
                      minY: 50,
                      maxY: 160,
                      gridData: FlGridData(show: true, horizontalInterval: 30, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: colors.line, strokeWidth: 1)),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            interval: 30,
                            getTitlesWidget: (v, m) => Text('${v.toInt()}', style: AppTextStyles.caption(context)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (v, m) {
                              final i = v.toInt();
                              if (i < 0 || i >= view.vitals.length) return const SizedBox();
                              final wk = view.vitals[i].gestationalWeek;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(wk != null ? 'wk $wk' : '', style: AppTextStyles.caption(context)),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: colors.tealMid,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: true),
                          spots: [for (var i = 0; i < view.vitals.length; i++) FlSpot(i.toDouble(), view.vitals[i].systolicBp.toDouble())],
                        ),
                        LineChartBarData(
                          isCurved: true,
                          color: colors.riskHigh,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: true),
                          spots: [for (var i = 0; i < view.vitals.length; i++) FlSpot(i.toDouble(), view.vitals[i].diastolicBp.toDouble())],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 18,
                  children: [
                    _LegendDot(color: colors.tealMid, label: 'Systolic'),
                    _LegendDot(color: colors.riskHigh, label: 'Diastolic'),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.cardGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.paper,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          child: Text(
            'This is a summary for your own reference. For questions about your results or care plan, please speak with your midwife or doctor at your next visit.',
            style: AppTextStyles.caption(context),
          ),
        ),
      ],
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
