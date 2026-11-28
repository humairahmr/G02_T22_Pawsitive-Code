import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'models/payment_review.dart';
import 'admin_payment_sheets.dart' show SheetFrame;

enum BookingSort { newest, oldest, balanceDue, amountHighToLow }

typedef BookingFilterResult = ({
  PaymentStage? stage,
  PaymentStatus? status,
  PaymentMethod? method,
  BookingSort sort,
});

Future<BookingFilterResult?> showBookingFilterSheet(
  BuildContext context, {
  required BookingFilterResult initial,
}) {
  return showModalBottomSheet<BookingFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(initial: initial),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final BookingFilterResult initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late PaymentStage? _stage = widget.initial.stage;
  late PaymentStatus? _status = widget.initial.status;
  late PaymentMethod? _method = widget.initial.method;
  late BookingSort _sort = widget.initial.sort;

  static const _sorts = <(BookingSort, String)>[
    (BookingSort.newest, 'Newest first'),
    (BookingSort.oldest, 'Oldest first'),
    (BookingSort.balanceDue, 'Balance due date'),
    (BookingSort.amountHighToLow, 'Amount: high to low'),
  ];

  static const _statuses = <(PaymentStatus?, String)>[
    (null, 'All'),
    (PaymentStatus.pendingVerification, 'Pending Verification'),
    (PaymentStatus.unpaid, 'Unpaid'),
    (PaymentStatus.paid, 'Paid'),
    (PaymentStatus.rejected, 'Rejected'),
    (PaymentStatus.cancelled, 'Cancelled'),
  ];

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: DesignTokens.cardText,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: 'Filter & sort',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Payment stage'),
          _Segmented<PaymentStage?>(
            options: const [
              (null, 'All'),
              (PaymentStage.deposit, 'Deposit'),
              (PaymentStage.balance, 'Balance'),
            ],
            selected: _stage,
            onChanged: (v) => setState(() => _stage = v),
          ),
          _heading('Payment status'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (value, label) in _statuses)
                _ChoicePill(
                  label: label,
                  selected: _status == value,
                  onTap: () => setState(() => _status = value),
                ),
            ],
          ),
          _heading('Payment method'),
          _Segmented<PaymentMethod?>(
            options: const [
              (null, 'All'),
              (PaymentMethod.qrCode, 'QR Code'),
              (PaymentMethod.cash, 'Cash'),
            ],
            selected: _method,
            onChanged: (v) => setState(() => _method = v),
          ),
          _heading('Sort by'),
          for (final (value, label) in _sorts)
            InkWell(
              onTap: () => setState(() => _sort = value),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: DesignTokens.cardText,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Icon(
                      _sort == value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: DesignTokens.cardText,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _stage = null;
                      _status = null;
                      _method = null;
                      _sort = BookingSort.newest;
                    }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.cardText,
                      side: const BorderSide(
                        color: DesignTokens.cardText,
                        width: 1.5,
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop((
                      stage: _stage,
                      status: _status,
                      method: _method,
                      sort: _sort,
                    )),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.studioYellow,
                      foregroundColor: DesignTokens.cardText,
                    ),
                    child: const Text(
                      'Show results',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          for (final (value, label) in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(value),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == selected
                        ? DesignTokens.studioYellow
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: DesignTokens.cardText,
                      fontWeight: value == selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
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
      color: selected ? DesignTokens.studioYellow : const Color(0xFFF1F1F1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Text(
            label,
            style: TextStyle(
              color: DesignTokens.cardText,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
