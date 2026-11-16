import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/design_tokens.dart';

class CustomerAppShell extends StatelessWidget {
  const CustomerAppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _destinations = [
    _CustomerDestination('Home', Icons.home_filled, '/customer/home'),
    _CustomerDestination('Explore', Icons.search, '/customer/explore'),
    _CustomerDestination(
      'Booking',
      Icons.calendar_month_outlined,
      '/customer/booking',
    ),
    _CustomerDestination('Profile', Icons.person_outline, '/customer/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final foundIndex = _destinations.indexWhere(
      (destination) => destination.path == location,
    );
    final selectedIndex = foundIndex < 0 ? 0 : foundIndex;
    final body = Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) ...[
              NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: const IconThemeData(
                  color: DesignTokens.cardText,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: Color(0xFFB0B0B0),
                ),
                selectedLabelTextStyle: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: DesignTokens.cardText),
                unselectedLabelTextStyle: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: const Color(0xFFB0B0B0)),
                onDestinationSelected: (index) {
                  context.go(_destinations[index].path);
                },
                destinations: [
                  for (final destination in _destinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, color: Color(0xFFE6E6E6)),
            ],
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: Colors.transparent,
              selectedIndex: selectedIndex,
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

    return isWide
        ? body
        : NavigationBarTheme(
            data: NavigationBarThemeData(
              iconTheme: WidgetStateProperty.resolveWith((states) {
                return IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? DesignTokens.cardText
                      : const Color(0xFFB0B0B0),
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                return Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: states.contains(WidgetState.selected)
                      ? DesignTokens.cardText
                      : const Color(0xFFB0B0B0),
                );
              }),
            ),
            child: body,
          );
  }
}

class _CustomerDestination {
  const _CustomerDestination(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
