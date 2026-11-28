import 'package:flutter/foundation.dart';

enum PackageCategory { wedding, maternity, preWed, graduation }

extension PackageCategoryLabel on PackageCategory {
  String get label {
    switch (this) {
      case PackageCategory.wedding:
        return 'Wedding';
      case PackageCategory.maternity:
        return 'Maternity';
      case PackageCategory.preWed:
        return 'Pre-Wed';
      case PackageCategory.graduation:
        return 'Graduation';
    }
  }
}

String formatHours(double hours) =>
    hours == hours.roundToDouble() ? '${hours.round()}' : '$hours';

@immutable
class StudioPackage {
  const StudioPackage({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationHours,
    required this.description,
    required this.included,
    required this.visible,
  });

  final String id;
  final String name;
  final PackageCategory category;
  final double price;
  final double durationHours;
  final String description;
  final List<String> included;
  final bool visible;

  StudioPackage copyWith({
    String? name,
    PackageCategory? category,
    double? price,
    double? durationHours,
    String? description,
    List<String>? included,
    bool? visible,
  }) {
    return StudioPackage(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      durationHours: durationHours ?? this.durationHours,
      description: description ?? this.description,
      included: included ?? this.included,
      visible: visible ?? this.visible,
    );
  }
}

const samplePackages = <StudioPackage>[
  StudioPackage(
    id: 'wedding-classic',
    name: 'Wedding Classic',
    category: PackageCategory.wedding,
    price: 1200,
    durationHours: 2,
    description:
        'A timeless wedding package covering your ceremony, couple '
        'portraits and family moments.',
    included: [
      '2 hours of coverage',
      '80 edited photos',
      'Online gallery for 6 months',
    ],
    visible: true,
  ),
  StudioPackage(
    id: 'maternity-glow',
    name: 'Maternity Glow',
    category: PackageCategory.maternity,
    price: 650,
    durationHours: 1.5,
    description: 'A soft, natural maternity session in studio or outdoors.',
    included: ['1.5 hours of coverage', '40 edited photos'],
    visible: true,
  ),
  StudioPackage(
    id: 'pre-wed-story',
    name: 'Pre-Wed Story',
    category: PackageCategory.preWed,
    price: 900,
    durationHours: 2,
    description: 'Tell your story together before the big day.',
    included: ['2 hours of coverage', '60 edited photos'],
    visible: true,
  ),
  StudioPackage(
    id: 'graduation-day',
    name: 'Graduation Day',
    category: PackageCategory.graduation,
    price: 450,
    durationHours: 1,
    description: 'Capture your convocation day.',
    included: ['1 hour of coverage', '30 edited photos'],
    visible: false,
  ),
];

/// Holds packages in memory. Replace with real backend calls later.
class PackageStore extends ChangeNotifier {
  PackageStore([List<StudioPackage>? initial])
    : _packages = List.of(initial ?? samplePackages);

  final List<StudioPackage> _packages;

  List<StudioPackage> get packages => List.unmodifiable(_packages);

  StudioPackage? byId(String id) {
    for (final p in _packages) {
      if (p.id == id) return p;
    }
    return null;
  }

  String nextId() => 'pkg-${DateTime.now().microsecondsSinceEpoch}';

  void add(StudioPackage package) {
    _packages.add(package);
    notifyListeners();
  }

  void update(StudioPackage package) {
    final i = _packages.indexWhere((p) => p.id == package.id);
    if (i == -1) return;
    _packages[i] = package;
    notifyListeners();
  }

  void setVisible(String id, bool visible) {
    final p = byId(id);
    if (p != null) update(p.copyWith(visible: visible));
  }
}

final packageStore = PackageStore();
