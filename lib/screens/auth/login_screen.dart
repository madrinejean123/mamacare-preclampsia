import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

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
          const AuthField(label: 'Email', hint: 'you@clinic.org', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          const AuthField(label: 'Password', hint: '••••••••', obscure: true),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.of(context).tealPrimary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Remember me', style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Forgot password?')),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Log in'),
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
