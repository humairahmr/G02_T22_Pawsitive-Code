import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';
import 'models/payment_review.dart';
import 'admin_payment_sheets.dart';

const _red = Color(0xFFC0392B);
const _dark = Color(0xFF1A1A1A);

class AdminBookingDetailScreen extends StatefulWidget {
  const AdminBookingDetailScreen({
    super.key,
    required this.payment,
    this.onChanged,
  });

  final PaymentReview payment;

  /// Called whenever the admin approves or rejects (hook up to backend later).
  final ValueChanged<PaymentReview>? onChanged;

  @override
  State<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  late PaymentReview _p = widget.payment;
  String? _banner;
  bool _bannerIsSuccess = true;

  bool get _resolved =>
      _p.status == PaymentStatus.paid || _p.status == PaymentStatus.rejected;

  void _update(PaymentReview next, {required String banner, required bool ok}) {
    setState(() {
      _p = next;
      _banner = banner;
      _bannerIsSuccess = ok;
    });
    widget.onChanged?.call(next);
  }

  Future<void> _markCashPaid() async {
    final result = await showReviewCashSheet(context, payment: _p);
    if (result == null) return;
    _update(
      _p.copyWith(
        status: PaymentStatus.paid,
        receivedAmount: result.amount,
        receivedAt: result.receivedOn,
      ),
      banner: 'Balance payment approved',
      ok: true,
    );
  }

  Future<void> _approveQr() async {
    final ok = await showApproveDepositSheet(context, payment: _p);
    if (ok != true) return;
    _update(
      _p.copyWith(status: PaymentStatus.paid),
      banner: 'Balance payment approved',
      ok: true,
    );
  }

  Future<void> _reject() async {
    final result = await showRejectSheet(context, payment: _p);
    if (result == null) return;
    _update(
      _p.copyWith(
        status: PaymentStatus.rejected,
        rejectionNote: result.note.isEmpty ? result.reason : result.note,
      ),
      banner: 'Balance payment rejected',
      ok: false,
    );
  }

  void _expandReceipt() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: const AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Icon(Icons.photo_camera_outlined, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    children: [
                      Row(
                        children: [
                          const AppBackButton(
                            fallbackLocation: '/admin/bookings',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Booking',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_banner != null) ...[
                        _Banner(text: _banner!, success: _bannerIsSuccess),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking ref',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  _p.bookingRef,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          _StatusPill(status: _p.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _CustomerCard(payment: _p),
                      const SizedBox(height: 16),
                      _BalanceCard(
                        payment: _p,
                        onExpandReceipt: _expandReceipt,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _buildActions(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (_resolved) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: () => context.go('/admin/bookings'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDADADA),
            foregroundColor: _dark,
          ),
          child: const Text(
            'Back to booking',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final isCash = _p.method == PaymentMethod.cash;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: _reject,
              style: FilledButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Reject',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: isCash ? _markCashPaid : _approveQr,
              style: FilledButton.styleFrom(
                backgroundColor: isCash
                    ? DesignTokens.studioYellow
                    : DesignTokens.confirmedGreen,
                foregroundColor: isCash ? _dark : Colors.white,
              ),
              child: Text(
                isCash ? 'Mark as paid' : 'Approve balance',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.success});
  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: success ? DesignTokens.confirmedGreen : _red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(success ? Icons.check : Icons.close, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.small = false});
  final PaymentStatus status;
  final bool small;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case PaymentStatus.unpaid:
        label = 'Unpaid';
        bg = _red;
        fg = Colors.white;
      case PaymentStatus.pendingVerification:
        label = 'Pending verification';
        bg = DesignTokens.studioYellow;
        fg = _dark;
      case PaymentStatus.paid:
        label = 'Paid';
        bg = DesignTokens.confirmedGreen;
        fg = Colors.white;
      case PaymentStatus.rejected:
        label = 'Rejected';
        bg = _red;
        fg = Colors.white;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 14 : 18,
        vertical: small ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.payment});
  final PaymentReview payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius + 8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: DesignTokens.studioYellow,
            child: Text(
              payment.customerName.isEmpty
                  ? '?'
                  : payment.customerName[0].toUpperCase(),
              style: const TextStyle(
                color: _dark,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  style: const TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  payment.email,
                  style: const TextStyle(color: Colors.black45),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Call',
            onPressed: () {},
            icon: const Icon(Icons.phone_outlined, color: _dark),
          ),
          IconButton.filledTonal(
            tooltip: 'Message',
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, color: _dark),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.payment, required this.onExpandReceipt});
  final PaymentReview payment;
  final VoidCallback onExpandReceipt;

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: const TextStyle(color: _dark, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final isQr = p.method == PaymentMethod.qrCode;

    Widget? note;
    if (p.status == PaymentStatus.unpaid && !isQr) {
      note = _NoteBox(
        text:
            'Collect ${formatRm(p.amount)} in cash when the customer arrives.',
        color: const Color(0xFFFFF4CC),
        icon: Icons.info_outline,
      );
    } else if (p.status == PaymentStatus.paid &&
        !isQr &&
        p.receivedAt != null) {
      note = _NoteBox(
        text:
            'Cash received: ${formatRm(p.receivedAmount ?? p.amount)} · '
            '${formatDateTime(p.receivedAt!)}',
        color: const Color(0xFFE4F0E4),
        icon: Icons.info_outline,
      );
    } else if (p.status == PaymentStatus.rejected && p.rejectionNote != null) {
      note = _NoteBox(
        text: 'Note to customer: “${p.rejectionNote}”',
        color: const Color(0xFFFDE8E6),
        icon: Icons.info_outline,
        textColor: _red,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius + 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Balance',
                  style: TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
              _StatusPill(status: p.status, small: true),
            ],
          ),
          _row('Method', p.methodLabel),
          _row('Amount', formatRm(p.amount)),
          if (isQr && p.receiptUploadedAt != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receipt uploaded',
                        style: TextStyle(
                          color: _dark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatDateTime(p.receiptUploadedAt!),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onExpandReceipt,
                  style: TextButton.styleFrom(foregroundColor: _dark),
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Expand'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // TODO: replace with Image.network(receiptUrl) once uploads exist
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4640),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.photo_camera_outlined, color: Colors.white38),
              ),
            ),
          ],
          if (note != null) ...[const SizedBox(height: 14), note],
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({
    required this.text,
    required this.color,
    required this.icon,
    this.textColor = Colors.black87,
  });

  final String text;
  final Color color;
  final IconData icon;
  final Color textColor;

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
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}
