import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/week_ribbon.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.paper,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(phone ? 132 : 84),
        child: Container(
          color: colors.tealDark,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: phone ? 20 : 40, vertical: phone ? 14 : 18),
                  child: _TopNav(phone: phone),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: phone ? 20 : 40, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Hero(phone: phone),
                      SizedBox(height: phone ? 48 : 88),
                      _Features(phone: phone),
                      const SizedBox(height: 56),
                    ],
                  ),
                ),
              ),
            ),
            _Footer(phone: phone),
          ],
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final bool phone;
  const _TopNav({required this.phone});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final logo = Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(Icons.favorite, color: colors.tealPrimary, size: 15),
        ),
        const SizedBox(width: 10),
        Text('MamaPreCare', style: AppTextStyles.logo(context, color: Colors.white)),
      ],
    );

    final loginButton = OutlinedButton(
      onPressed: () => context.go('/login'),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: const Text('Log in'),
    );

    final createAccountButton = ElevatedButton(
      onPressed: () => context.go('/register'),
      child: const Text('Create account'),
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              logo,
              const Spacer(),
              ThemeToggleButton(color: Colors.white.withValues(alpha: 0.85)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: loginButton),
              const SizedBox(width: 10),
              Expanded(child: createAccountButton),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        logo,
        const Spacer(),
        ThemeToggleButton(color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 4),
        loginButton,
        const SizedBox(width: 10),
        createAccountButton,
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final bool phone;
  const _Hero({required this.phone});

  @override
  Widget build(BuildContext context) {
    final text = _HeroText(phone: phone);
    final panel = const _HeroPanel();

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [text, const SizedBox(height: 32), panel],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: text),
          const SizedBox(width: 48),
          Expanded(flex: 5, child: panel),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final bool phone;
  const _HeroText({required this.phone});

  @override
  Widget build(BuildContext context) {
    final headlineSize = phone ? 30.0 : 42.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.of(context).tealLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text('Clinical decision support', style: AppTextStyles.label(context, color: AppColors.of(context).tealPrimary)),
        ),
        const SizedBox(height: 18),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Detect preeclampsia risk ', style: AppTextStyles.heroHeadline(context).copyWith(fontSize: headlineSize)),
              TextSpan(text: 'weeks before', style: AppTextStyles.heroHeadlineItalic(context).copyWith(fontSize: headlineSize)),
              TextSpan(text: ' it becomes an emergency', style: AppTextStyles.heroHeadline(context).copyWith(fontSize: headlineSize)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'MamaPreCare combines routine antenatal measurements with a machine-learning model to flag mothers at risk of preeclampsia so clinics can monitor, refer, and act early.',
          style: AppTextStyles.body(context, color: AppColors.of(context).inkSoft),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(onPressed: () => context.go('/register'), child: const Text('Start free pilot')),
            OutlinedButton(onPressed: () => context.go('/dashboard'), child: const Text('See a demo →')),
          ],
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 40,
          runSpacing: 20,
          children: const [
            _Stat(value: '76,000', caption: 'antenatal visits tracked'),
            _Stat(value: '20+ wks', caption: 'earliest risk detection'),
            _Stat(value: '< 2 min', caption: 'to run a prediction'),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String caption;
  const _Stat({required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.metricNumber(context).copyWith(fontSize: 24)),
        const SizedBox(height: 2),
        Text(caption, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.of(context).tealDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pregnancy timeline · Sample patient', style: AppTextStyles.caption(context, color: Colors.white.withValues(alpha: 0.55))),
          const SizedBox(height: 14),
          const WeekRibbon(currentWeek: 24, riskWeek: 24),
          const SizedBox(height: 10),
          Text('Week 24 · elevated risk detected', style: AppTextStyles.caption(context, color: Colors.white.withValues(alpha: 0.55))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            // This mini result card is always white, regardless of app theme,
            // so its contents are pinned to the light palette for contrast.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Predicted risk', style: AppTextStyles.body(context, color: AppColors.light.ink).copyWith(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.light.riskModerateBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text('Moderate · 42%', style: AppTextStyles.label(context, color: AppColors.light.riskModerate)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: LinearProgressIndicator(
                    value: 0.42,
                    minHeight: 6,
                    backgroundColor: AppColors.light.line,
                    valueColor: AlwaysStoppedAnimation(AppColors.light.riskModerate),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recommend BP monitoring twice weekly and review within 7 days.',
                  style: AppTextStyles.bodySmall(context, color: AppColors.light.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  final bool phone;
  const _Features({required this.phone});

  static const _items = [
    (icon: Icons.query_stats_rounded, title: 'Early ML-driven detection', body: 'Flags elevated preeclampsia risk from routine measurements, often weeks before symptoms appear.'),
    (icon: Icons.timeline_rounded, title: 'Track risk across pregnancy', body: 'Every visit plots onto a clear pregnancy timeline so trends are obvious at a glance.'),
    (icon: Icons.fact_check_outlined, title: 'Built for busy clinics', body: 'Plain-language results and recommended actions midwives can act on immediately.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cards = _items
        .map((item) => _FeatureCard(icon: item.icon, title: item.title, body: item.body))
        .toList();

    if (phone) {
      return Column(
        children: [
          for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureCard({required this.icon, required this.title, required this.body});

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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.of(context).tealWash, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.of(context).tealPrimary, size: 19),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.cardHeading(context)),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool phone;
  const _Footer({required this.phone});

  static const _linkColumns = [
    (
      title: 'Product',
      links: [
        (label: 'Dashboard', route: '/dashboard'),
        (label: 'Patients', route: '/patients'),
        (label: 'Reports', route: '/reports'),
      ],
    ),
    (
      title: 'Company',
      links: [
        (label: 'About', route: null),
        (label: 'Contact', route: null),
        (label: 'Careers', route: null),
      ],
    ),
    (
      title: 'Legal',
      links: [
        (label: 'Privacy policy', route: null),
        (label: 'Terms of service', route: null),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.favorite, color: colors.tealPrimary, size: 14),
            ),
            const SizedBox(width: 10),
            Text('MamaPreCare', style: AppTextStyles.logo(context, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          child: Text(
            'Clinical decision support for antenatal clinics, built to catch preeclampsia risk early.',
            style: AppTextStyles.bodySmall(context, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );

    final linkColumns = phone
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final col in _linkColumns) ...[
                _FooterColumn(title: col.title, links: col.links),
                const SizedBox(height: 28),
              ],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final col in _linkColumns) ...[
                SizedBox(width: 140, child: _FooterColumn(title: col.title, links: col.links)),
                const SizedBox(width: 24),
              ],
            ],
          );

    return Container(
      width: double.infinity,
      color: colors.tealDark,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: phone ? 20 : 40, vertical: phone ? 40 : 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phone)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [brand, const SizedBox(height: 32), linkColumns],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      brand,
                      const Spacer(),
                      linkColumns,
                    ],
                  ),
                SizedBox(height: phone ? 32 : 40),
                Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
                const SizedBox(height: 20),
                Text(
                  '© 2026 MamaPreCare. All rights reserved.',
                  style: AppTextStyles.caption(context, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<({String label, String? route})> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.label(context, color: Colors.white).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: link.route != null
                ? InkWell(
                    onTap: () => context.go(link.route!),
                    child: Text(link.label, style: AppTextStyles.bodySmall(context, color: Colors.white.withValues(alpha: 0.7))),
                  )
                : Text(link.label, style: AppTextStyles.bodySmall(context, color: Colors.white.withValues(alpha: 0.7))),
          ),
      ],
    );
  }
}
