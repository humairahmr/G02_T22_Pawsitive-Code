import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/design_tokens.dart';

class AdminAppShell extends StatelessWidget {
  const AdminAppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _destinations = [
    _DashboardDestination(
      'Dashboard',
      Icons.dashboard_outlined,
      '/admin/dashboard',
    ),
    _DashboardDestination(
      'Booking',
      Icons.calendar_month_outlined,
      '/admin/bookings',
    ),
    _DashboardDestination('Customer', Icons.people_outline, '/admin/customers'),
    _DashboardDestination('Reviews', Icons.star_border, '/admin/reviews'),
    _DashboardDestination('Setting', Icons.tune, '/admin/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final selectedIndex = _destinations.indexWhere(
      (destination) => destination.path == location,
    );
    final selectedDestination = selectedIndex < 0 ? 0 : selectedIndex;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) ...[
              NavigationRail(
                selectedIndex: selectedDestination,
                onDestinationSelected: (index) {
                  context.go(_destinations[index].path);
                },
                labelType: NavigationRailLabelType.all,
                backgroundColor: DesignTokens.background,
                selectedIconTheme: const IconThemeData(
                  color: DesignTokens.background,
                ),
                unselectedIconTheme: const IconThemeData(color: Colors.white70),
                indicatorColor: DesignTokens.studioYellow,
                destinations: [
                  for (final destination in _destinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, color: Color(0xFF303030)),
            ],
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedDestination,
              onDestinationSelected: (index) {
                context.go(_destinations[index].path);
              },
              destinations: [
                for (final destination in _destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }
}

class _DashboardDestination {
  const _DashboardDestination(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
