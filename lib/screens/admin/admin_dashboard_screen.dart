import 'package:flutter/material.dart';

import '../../models/patient.dart';
import '../../models/staff_user.dart';
import '../../models/stats.dart';
import '../../services/patient_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = PatientService();
  late Future<(List<StaffUser>, ClinicStats)> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = (_service.fetchStaff(), _service.fetchStats()).wait;
  }

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AppScaffold(
      currentRoute: '/admin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin', style: AppTextStyles.screenTitle(context)),
          const SizedBox(height: 4),
          Text('Manage clinic staff and patient portal access.', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: AppSpacing.sectionGap),
          FutureBuilder<(List<StaffUser>, ClinicStats)>(
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
                  text: 'Could not load admin data: ${snapshot.error}',
                );
              }
              final (staff, stats) = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricsRow(phone: phone, stats: stats, staffCount: staff.length),
                  const SizedBox(height: AppSpacing.cardGap),
                  _StaffCard(staff: staff, onChanged: () => setState(_load)),
                  const SizedBox(height: AppSpacing.cardGap),
                  const _PatientLoginCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final bool phone;
  final ClinicStats stats;
  final int staffCount;
  const _MetricsRow({required this.phone, required this.stats, required this.staffCount});

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(label: 'Staff accounts', value: '$staffCount'),
      MetricCard(label: 'Active patients', value: '${stats.activePatients}'),
      MetricCard(label: 'Assessments run', value: '${stats.totalAssessments}'),
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

class _StaffCard extends StatelessWidget {
  final List<StaffUser> staff;
  final VoidCallback onChanged;
  const _StaffCard({required this.staff, required this.onChanged});

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
          Row(
            children: [
              Expanded(child: Text('Staff', style: AppTextStyles.cardHeading(context))),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _AddStaffDialog(onAdded: onChanged),
                ),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text('Add doctor / staff'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (staff.isEmpty)
            Text('No staff accounts yet.', style: AppTextStyles.bodySmall(context, color: AppColors.of(context).inkSoft))
          else
            for (final u in staff) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name, style: AppTextStyles.body(context, color: AppColors.of(context).ink).copyWith(fontWeight: FontWeight.w600)),
                          Text(u.email, style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: u.role == 'admin' ? AppColors.of(context).tealWash : AppColors.of(context).paper,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        border: Border.all(color: AppColors.of(context).line),
                      ),
                      child: Text(
                        u.role == 'admin' ? 'Admin' : 'Clinician',
                        style: AppTextStyles.caption(context, color: u.role == 'admin' ? AppColors.of(context).tealPrimary : AppColors.of(context).inkSoft),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Remove',
                      icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.of(context).riskHigh),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Remove staff account?'),
                            content: Text('${u.name} will no longer be able to log in.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remove')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          try {
                            await PatientService().deleteStaff(u.id);
                            onChanged();
                          } on PatientApiException catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (u != staff.last) Divider(height: 1, color: AppColors.of(context).line),
            ],
        ],
      ),
    );
  }
}

class _AddStaffDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddStaffDialog({required this.onAdded});

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'clinician';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Name, email, and password are all required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await PatientService().createStaff(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
      );
      widget.onAdded();
      if (mounted) Navigator.of(context).pop();
    } on PatientApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add doctor / staff'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Work email')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Temporary password')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'clinician', child: Text('Clinician (doctor / midwife / nurse)')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'clinician'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}

class _PatientLoginCard extends StatefulWidget {
  const _PatientLoginCard();

  @override
  State<_PatientLoginCard> createState() => _PatientLoginCardState();
}

class _PatientLoginCardState extends State<_PatientLoginCard> {
  late Future<List<Patient>> _patientsFuture;
  String? _selectedPatientId;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService().fetchPatients();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedPatientId == null || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Select a patient and fill in both fields.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _successMessage = null;
    });
    try {
      await PatientService().createPatientLogin(
        _selectedPatientId!,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      setState(() {
        _successMessage = 'Portal login created. Share these credentials with the patient directly. '
            'They are not shown again after you leave this page.';
      });
      _emailController.clear();
      _passwordController.clear();
    } on PatientApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
          Text('Create patient portal access', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 4),
          Text(
            'Gives a patient her own read-only login to view her vitals and status. Not her clinical notes or risk score.',
            style: AppTextStyles.caption(context),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<Patient>>(
            future: _patientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Could not load patients: ${snapshot.error}', style: AppTextStyles.bodySmall(context));
              }
              final patients = snapshot.data!;
              return DropdownButtonFormField<String>(
                initialValue: _selectedPatientId,
                decoration: const InputDecoration(labelText: 'Patient'),
                items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (v) => setState(() => _selectedPatientId = v),
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Login email')),
          const SizedBox(height: 12),
          TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Temporary password')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 12),
            AlertStrip(icon: Icons.check_circle_outline_rounded, text: _successMessage!),
          ],
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create login'),
          ),
        ],
      ),
    );
  }
}
