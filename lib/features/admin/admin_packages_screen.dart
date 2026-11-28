import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';
import 'models/payment_review.dart' show formatRm;
import 'models/studio_package.dart';

class AdminPackagesScreen extends StatefulWidget {
  const AdminPackagesScreen({super.key, this.store, this.onAdd, this.onEdit});

  final PackageStore? store;
  final VoidCallback? onAdd;
  final ValueChanged<StudioPackage>? onEdit;

  @override
  State<AdminPackagesScreen> createState() => _AdminPackagesScreenState();
}

class _AdminPackagesScreenState extends State<AdminPackagesScreen> {
  PackageCategory? _filter;

  PackageStore get _store => widget.store ?? packageStore;

  static const _filters = <(PackageCategory?, String)>[
    (null, 'All'),
    (PackageCategory.wedding, 'Wedding'),
    (PackageCategory.maternity, 'Maternity'),
    (PackageCategory.preWed, 'Pre-Wed'),
    (PackageCategory.graduation, 'Graduation'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final items = _store.packages
            .where((p) => _filter == null || p.category == _filter)
            .toList();

        return Scaffold(
          backgroundColor: DesignTokens.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const ScreenHeader(
                            title: 'Packages',
                            fallbackLocation: '/admin/settings',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (final (value, label) in _filters) ...[
                                  _Chip(
                                    label: label,
                                    selected: _filter == value,
                                    onTap: () =>
                                        setState(() => _filter = value),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (items.isEmpty)
                            const Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'No packages in this category yet.',
                                  style: TextStyle(
                                    color: DesignTokens.cardText,
                                  ),
                                ),
                              ),
                            )
                          else
                            for (final p in items)
                              _PackageCard(
                                package: p,
                                onTap: () => widget.onEdit?.call(p),
                                onVisibleChanged: (v) =>
                                    _store.setVisible(p.id, v),
                              ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: widget.onAdd,
                          style: FilledButton.styleFrom(
                            backgroundColor: DesignTokens.studioYellow,
                            foregroundColor: DesignTokens.cardText,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Add package',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      color: selected ? DesignTokens.studioYellow : const Color(0xFF48453F),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? DesignTokens.cardText : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.onTap,
    required this.onVisibleChanged,
  });

  final StudioPackage package;
  final VoidCallback onTap;
  final ValueChanged<bool> onVisibleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4640),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(
                        color: DesignTokens.cardText,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      '${formatRm(package.price)} · '
                      '${formatHours(package.durationHours)} hr',
                      style: const TextStyle(color: Color(0xFF858585)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        package.category.label,
                        style: const TextStyle(
                          color: DesignTokens.cardText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch.adaptive(
                    value: package.visible,
                    onChanged: onVisibleChanged,
                    activeTrackColor: DesignTokens.studioYellow,
                    activeThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFD9D9D9),
                    inactiveThumbColor: Colors.white,
                  ),
                  Text(
                    package.visible ? 'Visible' : 'Hidden',
                    style: const TextStyle(
                      color: Color(0xFF858585),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
