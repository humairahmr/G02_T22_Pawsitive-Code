import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/design_tokens.dart';
import 'models/payment_review.dart';

const _dark = Color(0xFF1A1A1A);
const _red = Color(0xFFC0392B);

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: _dark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close, color: _dark),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetButtons extends StatelessWidget {
  const _SheetButtons({
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmColor = DesignTokens.studioYellow,
    this.confirmTextColor = _dark,
  });

  final String confirmLabel;
  final VoidCallback? onConfirm;
  final Color confirmColor;
  final Color confirmTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _dark,
                side: const BorderSide(color: _dark, width: 1.5),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: confirmTextColor,
                disabledBackgroundColor: Colors.black12,
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text, this.color = const Color(0xFFF1F1F1)});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({Widget? suffix}) => InputDecoration(
  suffixIcon: suffix,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Colors.black26),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Colors.black26),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: _dark, width: 1.5),
  ),
);

// ---------------------------------------------------------------------------
// 1. Cash: "Review balance"
// ---------------------------------------------------------------------------

Future<({double amount, DateTime receivedOn})?> showReviewCashSheet(
  BuildContext context, {
  required PaymentReview payment,
}) {
  return showModalBottomSheet<({double amount, DateTime receivedOn})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReviewCashSheet(payment: payment),
  );
}

class _ReviewCashSheet extends StatefulWidget {
  const _ReviewCashSheet({required this.payment});
  final PaymentReview payment;

  @override
  State<_ReviewCashSheet> createState() => _ReviewCashSheetState();
}

class _ReviewCashSheetState extends State<_ReviewCashSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.payment.amount.toStringAsFixed(2),
  );
  DateTime _receivedOn = DateTime.now();
  bool _confirmed = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _receivedOn,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_receivedOn),
    );
    if (time == null) return;
    setState(() {
      _receivedOn = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    final parsed = double.tryParse(_amount.text);
    final valid = _confirmed && parsed != null && parsed > 0;

    return _SheetFrame(
      title: 'Review balance',
      subtitle: '${p.customerName} · ${p.bookingRef} · ${p.methodLabel}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount received',
            style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: _dark),
            decoration: _fieldDecoration().copyWith(prefixText: 'RM '),
          ),
          const SizedBox(height: 16),
          const Text(
            'Received on',
            style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: _fieldDecoration(
                suffix: const Icon(Icons.calendar_today_outlined, color: _dark),
              ),
              child: Text(
                formatDateTime(_receivedOn),
                style: const TextStyle(color: _dark),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _confirmed,
            onChanged: (v) => setState(() => _confirmed = v ?? false),
            activeColor: DesignTokens.studioYellow,
            checkColor: _dark,
            title: const Text(
              'I confirm the cash balance was received in person.',
              style: TextStyle(color: _dark),
            ),
          ),
          const _InfoBox(
            text:
                'Recorded as Admin ADM-001 with the timestamp above. '
                'The deposit becomes Paid.',
          ),
          const SizedBox(height: 16),
          _SheetButtons(
            confirmLabel: 'Approve balance',
            onConfirm: valid
                ? () =>
                      Navigator.of(context)
                          .pop((amount: parsed, receivedOn: _receivedOn))
                : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. QR: "Review deposit" checklist
// ---------------------------------------------------------------------------

Future<bool?> showApproveDepositSheet(
  BuildContext context, {
  required PaymentReview payment,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ApproveDepositSheet(payment: payment),
  );
}

class _ApproveDepositSheet extends StatefulWidget {
  const _ApproveDepositSheet({required this.payment});
  final PaymentReview payment;

  @override
  State<_ApproveDepositSheet> createState() => _ApproveDepositSheetState();
}

class _ApproveDepositSheetState extends State<_ApproveDepositSheet> {
  bool _amountOk = false;
  bool _refOk = false;
  bool _payeeOk = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    final allChecked = _amountOk && _refOk && _payeeOk;

    Widget check(String label, bool value, ValueChanged<bool?> onChanged) {
      return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
        activeColor: DesignTokens.studioYellow,
        checkColor: _dark,
        title: Text(label, style: const TextStyle(color: _dark)),
      );
    }

    return _SheetFrame(
      title: 'Review deposit',
      subtitle:
          '${p.customerName} · ${p.bookingRef} · '
          'Deposit ${formatRm(p.depositAmount)} · ${p.methodLabel}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check before approving',
            style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
          ),
          check(
            'Amount matches ${formatRm(p.amount)}',
            _amountOk,
            (v) => setState(() => _amountOk = v ?? false),
          ),
          check(
            'Reference ${p.bookingRef} is visible',
            _refOk,
            (v) => setState(() => _refOk = v ?? false),
          ),
          check(
            'Paid to Blackbox Studio (Maybank)',
            _payeeOk,
            (v) => setState(() => _payeeOk = v ?? false),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Are you sure to approve this payment?',
              style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _SheetButtons(
            confirmLabel: 'Approve balance',
            onConfirm: allChecked
                ? () => Navigator.of(context).pop(true)
                : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Reject balance
// ---------------------------------------------------------------------------

Future<({String reason, String note})?> showRejectSheet(
  BuildContext context, {
  required PaymentReview payment,
}) {
  return showModalBottomSheet<({String reason, String note})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RejectSheet(payment: payment),
  );
}

class _RejectSheet extends StatefulWidget {
  const _RejectSheet({required this.payment});
  final PaymentReview payment;

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  static const _reasons = [
    'Amount mismatch',
    'Unclear receipt',
    'Wrong account',
    'Other',
  ];

  late String _reason = _reasons.first;
  late final TextEditingController _note = TextEditingController(
    text: _template(_reasons.first),
  );

  String _template(String reason) {
    final amount = formatRm(widget.payment.depositAmount);
    switch (reason) {
      case 'Amount mismatch':
        return 'The receipt amount doesn’t match $amount. '
            'Please upload a clear receipt.';
      case 'Unclear receipt':
        return 'The receipt is unclear. Please upload a clearer photo.';
      case 'Wrong account':
        return 'The payment was sent to a different account. '
            'Please pay to Blackbox Studio (Maybank).';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;

    return _SheetFrame(
      title: 'Reject balance',
      subtitle:
          '${p.customerName} · ${p.bookingRef} · '
          'Deposit ${formatRm(p.depositAmount)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reason',
            style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in _reasons)
                ChoiceChip(
                  label: Text(r),
                  selected: _reason == r,
                  showCheckmark: false,
                  selectedColor: DesignTokens.studioYellow,
                  backgroundColor: const Color(0xFFF1F1F1),
                  labelStyle: const TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                  onSelected: (_) => setState(() {
                    _reason = r;
                    _note.text = _template(r);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Note to customer (optional)',
            style: TextStyle(color: _dark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLength: 200,
            maxLines: 3,
            style: const TextStyle(color: _dark),
            decoration: _fieldDecoration().copyWith(
              fillColor: const Color(0xFFF1F1F1),
            ),
          ),
          const SizedBox(height: 4),
          _InfoBox(
            color: const Color(0xFFFDE8E6),
            text:
                'Deposit status becomes Rejected. '
                'The customer gets this note via the app.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pop((reason: _reason, note: _note.text.trim())),
                    style: FilledButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Reject balance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _dark,
                      side: const BorderSide(color: _dark, width: 1.5),
                    ),
                    child: const Text('Cancel'),
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
