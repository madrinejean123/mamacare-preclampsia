import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/theme_toggle_button.dart';

/// Shared centered-card layout used by Login and Register.
class AuthShell extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const AuthShell({super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).paper,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: phone ? 20 : 24, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: phone ? double.infinity : maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text('Back to home'),
                        ),
                        const Spacer(),
                        ThemeToggleButton(color: AppColors.of(context).inkSoft),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => context.go('/'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(color: AppColors.of(context).tealPrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 15),
                          ),
                          const SizedBox(width: 10),
                          Text('MamaSafe', style: AppTextStyles.logo(context)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).card,
                        border: Border.all(color: AppColors.of(context).line),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;

  const AuthField({
    super.key,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(context)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          keyboardType: keyboardType,
          style: AppTextStyles.body(context),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
