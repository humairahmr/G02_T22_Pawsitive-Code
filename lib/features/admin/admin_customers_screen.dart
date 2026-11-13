import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

enum CustomerBookingFilter { all, upcoming, unpaid, past }

@immutable
class CustomerBooking {
  const CustomerBooking({
    required this.customerName,
    required this.sessionType,
    required this.bookingDate,
    required this.isUpcoming,
    required this.isPaid,
  });

  final String customerName;
  final String sessionType;
  final String bookingDate;
  final bool isUpcoming;
  final bool isPaid;
}

const sampleCustomerBookings = [
  CustomerBooking(
    customerName: 'Dayang',
    sessionType: 'Wedding Photo',
    bookingDate: '30 August 2026',
    isUpcoming: true,
    isPaid: true,
  ),
  CustomerBooking(
    customerName: 'Fong',
    sessionType: 'Wedding Photo',
    bookingDate: '30 August 2026',
    isUpcoming: true,
    isPaid: false,
  ),
  CustomerBooking(
    customerName: 'Ros',
    sessionType: 'Wedding Photo',
    bookingDate: '30 August 2026',
    isUpcoming: false,
    isPaid: true,
  ),
];

class AdminCustomerScreen extends StatefulWidget {
  const AdminCustomerScreen({
    super.key,
    this.bookings = sampleCustomerBookings,
    this.onBack,
    this.onBookingSelected,
  });

  final List<CustomerBooking> bookings;
  final VoidCallback? onBack;
  final ValueChanged<CustomerBooking>? onBookingSelected;

  @override
  State<AdminCustomerScreen> createState() => _AdminCustomerScreenState();
}

class _AdminCustomerScreenState extends State<AdminCustomerScreen> {
  final _searchController = TextEditingController();
  CustomerBookingFilter _selectedFilter = CustomerBookingFilter.all;
  String _searchQuery = '';

  static const _filters = [
    (CustomerBookingFilter.all, 'ALL'),
    (CustomerBookingFilter.upcoming, 'Upcoming'),
    (CustomerBookingFilter.unpaid, 'Unpaid'),
    (CustomerBookingFilter.past, 'Past'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _visibleBookings;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Customer',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 28),
                _SearchBar(
                  controller: _searchController,
                  fallbackLocation: '/admin/dashboard',
                  onBack: widget.onBack,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final (filter, label) in _filters) ...[
                        _FilterChip(
                          label: label,
                          selected: _selectedFilter == filter,
                          onSelected: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                        if (filter != CustomerBookingFilter.past)
                          const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _CustomerBookingsCard(
                  bookings: bookings,
                  onBookingSelected: widget.onBookingSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<CustomerBooking> get _visibleBookings {
    final query = _searchQuery.trim().toLowerCase();
    return widget.bookings.where((booking) {
      final matchesFilter = switch (_selectedFilter) {
        CustomerBookingFilter.all => true,
        CustomerBookingFilter.upcoming => booking.isUpcoming,
        CustomerBookingFilter.unpaid => !booking.isPaid,
        CustomerBookingFilter.past => !booking.isUpcoming,
      };
      final searchableText =
          '${booking.customerName} ${booking.sessionType} ${booking.bookingDate}'
              .toLowerCase();
      return matchesFilter && searchableText.contains(query);
    }).toList();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.fallbackLocation,
    required this.onBack,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String fallbackLocation;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            AppBackButton(
              fallbackLocation: fallbackLocation,
              onPressed: onBack,
              icon: Icons.arrow_back,
              color: const Color(0xFF4A4650),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DesignTokens.cardText,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A4650),
                  ),
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
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? DesignTokens.studioYellow : const Color(0xFF48453F),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? DesignTokens.cardText : Colors.white,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerBookingsCard extends StatelessWidget {
  const _CustomerBookingsCard({
    required this.bookings,
    required this.onBookingSelected,
  });

  final List<CustomerBooking> bookings;
  final ValueChanged<CustomerBooking>? onBookingSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: bookings.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No customers found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.cardText,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                for (var index = 0; index < bookings.length; index++) ...[
                  _CustomerBookingRow(
                    booking: bookings[index],
                    onTap: onBookingSelected == null
                        ? null
                        : () => onBookingSelected!(bookings[index]),
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: DesignTokens.studioYellow,
                  ),
                ],
              ],
            ),
    );
  }
}

class _CustomerBookingRow extends StatelessWidget {
  const _CustomerBookingRow({required this.booking, required this.onTap});

  final CustomerBooking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.customerName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DesignTokens.cardText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${booking.sessionType} - ${booking.bookingDate}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF858585),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
