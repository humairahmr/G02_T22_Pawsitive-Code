import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

@immutable
class _ExploreStyle {
  const _ExploreStyle(this.title, this.category, this.icon, this.colors);

  final String title;
  final String category;
  final IconData icon;
  final List<Color> colors;
}

class CustomerExploreScreen extends StatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  State<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends State<CustomerExploreScreen> {
  static const _filters = ['ALL', 'Wedding', 'Event', 'Graduation'];
  static const _styles = [
    _ExploreStyle('Golden hour', 'Wedding', Icons.favorite_outline, [
      Color(0xFFBE9277),
      Color(0xFF574139),
    ]),
    _ExploreStyle('The big day', 'Wedding', Icons.camera_alt_outlined, [
      Color(0xFF879078),
      Color(0xFF3E4B3D),
    ]),
    _ExploreStyle('Celebrate together', 'Event', Icons.celebration_outlined, [
      Color(0xFF81728F),
      Color(0xFF43394E),
    ]),
    _ExploreStyle('A new chapter', 'Graduation', Icons.school_outlined, [
      Color(0xFF7794A0),
      Color(0xFF394E59),
    ]),
    _ExploreStyle('Quiet moments', 'Event', Icons.auto_awesome_outlined, [
      Color(0xFF9A8870),
      Color(0xFF51473C),
    ]),
    _ExploreStyle('Classic portrait', 'Wedding', Icons.portrait_outlined, [
      Color(0xFF92727A),
      Color(0xFF4C3940),
    ]),
  ];

  final _searchController = TextEditingController();
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleStyles = _styles.where((style) {
      final matchesFilter =
          _selectedFilter == 'ALL' || style.category == _selectedFilter;
      final matchesQuery = style.title.toLowerCase().contains(
        _searchQuery.trim().toLowerCase(),
      );
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
              children: [
                Text(
                  'Explore',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 36),
                ),
                Text(
                  'Find your style with us!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 28),
                _ExploreSearchBar(
                  controller: _searchController,
                  fallbackLocation: '/customer/home',
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final filter in _filters)
                      _ExploreFilterChip(
                        label: filter,
                        selected: _selectedFilter == filter,
                        onTap: () => setState(() => _selectedFilter = filter),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                if (visibleStyles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No styles match your search.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columnCount = constraints.maxWidth >= 900 ? 4 : 2;
                      final columns = List.generate(
                        columnCount,
                        (_) => <Widget>[],
                      );
                      for (
                        var index = 0;
                        index < visibleStyles.length;
                        index++
                      ) {
                        final style = visibleStyles[index];
                        columns[index % columnCount].add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ExploreStyleCard(
                              style: style,
                              height: index.isEven ? 260 : 200,
                              onTap: () => context.go(
                                '/customer/booking?category=${Uri.encodeQueryComponent(style.category)}',
                              ),
                            ),
                          ),
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var index = 0; index < columns.length; index++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == columns.length - 1 ? 0 : 14,
                                ),
                                child: Column(children: columns[index]),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreSearchBar extends StatelessWidget {
  const _ExploreSearchBar({
    required this.controller,
    required this.fallbackLocation,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String fallbackLocation;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            const SizedBox(width: 18),
            AppBackButton(
              fallbackLocation: fallbackLocation,
              icon: Icons.arrow_back,
              color: const Color(0xFF4A4650),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: DesignTokens.cardText),
                decoration: InputDecoration(
                  hintText: 'Search style, packages',
                  hintStyle: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF4A4650)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              onPressed: onClear,
              tooltip: 'Clear search',
              icon: const Icon(Icons.close, color: Color(0xFF4A4650)),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _ExploreFilterChip extends StatelessWidget {
  const _ExploreFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DesignTokens.studioYellow : Colors.white,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: DesignTokens.cardText, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }
}

class _ExploreStyleCard extends StatelessWidget {
  const _ExploreStyleCard({
    required this.style,
    required this.height,
    required this.onTap,
  });

  final _ExploreStyle style;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: style.colors.last,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: style.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 18,
                right: 10,
                child: Icon(
                  style.icon,
                  size: height * 0.52,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              Positioned(
                left: 14,
                right: 12,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      style.category,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
