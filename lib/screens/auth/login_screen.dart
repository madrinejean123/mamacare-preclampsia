import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/alert_strip.dart';
import 'auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.instance.login(
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
    return AuthShell(
      maxWidth: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back', style: AppTextStyles.screenTitle(context).copyWith(fontSize: 26)),
          const SizedBox(height: 6),
          Text('Log in to your clinic workspace.', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: 24),
          AuthField(
            label: 'Email',
            hint: 'you@clinic.org',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthField(label: 'Password', hint: '••••••••', controller: _passwordController, obscure: true),
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
                  : const Text('Log in'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              children: [
                Text("Don't have an account? ", style: AppTextStyles.bodySmall(context)),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Create one'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
