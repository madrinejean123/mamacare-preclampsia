import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';
import 'theme_toggle_button.dart';

Future<void> _logout(BuildContext context) async {
  await AuthService.instance.logout();
  if (context.mounted) context.go('/');
}

class NavDestinationSpec {
  final String label;
  final IconData icon;
  final String route;

  const NavDestinationSpec({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const _clinicSection = [
  NavDestinationSpec(label: 'Dashboard', icon: Icons.grid_view_rounded, route: '/dashboard'),
  NavDestinationSpec(label: 'Patients', icon: Icons.people_alt_outlined, route: '/patients'),
  NavDestinationSpec(label: 'New assessment', icon: Icons.add_circle_outline, route: '/assess'),
];

const _insightsSection = [
  NavDestinationSpec(label: 'Trends', icon: Icons.show_chart_rounded, route: '/trends'),
  NavDestinationSpec(label: 'Reports', icon: Icons.description_outlined, route: '/reports'),
];

const _manageSection = [
  NavDestinationSpec(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
];

const _allDestinations = [..._clinicSection, ..._insightsSection, ..._manageSection];

/// Shell that switches between a fixed web sidebar, a tablet NavigationRail,
/// and a phone bottom nav bar depending on breakpoint. Wrap every
/// authenticated screen's body in this.
class AppScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  final String clinicName;

  const AppScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
    this.clinicName = 'Mulago Antenatal Clinic',
  });

  int get _selectedIndex {
    final i = _allDestinations.indexWhere((d) => d.route == currentRoute);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final screenClass = screenClassOf(context);
    final colors = AppColors.of(context);

    if (screenClass == ScreenClass.web) {
      return Scaffold(
        backgroundColor: colors.paper,
        body: Row(
          children: [
            _Sidebar(currentRoute: currentRoute, clinicName: clinicName),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (screenClass == ScreenClass.tablet) {
      return Scaffold(
        backgroundColor: colors.paper,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: colors.tealDark,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => context.go(_allDestinations[i].route),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.55)),
              selectedLabelTextStyle: AppTextStyles.label(context, color: Colors.white),
              unselectedLabelTextStyle: AppTextStyles.label(context, color: Colors.white.withValues(alpha: 0.55)),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.favorite, color: colors.tealPrimary, size: 16),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        ThemeToggleButton(color: Colors.white.withValues(alpha: 0.75)),
                        IconButton(
                          tooltip: 'Log out',
                          onPressed: () => _logout(context),
                          icon: Icon(Icons.logout_rounded, color: Colors.white.withValues(alpha: 0.75), size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: _allDestinations
                  .map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)))
                  .toList(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    // Phone
    final navItems = [
      _clinicSection[0],
      _clinicSection[1],
      _clinicSection[2],
      _insightsSection[0],
      _manageSection[0],
    ];
    final navIndex = navItems.indexWhere((d) => d.route == currentRoute);

    return Scaffold(
      backgroundColor: colors.paper,
      appBar: AppBar(
        backgroundColor: colors.tealDark,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.favorite, color: colors.tealPrimary, size: 14),
            ),
            const SizedBox(width: 8),
            Text('MamaSafe', style: AppTextStyles.logo(context, color: Colors.white).copyWith(fontSize: 17)),
          ],
        ),
        actions: [
          ThemeToggleButton(color: Colors.white.withValues(alpha: 0.85)),
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout_rounded, color: Colors.white.withValues(alpha: 0.85), size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.tealDark,
          surfaceTintColor: Colors.transparent,
          indicatorColor: colors.tealPrimary,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return AppTextStyles.caption(context, color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6))
                .copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w500);
          }),
        ),
        child: NavigationBar(
          selectedIndex: navIndex < 0 ? 0 : navIndex,
          onDestinationSelected: (i) => context.go(navItems[i].route),
          destinations: navItems
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    label: d.label == 'New assessment' ? 'Assess' : (d.label == 'Settings' ? 'More' : d.label),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentRoute;
  final String clinicName;

  const _Sidebar({required this.currentRoute, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppColors.of(context).tealDark,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.favorite, color: AppColors.of(context).tealPrimary, size: 16),
              ),
              const SizedBox(width: 10),
              Text('MamaSafe', style: AppTextStyles.logo(context, color: Colors.white)),
              const Spacer(),
              ThemeToggleButton(color: Colors.white.withValues(alpha: 0.75)),
            ],
          ),
          const SizedBox(height: 30),
          _SectionLabel('Clinic'),
          const SizedBox(height: 6),
          ..._clinicSection.map((d) => _SidebarItem(spec: d, selected: d.route == currentRoute)),
          const SizedBox(height: 22),
          _SectionLabel('Insights'),
          const SizedBox(height: 6),
          ..._insightsSection.map((d) => _SidebarItem(spec: d, selected: d.route == currentRoute)),
          const SizedBox(height: 22),
          _SectionLabel('Manage'),
          const SizedBox(height: 6),
          ..._manageSection.map((d) => _SidebarItem(spec: d, selected: d.route == currentRoute)),
          const Spacer(),
          InkWell(
            onTap: () => _logout(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 10),
                  Text('Log out', style: AppTextStyles.body(context, color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.tableHeader(context, color: Colors.white.withValues(alpha: 0.45)),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavDestinationSpec spec;
  final bool selected;

  const _SidebarItem({required this.spec, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(spec.route),
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.of(context).tealPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            ),
            child: Row(
              children: [
                Icon(spec.icon, size: 18, color: selected ? Colors.white : Colors.white.withValues(alpha: 0.75)),
                const SizedBox(width: 10),
                Text(
                  spec.label,
                  style: AppTextStyles.body(context, color: selected ? Colors.white : Colors.white.withValues(alpha: 0.75))
                      .copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
