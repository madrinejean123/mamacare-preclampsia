import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/patient.dart';
import '../../services/patient_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/risk_badge.dart';
import '../../widgets/week_ribbon.dart';

class PatientProfileScreen extends StatefulWidget {
  final String patientId;
  const PatientProfileScreen({super.key, required this.patientId});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late Future<Patient> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = PatientService().fetchPatient(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/patients',
      child: FutureBuilder<Patient>(
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
              text: 'Could not load this patient: ${snapshot.error}',
            );
          }
          final patient = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleRow(patient: patient, phone: phone),
              const SizedBox(height: AppSpacing.sectionGap),
              _MetricsRow(patient: patient, phone: phone),
              const SizedBox(height: AppSpacing.cardGap),
              _TimelineAndHistory(patient: patient, phone: phone),
              const SizedBox(height: AppSpacing.cardGap),
              _NotesCard(patient: patient, onNoteAdded: () => setState(_load)),
            ],
          );
        },
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
    final edd = patient.edd != null ? DateFormat('MMM d, y').format(patient.edd!) : 'Not set';
    final cards = [
      _SmallMetric(label: 'Age', value: '${patient.age}'),
      _SmallMetric(label: 'Gestational week', value: 'Wk ${patient.gestationalWeek}', caption: 'EDD $edd'),
      _SmallMetric(label: 'Gravida / Para', value: 'G${patient.gravida} P${patient.para}'),
      _SmallMetric(
        label: 'Latest BP',
        value: patient.assessments.isEmpty ? 'None yet' : '${patient.systolicBp}/${patient.diastolicBp}',
      ),
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
          if (assessments.isEmpty)
            Text('No assessments yet.', style: AppTextStyles.bodySmall(context, color: AppColors.of(context).inkSoft))
          else
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

class _NotesCard extends StatefulWidget {
  final Patient patient;
  final VoidCallback onNoteAdded;
  const _NotesCard({required this.patient, required this.onNoteAdded});

  @override
  State<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<_NotesCard> {
  final _authorController = TextEditingController();
  final _textController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _authorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_authorController.text.trim().isEmpty || _textController.text.trim().isEmpty) {
      setState(() => _error = 'Author and note text are both required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await PatientService().addNote(
        widget.patient.id,
        author: _authorController.text.trim(),
        text: _textController.text.trim(),
      );
      _authorController.clear();
      _textController.clear();
      widget.onNoteAdded();
    } on PatientApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
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
            Text('No notes yet. Add one after the next visit.', style: AppTextStyles.bodySmall(context))
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
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.of(context).line),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: TextField(controller: _authorController, decoration: const InputDecoration(labelText: 'Your name'))),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: TextField(controller: _textController, decoration: const InputDecoration(labelText: 'Add a note'))),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add'),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: AppColors.of(context).riskHigh)),
          ],
        ],
      ),
    );
  }
}
