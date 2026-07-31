import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/alert_strip.dart';
import 'auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _role = 'Midwife';
  String _facilityLevel = 'Health Centre IV';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final name = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
    try {
      await AuthService.instance.register(
        name: name,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.go('/dashboard');
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
          Text('Set up MamaPreCare for your antenatal clinic.', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: 24),
          _FieldPair(
            phone: phone,
            left: AuthField(label: 'First name', hint: 'Amina', controller: _firstNameController),
            right: AuthField(label: 'Last name', hint: 'Nakato', controller: _lastNameController),
          ),
          const SizedBox(height: 16),
          AuthField(
            label: 'Work email',
            hint: 'you@clinic.org',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
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
          AuthField(label: 'Password', hint: 'Create a password', controller: _passwordController, obscure: true),
          if (_error != null) ...[
            const SizedBox(height: 16),
            AlertStrip(icon: Icons.error_outline_rounded, tone: AlertTone.danger, text: _error!),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create account'),
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
