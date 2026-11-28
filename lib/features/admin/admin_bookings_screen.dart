import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';
import 'admin_filter.dart';
import 'models/admin_booking.dart';
import 'models/payment_review.dart';
import 'admin_payment_status_pill.dart';

export 'models/admin_booking.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({
    super.key,
    this.store,
    this.onBookingSelected,
    this.onPaymentSelected,
  });

  final BookingStore? store;

  /// "See details": opens the payment that needs attention.
  final ValueChanged<AdminBooking>? onBookingSelected;

  /// Tap on the Deposit or Balance row.
  final ValueChanged<PaymentReview>? onPaymentSelected;

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final _search = TextEditingController();
  PaymentStage? _stage;
  PaymentStatus? _status;
  PaymentMethod? _method;
  BookingSort _sort = BookingSort.newest;

  static const _statusChips = <(PaymentStatus?, String)>[
    (null, 'All'),
    (PaymentStatus.pendingVerification, 'Pending verification'),
    (PaymentStatus.unpaid, 'Unpaid'),
    (PaymentStatus.paid, 'Paid'),
    (PaymentStatus.rejected, 'Rejected'),
    (PaymentStatus.cancelled, 'Cancelled'),
  ];

  BookingStore get _store => widget.store ?? bookingStore;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AdminBooking> _visible(List<AdminBooking> all) {
    final query = _search.text.trim().toLowerCase();
    final list = all.where((b) {
      final parts = _stage == null
          ? [b.deposit, b.balance]
          : [b.paymentFor(_stage!)];
      if (_status != null && !parts.any((p) => p.status == _status)) {
        return false;
      }
      if (_method != null && !parts.any((p) => p.method == _method)) {
        return false;
      }
      if (query.isNotEmpty &&
          !b.customerName.toLowerCase().contains(query) &&
          !b.ref.toLowerCase().contains(query) &&
          !b.packageName.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case BookingSort.newest:
          return b.sortKey.compareTo(a.sortKey);
        case BookingSort.oldest:
          return a.sortKey.compareTo(b.sortKey);
        case BookingSort.balanceDue:
          return a.dueKey.compareTo(b.dueKey);
        case BookingSort.amountHighToLow:
          return b.total.compareTo(a.total);
      }
    });
    return list;
  }

  Future<void> _openFilters() async {
    final result = await showBookingFilterSheet(
      context,
      initial: (stage: _stage, status: _status, method: _method, sort: _sort),
    );
    if (result == null || !mounted) return;
    setState(() {
      _stage = result.stage;
      _status = result.status;
      _method = result.method;
      _sort = result.sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final all = _store.bookings;
        final visible = _visible(all);

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
                    const SizedBox(height: 20),
                    _SearchField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      onClear: () => setState(_search.clear),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final (status, label) in _statusChips) ...[
                            _FilterChip(
                              label: label,
                              selected: _status == status,
                              onSelected: () =>
                                  setState(() => _status = status),
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
                          child: _DropdownBox<PaymentStage?>(
                            value: _stage,
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('Stage: All'),
                              ),
                              DropdownMenuItem(
                                value: PaymentStage.deposit,
                                child: Text('Stage: Deposit'),
                              ),
                              DropdownMenuItem(
                                value: PaymentStage.balance,
                                child: Text('Stage: Balance'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _stage = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: 'Filter & sort',
                          child: Material(
                            color: DesignTokens.studioYellow,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: _openFilters,
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
                    const SizedBox(height: 20),
                    Text(
                      'Showing ${visible.length} of ${all.length} bookings',
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
                      for (final booking in visible)
                        _BookingCard(
                          booking: booking,
                          onSelected: widget.onBookingSelected,
                          onPaymentSelected: widget.onPaymentSelected,
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onSelected,
    required this.onPaymentSelected,
  });

  final AdminBooking booking;
  final ValueChanged<AdminBooking>? onSelected;
  final ValueChanged<PaymentReview>? onPaymentSelected;

  @override
  Widget build(BuildContext context) {
    final deposit = booking.deposit;
    final balance = booking.balance;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.customerName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: DesignTokens.cardText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  booking.dateLabel,
                  style: const TextStyle(color: Color(0xFF858585)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.packageName} · ${formatRm(booking.total)}',
              style: const TextStyle(color: Color(0xFF858585), fontSize: 15),
            ),
            const Divider(height: 24, color: Color(0xFFE0E0E0)),
            _PaymentRow(
              payment: deposit,
              subtitle: deposit.method == PaymentMethod.qrCode ? 'QR' : 'Cash',
              onTap: () => onPaymentSelected?.call(deposit),
            ),
            const SizedBox(height: 4),
            _PaymentRow(
              payment: balance,
              subtitle: 'due ${booking.balanceDue}',
              locked: booking.balanceLocked,
              onTap: booking.balanceLocked
                  ? null
                  : () => onPaymentSelected?.call(balance),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onSelected?.call(booking),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF858585),
                  visualDensity: VisualDensity.compact,
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right, size: 22),
                label: const Text('See details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.subtitle,
    required this.onTap,
    this.locked = false,
  });

  final PaymentReview payment;
  final String subtitle;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final showIcon = payment.stage == PaymentStage.deposit || !locked;
    final isQr = payment.method == PaymentMethod.qrCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (showIcon)
                    Icon(
                      isQr ? Icons.qr_code_2 : Icons.payments_outlined,
                      size: 22,
                      color: DesignTokens.cardText,
                    ),
                  Text(
                    '${payment.stageLabel} ${formatRm(payment.amount)}',
                    style: const TextStyle(
                      color: DesignTokens.cardText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF858585)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PaymentStatusPill(
              status: payment.status,
              small: true,
              locked: locked,
            ),
          ],
        ),
      ),
    );
  }
}
