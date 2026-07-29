import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_data.dart';
import '../../models/patient.dart';
import '../../models/risk_level.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/patient_tile.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  String _query = '';
  RiskLevel? _filter;

  List<Patient> get _filtered {
    var list = MockData.patients;
    if (_filter != null) {
      list = list.where((p) => p.riskLevel == _filter).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int _countFor(RiskLevel? level) {
    if (level == null) return MockData.patients.length;
    return MockData.patients.where((p) => p.riskLevel == level).length;
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/patients',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(phone: phone, onQueryChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: AppSpacing.md),
          _FilterChips(
            selected: _filter,
            countFor: _countFor,
            onSelected: (level) => setState(() => _filter = level),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          phone ? _PatientCardsList(patients: _filtered) : _PatientsTable(patients: _filtered),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool phone;
  final ValueChanged<String> onQueryChanged;

  const _Header({required this.phone, required this.onQueryChanged});

  Widget _search(BuildContext context) {
    return SizedBox(
      width: 230,
      child: TextField(
        onChanged: onQueryChanged,
        style: AppTextStyles.body(context),
        decoration: InputDecoration(
          hintText: 'Search patients',
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.of(context).inkMute),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: () => context.go('/assess'),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('New assessment'),
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Patients', style: AppTextStyles.screenTitle(context))),
              button,
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: _SearchFull(onQueryChanged: onQueryChanged)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: Text('Patients', style: AppTextStyles.screenTitle(context))),
        _search(context),
        const SizedBox(width: 12),
        button,
      ],
    );
  }
}

class _SearchFull extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  const _SearchFull({required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onQueryChanged,
      style: AppTextStyles.body(context),
      decoration: InputDecoration(
        hintText: 'Search patients',
        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.of(context).inkMute),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final RiskLevel? selected;
  final int Function(RiskLevel?) countFor;
  final ValueChanged<RiskLevel?> onSelected;

  const _FilterChips({required this.selected, required this.countFor, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = <(String, RiskLevel?)>[
      ('All', null),
      ('High risk', RiskLevel.high),
      ('Moderate', RiskLevel.moderate),
      ('Low', RiskLevel.low),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items) ...[
            _Chip(
              label: '${item.$1} (${countFor(item.$2)})',
              active: selected == item.$2,
              onTap: () => onSelected(item.$2),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.of(context).tealPrimary : AppColors.of(context).card,
          border: Border.all(color: active ? AppColors.of(context).tealPrimary : AppColors.of(context).line),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(context, color: active ? Colors.white : AppColors.of(context).inkSoft),
        ),
      ),
    );
  }
}

class _PatientsTable extends StatelessWidget {
  final List<Patient> patients;
  const _PatientsTable({required this.patients});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('PATIENT', style: AppTextStyles.tableHeader(context))),
                Expanded(child: Text('AGE', style: AppTextStyles.tableHeader(context))),
                Expanded(child: Text('GEST. WEEK', style: AppTextStyles.tableHeader(context))),
                Expanded(child: Text('LAST VISIT', style: AppTextStyles.tableHeader(context))),
                Expanded(child: Text('RISK', style: AppTextStyles.tableHeader(context))),
                const SizedBox(width: 72),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.of(context).line),
          if (patients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No patients match this filter.', style: AppTextStyles.bodySmall(context)),
            )
          else
            for (var i = 0; i < patients.length; i++) ...[
              PatientTile(patient: patients[i], onTap: () => context.go('/patients/${patients[i].id}')),
              if (i != patients.length - 1) Divider(height: 1, color: AppColors.of(context).line),
            ],
        ],
      ),
    );
  }
}

class _PatientCardsList extends StatelessWidget {
  final List<Patient> patients;
  const _PatientCardsList({required this.patients});

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text('No patients match this filter.', style: AppTextStyles.bodySmall(context)),
      );
    }
    return Column(
      children: [
        for (final p in patients)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: PatientTile(patient: p, onTap: () => context.go('/patients/${p.id}')),
          ),
      ],
    );
  }
}
