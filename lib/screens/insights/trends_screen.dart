import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/patient.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/app_scaffold.dart';

class TrendsScreen extends StatefulWidget {
  final String? initialPatientId;
  const TrendsScreen({super.key, this.initialPatientId});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  late String _patientId;

  @override
  void initState() {
    super.initState();
    _patientId = widget.initialPatientId ?? MockData.patients.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final patient = MockData.patientById(_patientId);

    return AppScaffold(
      currentRoute: '/trends',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            phone: phone,
            patientId: _patientId,
            onChanged: (v) => setState(() => _patientId = v),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (phone)
            Column(
              children: [
                _RiskScoreChartCard(patient: patient),
                const SizedBox(height: AppSpacing.cardGap),
                _BpChartCard(patient: patient),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _RiskScoreChartCard(patient: patient)),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(child: _BpChartCard(patient: patient)),
              ],
            ),
          const SizedBox(height: AppSpacing.cardGap),
          _InterpretationCard(patient: patient),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool phone;
  final String patientId;
  final ValueChanged<String> onChanged;
  const _Header({required this.phone, required this.patientId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final title = Text('Trends', style: AppTextStyles.screenTitle(context));
    final selector = Container(
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
          value: patientId,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.of(context).inkMute),
          style: AppTextStyles.body(context),
          items: MockData.patients
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 14), SizedBox(width: double.infinity, child: selector)],
      );
    }
    return Row(children: [Expanded(child: title), selector]);
  }
}

class _RiskScoreChartCard extends StatelessWidget {
  final Patient patient;
  const _RiskScoreChartCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final assessments = patient.assessments;
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
          Text('Risk score across visits', style: AppTextStyles.cardHeading(context)),
          SizedBox(height: phone ? 16 : 20),
          SizedBox(
            height: phone ? 200 : 230,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(show: true, horizontalInterval: 25, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.of(context).line, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 25,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: AppTextStyles.caption(context)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= assessments.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('wk ${assessments[i].gestationalWeek}', style: AppTextStyles.caption(context)),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.of(context).riskModerate,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    spots: [
                      for (var i = 0; i < assessments.length; i++)
                        FlSpot(i.toDouble(), assessments[i].riskPercent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BpChartCard extends StatelessWidget {
  final Patient patient;
  const _BpChartCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final assessments = patient.assessments;
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
            children: [
              Expanded(
                child: Text(
                  'Blood pressure across visits',
                  style: AppTextStyles.cardHeading(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _LegendDot(color: AppColors.of(context).tealMid, label: 'Systolic'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.of(context).riskHigh, label: 'Diastolic'),
            ],
          ),
          SizedBox(height: phone ? 16 : 20),
          SizedBox(
            height: phone ? 200 : 230,
            child: LineChart(
              LineChartData(
                minY: 50,
                maxY: 160,
                gridData: FlGridData(show: true, horizontalInterval: 30, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.of(context).line, strokeWidth: 1)),
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
                        if (i < 0 || i >= assessments.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('wk ${assessments[i].gestationalWeek}', style: AppTextStyles.caption(context)),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.of(context).tealMid,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    spots: [for (var i = 0; i < assessments.length; i++) FlSpot(i.toDouble(), assessments[i].systolicBp.toDouble())],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.of(context).riskHigh,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    spots: [for (var i = 0; i < assessments.length; i++) FlSpot(i.toDouble(), assessments[i].diastolicBp.toDouble())],
                  ),
                ],
              ),
            ),
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

class _InterpretationCard extends StatelessWidget {
  final Patient patient;
  const _InterpretationCard({required this.patient});

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
          Text('Interpretation', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 10),
          Text(
            '${patient.name}\'s predicted risk has risen steadily since week ${patient.riskWeek > 0 ? patient.riskWeek : patient.gestationalWeek}, tracking a corresponding rise in diastolic blood pressure. '
            'The pattern is consistent with early preeclampsia and supports continued close monitoring alongside clinical review.',
            style: AppTextStyles.bodySmall(context, color: AppColors.of(context).ink),
          ),
        ],
      ),
    );
  }
}
