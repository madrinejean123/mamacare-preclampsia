import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import 'auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _role = 'Midwife';
  String _facilityLevel = 'Health Centre IV';

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return AuthShell(
      maxWidth: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create your account', style: AppTextStyles.screenTitle(context).copyWith(fontSize: 26)),
          const SizedBox(height: 6),
          Text('Set up MamaSafe for your antenatal clinic.', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: 24),
          _FieldPair(
            phone: phone,
            left: const AuthField(label: 'First name', hint: 'Amina'),
            right: const AuthField(label: 'Last name', hint: 'Nakato'),
          ),
          const SizedBox(height: 16),
          const AuthField(label: 'Work email', hint: 'you@clinic.org', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          const AuthField(label: 'Facility name', hint: 'Mulago Antenatal Clinic'),
          const SizedBox(height: 16),
          _FieldPair(
            phone: phone,
            left: _Dropdown(
              label: 'Role',
              value: _role,
              options: const ['Midwife', 'Nurse', 'Obstetrician', 'Clinic admin'],
              onChanged: (v) => setState(() => _role = v),
            ),
            right: _Dropdown(
              label: 'Facility level',
              value: _facilityLevel,
              options: const ['Health Centre III', 'Health Centre IV', 'General Hospital', 'National Referral Hospital'],
              onChanged: (v) => setState(() => _facilityLevel = v),
            ),
          ),
          const SizedBox(height: 16),
          const AuthField(label: 'Password', hint: 'Create a password', obscure: true),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Create account'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              children: [
                Text('Already have an account? ', style: AppTextStyles.bodySmall(context)),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Log in'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldPair extends StatelessWidget {
  final bool phone;
  final Widget left;
  final Widget right;

  const _FieldPair({required this.phone, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    if (phone) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(context)),
        const SizedBox(height: 6),
        Container(
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
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.of(context).inkMute),
              style: AppTextStyles.body(context),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
