import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/mock_data.dart';
import '../../models/patient.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/risk_badge.dart';
import '../../widgets/week_ribbon.dart';

class PatientProfileScreen extends StatelessWidget {
  final String patientId;
  const PatientProfileScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient = MockData.patientById(patientId);
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/patients',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(patient: patient, phone: phone),
          const SizedBox(height: AppSpacing.sectionGap),
          _MetricsRow(patient: patient, phone: phone),
          const SizedBox(height: AppSpacing.cardGap),
          _TimelineAndHistory(patient: patient, phone: phone),
          const SizedBox(height: AppSpacing.cardGap),
          _NotesCard(patient: patient),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final Patient patient;
  final bool phone;
  const _TitleRow({required this.patient, required this.phone});

  @override
  Widget build(BuildContext context) {
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.of(context).tealLight,
          child: Text(patient.initials, style: AppTextStyles.cardHeading(context, color: AppColors.of(context).tealPrimary)),
        ),
        const SizedBox(width: 14),
        Text(patient.name, style: AppTextStyles.screenTitle(context)),
        const SizedBox(width: 12),
        RiskBadge(level: patient.riskLevel, percent: patient.riskPercent),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => context.go('/trends?patient=${patient.id}'),
          child: const Text('View trends'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => context.go('/assess'),
          child: const Text('New assessment'),
        ),
      ],
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [identity, const SizedBox(height: 16), actions],
      );
    }

    return Row(
      children: [
        Expanded(child: identity),
        actions,
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final Patient patient;
  final bool phone;
  const _MetricsRow({required this.patient, required this.phone});

  @override
  Widget build(BuildContext context) {
    final edd = DateFormat('MMM d, y').format(patient.edd);
    final cards = [
      _SmallMetric(label: 'Age', value: '${patient.age}'),
      _SmallMetric(label: 'Gestational week', value: 'Wk ${patient.gestationalWeek}', caption: 'EDD $edd'),
      _SmallMetric(label: 'Gravida / Para', value: 'G${patient.gravida} P${patient.para}'),
      _SmallMetric(label: 'Latest BP', value: '${patient.systolicBp}/${patient.diastolicBp}'),
    ];

    if (phone) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.cardGap,
        crossAxisSpacing: AppSpacing.cardGap,
        childAspectRatio: 1.2,
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

class _SmallMetric extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;

  const _SmallMetric({required this.label, required this.value, this.caption});

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
          Text(label, style: AppTextStyles.caption(context)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.cardHeading(context)),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(caption!, style: AppTextStyles.caption(context)),
          ],
        ],
      ),
    );
  }
}

class _TimelineAndHistory extends StatelessWidget {
  final Patient patient;
  final bool phone;
  const _TimelineAndHistory({required this.patient, required this.phone});

  @override
  Widget build(BuildContext context) {
    final timeline = _TimelineCard(patient: patient);
    final history = _HistoryCard(patient: patient);

    if (phone) {
      return Column(children: [timeline, const SizedBox(height: AppSpacing.cardGap), history]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: timeline),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(child: history),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Patient patient;
  const _TimelineCard({required this.patient});

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
          Text('Pregnancy timeline', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 18),
          WeekRibbon(currentWeek: patient.gestationalWeek, riskWeek: patient.riskWeek),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('wk 4', style: AppTextStyles.caption(context)),
              Text('wk ${patient.gestationalWeek} · today', style: AppTextStyles.caption(context)),
              Text('wk 40', style: AppTextStyles.caption(context)),
            ],
          ),
          if (patient.riskWeek > 0) ...[
            const SizedBox(height: 18),
            AlertStrip(
              icon: Icons.warning_amber_rounded,
              tone: AlertTone.warning,
              text: 'Elevated risk first detected at week ${patient.riskWeek}, driven by rising blood pressure. Recommend continued twice-weekly monitoring.',
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Patient patient;
  const _HistoryCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final assessments = patient.assessments.reversed.toList();
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
          Text('Assessment history', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 10),
          for (final a in assessments) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${DateFormat('MMM d, y').format(a.date)} · wk ${a.gestationalWeek}',
                      style: AppTextStyles.bodySmall(context, color: AppColors.of(context).ink),
                    ),
                  ),
                  RiskBadge(level: a.riskLevel, percent: a.riskPercent),
                ],
              ),
            ),
            if (a != assessments.last) Divider(height: 1, color: AppColors.of(context).line),
          ],
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final Patient patient;
  const _NotesCard({required this.patient});

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
          Text('Clinical notes', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 12),
          if (patient.notes.isEmpty)
            Text('No notes yet — add one after the next visit.', style: AppTextStyles.bodySmall(context))
          else
            for (final n in patient.notes) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${DateFormat('MMM d, y').format(n.date)} · ${n.author}', style: AppTextStyles.label(context)),
                    const SizedBox(height: 4),
                    Text(n.text, style: AppTextStyles.bodySmall(context, color: AppColors.of(context).ink)),
                  ],
                ),
              ),
              if (n != patient.notes.last) Divider(height: 1, color: AppColors.of(context).line),
            ],
        ],
      ),
    );
  }
}
