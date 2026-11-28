import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';
import 'models/payment_review.dart';

enum BookingStatus {
  pendingVerification,
  confirmed,
  unpaid,
  rejected,
  cancelled,
}

@immutable
class AdminBooking {
  const AdminBooking({
    required this.customerName,
    required this.sessionType,
    required this.status,
    required this.dateTime,
    required this.method,
    required this.sortKey,
    this.ref = 'BBS-261212-014',
  });

  final String customerName;
  final String sessionType;
  final BookingStatus status;
  final String dateTime;
  final PaymentMethod method;
  final String ref;

  /// yyyymmddNN, used only for "Sort: Newest / Oldest".
  final int sortKey;

  /// Converts this booking into the data the booking detail screen needs.
  PaymentReview toPaymentReview() {
    late final PaymentStatus paymentStatus;
    switch (status) {
      case BookingStatus.pendingVerification:
        paymentStatus = PaymentStatus.pendingVerification;
      case BookingStatus.confirmed:
        paymentStatus = PaymentStatus.paid;
      case BookingStatus.rejected:
        paymentStatus = PaymentStatus.rejected;
      case BookingStatus.unpaid:
      case BookingStatus.cancelled:
        paymentStatus = PaymentStatus.unpaid;
    }
    return PaymentReview(
      bookingRef: ref,
      customerName: customerName,
      email: 'xxxxx@gmail.com',
      method: method,
      amount: 1400,
      status: paymentStatus,
      receiptUploadedAt: method == PaymentMethod.qrCode
          ? DateTime(2026, 11, 24, 15, 42)
          : null,
    );
  }
}

const sampleAdminBookings = [
  AdminBooking(
    customerName: 'Fong',
    sessionType: 'Wedding Photo',
    status: BookingStatus.pendingVerification,
    dateTime: '30 August 2026 · 10:00 AM',
    method: PaymentMethod.qrCode,
    sortKey: 2026083001,
  ),
  AdminBooking(
    customerName: 'Dayang',
    sessionType: 'Wedding Photo',
    status: BookingStatus.confirmed,
    dateTime: '26 August 2026 · 10:00 AM',
    method: PaymentMethod.qrCode,
    sortKey: 2026082603,
  ),
  AdminBooking(
    customerName: 'Umang',
    sessionType: 'Wedding Photo',
    status: BookingStatus.unpaid,
    dateTime: '26 August 2026 · 10:00 AM',
    method: PaymentMethod.cash,
    sortKey: 2026082602,
  ),
  AdminBooking(
    customerName: 'Ros',
    sessionType: 'Wedding Photo',
    status: BookingStatus.rejected,
    dateTime: '26 August 2026 · 10:00 AM',
    method: PaymentMethod.cash,
    sortKey: 2026082601,
  ),
];

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({
    super.key,
    this.bookings = sampleAdminBookings,
    this.totalCount,
    this.onBookingSelected,
  });

  final List<AdminBooking> bookings;

  /// Total bookings in the system (for "Showing x of y"). Defaults to the
  /// length of [bookings].
  final int? totalCount;
  final ValueChanged<AdminBooking>? onBookingSelected;

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final _searchController = TextEditingController();
  BookingStatus? _status;
  PaymentMethod? _method;
  bool _newestFirst = true;

  static const _statusFilters = [
    (null, 'All'),
    (BookingStatus.pendingVerification, 'Pending verification'),
    (BookingStatus.unpaid, 'Unpaid'),
    (BookingStatus.rejected, 'Rejected'),
    (BookingStatus.cancelled, 'Cancelled'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminBooking> get _visible {
    final query = _searchController.text.trim().toLowerCase();
    final list = widget.bookings.where((b) {
      if (_status != null && b.status != _status) return false;
      if (_method != null && b.method != _method) return false;
      if (query.isNotEmpty &&
          !b.customerName.toLowerCase().contains(query) &&
          !b.ref.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
    list.sort(
      (a, b) => _newestFirst
          ? b.sortKey.compareTo(a.sortKey)
          : a.sortKey.compareTo(b.sortKey),
    );
    return list;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _status = null;
      _method = null;
      _newestFirst = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final total = widget.totalCount ?? widget.bookings.length;

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
                const ScreenHeader(
                  title: 'Booking',
                  fallbackLocation: '/admin/dashboard',
                ),
                const SizedBox(height: 24),
                _SearchField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onClear: () => setState(_searchController.clear),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final (status, label) in _statusFilters) ...[
                        _FilterChip(
                          label: label,
                          selected: _status == status,
                          onSelected: () => setState(() => _status = status),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownBox<PaymentMethod?>(
                        value: _method,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Method: All'),
                          ),
                          DropdownMenuItem(
                            value: PaymentMethod.cash,
                            child: Text('Method: Cash'),
                          ),
                          DropdownMenuItem(
                            value: PaymentMethod.qrCode,
                            child: Text('Method: QR Code'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _method = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownBox<bool>(
                        value: _newestFirst,
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Sort: Newest'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Sort: Oldest'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _newestFirst = v ?? true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: 'Reset filters',
                      child: Material(
                        color: DesignTokens.studioYellow,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _resetFilters,
                          borderRadius: BorderRadius.circular(16),
                          child: const SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.filter_alt_outlined,
                              color: DesignTokens.cardText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Showing ${visible.length} of $total bookings',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  const Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No bookings match your filters.',
                        style: TextStyle(color: DesignTokens.cardText),
                      ),
                    ),
                  )
                else
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (var i = 0; i < visible.length; i++)
                            _BookingListItem(
                              booking: visible[i],
                              onSelected: widget.onBookingSelected,
                              showDivider: i < visible.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: DesignTokens.cardText, fontSize: 18),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 18),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: DesignTokens.cardText),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close, color: DesignTokens.cardText),
                onPressed: onClear,
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: DesignTokens.studioYellow,
            width: 2,
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
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

class _DropdownBox<T> extends StatelessWidget {
  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: DesignTokens.cardText,
          ),
          style: const TextStyle(color: DesignTokens.cardText, fontSize: 15),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BookingListItem extends StatelessWidget {
  const _BookingListItem({
    required this.booking,
    required this.onSelected,
    required this.showDivider,
  });

  final AdminBooking booking;
  final ValueChanged<AdminBooking>? onSelected;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isQr = booking.method == PaymentMethod.qrCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: DesignTokens.cardText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.sessionType,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF858585),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(status: booking.status),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _BookingInfoRow(
          icon: Icons.calendar_month_outlined,
          text: booking.dateTime,
        ),
        const SizedBox(height: 8),
        _BookingInfoRow(
          icon: isQr ? Icons.qr_code_2 : Icons.payments_outlined,
          text: isQr ? 'QR Code' : 'Cash',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => onSelected?.call(booking),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF858585),
              padding: const EdgeInsets.symmetric(vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right, size: 22),
            label: const Text('See details'),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE0E0E0)),
        if (!showDivider) const SizedBox(height: 4),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case BookingStatus.pendingVerification:
        label = 'Pending verification';
        bg = DesignTokens.studioYellow;
        fg = DesignTokens.cardText;
      case BookingStatus.confirmed:
        label = 'Confirmed';
        bg = DesignTokens.confirmedGreen;
        fg = Colors.white;
      case BookingStatus.unpaid:
        label = 'Unpaid';
        bg = const Color(0xFFC0392B);
        fg = Colors.white;
      case BookingStatus.rejected:
        label = 'Rejected';
        bg = const Color(0xFFC0392B);
        fg = Colors.white;
      case BookingStatus.cancelled:
        label = 'Cancelled';
        bg = const Color(0xFF757575);
        fg = Colors.white;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: fg,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFFB0B0B0)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: const Color(0xFFB0B0B0), fontSize: 14),
          ),
        ),
      ],
    );
  }
}
