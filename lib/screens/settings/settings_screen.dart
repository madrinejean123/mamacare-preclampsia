import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _highRiskThreshold = '55%';
  String _moderateThreshold = '20%';
  bool _showExplanations = true;

  bool _smsAlerts = true;
  bool _weeklyEmail = false;
  String _language = 'English';

  static const _team = [
    (name: 'Amina Nakato', role: 'Midwife · Admin', initials: 'AN'),
    (name: 'Grace Achieng', role: 'Midwife', initials: 'GA'),
    (name: 'Dr. Robert Ouma', role: 'Obstetrician', initials: 'RO'),
  ];

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final model = _ModelConfigCard(
      highRiskThreshold: _highRiskThreshold,
      moderateThreshold: _moderateThreshold,
      showExplanations: _showExplanations,
      onHighRisk: (v) => setState(() => _highRiskThreshold = v),
      onModerate: (v) => setState(() => _moderateThreshold = v),
      onShowExplanations: (v) => setState(() => _showExplanations = v),
    );
    final clinic = _ClinicAlertsCard(
      smsAlerts: _smsAlerts,
      weeklyEmail: _weeklyEmail,
      language: _language,
      onSms: (v) => setState(() => _smsAlerts = v),
      onWeeklyEmail: (v) => setState(() => _weeklyEmail = v),
      onLanguage: (v) => setState(() => _language = v),
    );

    return AppScaffold(
      currentRoute: '/settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTextStyles.screenTitle(context)),
          const SizedBox(height: AppSpacing.sectionGap),
          if (phone)
            Column(children: [model, const SizedBox(height: AppSpacing.cardGap), clinic])
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: model),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(child: clinic),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.cardGap),
          _TeamCard(team: _team),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SettingsCard({required this.title, required this.rows});

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
          Text(title, style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) Divider(height: 1, color: AppColors.of(context).line),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? caption;
  final Widget control;
  const _SettingsRow({required this.label, this.caption, required this.control});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body(context, color: AppColors.of(context).ink)),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(caption!, style: AppTextStyles.caption(context)),
                ],
              ],
            ),
          ),
          control,
        ],
      ),
    );
  }
}

class _PillToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PillToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.of(context).tealMid : AppColors.of(context).line,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SettingsDropdown({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border.all(color: AppColors.of(context).line),
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.of(context).card,
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.of(context).inkMute, size: 18),
          style: AppTextStyles.body(context),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ModelConfigCard extends StatelessWidget {
  final String highRiskThreshold;
  final String moderateThreshold;
  final bool showExplanations;
  final ValueChanged<String> onHighRisk;
  final ValueChanged<String> onModerate;
  final ValueChanged<bool> onShowExplanations;

  const _ModelConfigCard({
    required this.highRiskThreshold,
    required this.moderateThreshold,
    required this.showExplanations,
    required this.onHighRisk,
    required this.onModerate,
    required this.onShowExplanations,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Model configuration',
      rows: [
        _SettingsRow(
          label: 'High-risk threshold',
          caption: 'Predictions at or above this score are flagged High',
          control: _SettingsDropdown(
            value: highRiskThreshold,
            options: const ['45%', '50%', '55%', '60%'],
            onChanged: onHighRisk,
          ),
        ),
        _SettingsRow(
          label: 'Moderate threshold',
          caption: 'Predictions at or above this score are flagged Moderate',
          control: _SettingsDropdown(
            value: moderateThreshold,
            options: const ['15%', '20%', '25%', '30%'],
            onChanged: onModerate,
          ),
        ),
        _SettingsRow(
          label: 'Show explanations',
          caption: 'Display contributing factors on the result screen',
          control: _PillToggle(value: showExplanations, onChanged: onShowExplanations),
        ),
      ],
    );
  }
}

class _ClinicAlertsCard extends StatelessWidget {
  final bool smsAlerts;
  final bool weeklyEmail;
  final String language;
  final ValueChanged<bool> onSms;
  final ValueChanged<bool> onWeeklyEmail;
  final ValueChanged<String> onLanguage;

  const _ClinicAlertsCard({
    required this.smsAlerts,
    required this.weeklyEmail,
    required this.language,
    required this.onSms,
    required this.onWeeklyEmail,
    required this.onLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.of(context);
    return _SettingsCard(
      title: 'Clinic and alerts',
      rows: [
        _SettingsRow(
          label: 'Dark mode',
          caption: 'Switch the whole app to a low-light color scheme',
          control: _PillToggle(value: themeController.isDark, onChanged: (_) => themeController.toggle()),
        ),
        _SettingsRow(
          label: 'SMS alerts',
          caption: 'Notify staff when a patient is flagged High risk',
          control: _PillToggle(value: smsAlerts, onChanged: onSms),
        ),
        _SettingsRow(
          label: 'Weekly email digest',
          caption: 'Summary of assessments and referrals every Monday',
          control: _PillToggle(value: weeklyEmail, onChanged: onWeeklyEmail),
        ),
        _SettingsRow(
          label: 'Language',
          control: _SettingsDropdown(
            value: language,
            options: const ['English', 'Luganda', 'Swahili'],
            onChanged: onLanguage,
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  final List team;
  const _TeamCard({required this.team});

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
          Text('Team', style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 6),
          for (final m in team) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.of(context).tealLight,
                    child: Text(m.initials, style: AppTextStyles.caption(context, color: AppColors.of(context).tealPrimary).copyWith(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: AppTextStyles.body(context, color: AppColors.of(context).ink).copyWith(fontWeight: FontWeight.w600)),
                        Text(m.role, style: AppTextStyles.caption(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (m != team.last) Divider(height: 1, color: AppColors.of(context).line),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
            label: const Text('Invite team member'),
          ),
        ],
      ),
    );
  }
}
