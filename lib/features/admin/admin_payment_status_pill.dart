import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'models/payment_review.dart';

const paymentRed = Color(0xFFC0392B);

class PaymentStatusPill extends StatelessWidget {
  const PaymentStatusPill({
    super.key,
    required this.status,
    this.small = false,
    this.locked = false,
  });

  final PaymentStatus status;
  final bool small;

  /// Shows a grey "Locked" pill (balance not available yet).
  final bool locked;

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color fg;
    switch (status) {
      case PaymentStatus.unpaid:
        label = 'Unpaid';
        bg = paymentRed;
        fg = Colors.white;
      case PaymentStatus.pendingVerification:
        label = 'Pending verification';
        bg = DesignTokens.studioYellow;
        fg = DesignTokens.cardText;
      case PaymentStatus.paid:
        label = 'Paid';
        bg = DesignTokens.confirmedGreen;
        fg = Colors.white;
      case PaymentStatus.rejected:
        label = 'Rejected';
        bg = paymentRed;
        fg = Colors.white;
      case PaymentStatus.cancelled:
        label = 'Cancelled';
        bg = const Color(0xFF757575);
        fg = Colors.white;
    }
    if (locked) {
      label = 'Locked';
      bg = const Color(0xFFE6E6E6);
      fg = const Color(0xFF757575);
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
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: small ? 13 : 15,
        ),
      ),
    );
  }
}
