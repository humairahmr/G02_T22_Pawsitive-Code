enum PaymentMethod { cash, qrCode }

enum PaymentStage { deposit, balance }

enum PaymentStatus { unpaid, pendingVerification, paid, rejected, cancelled }

String formatDateTime(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour < 12 ? 'AM' : 'PM';
  return '${d.day} ${months[d.month - 1]} ${d.year}, $hour:$minute $period';
}

String formatRm(double amount) {
  final whole = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return 'RM $buffer';
}

/// One payment (the deposit OR the balance) of a booking.
class PaymentReview {
  const PaymentReview({
    required this.bookingRef,
    required this.customerName,
    required this.email,
    required this.method,
    required this.amount,
    required this.status,
    this.stage = PaymentStage.deposit,
    this.receiptUploadedAt,
    this.receivedAmount,
    this.receivedAt,
    this.rejectionNote,
  });

  final String bookingRef;
  final String customerName;
  final String email;
  final PaymentMethod method;
  final PaymentStage stage;
  final double amount;
  final PaymentStatus status;
  final DateTime? receiptUploadedAt;
  final double? receivedAmount;
  final DateTime? receivedAt;
  final String? rejectionNote;

  String get stageLabel =>
      stage == PaymentStage.deposit ? 'Deposit' : 'Balance';
  String get stageWord => stageLabel.toLowerCase();
  String get methodLabel => method == PaymentMethod.cash ? 'Cash' : 'QR Code';

  PaymentReview copyWith({
    PaymentStatus? status,
    double? receivedAmount,
    DateTime? receivedAt,
    String? rejectionNote,
  }) {
    return PaymentReview(
      bookingRef: bookingRef,
      customerName: customerName,
      email: email,
      method: method,
      stage: stage,
      amount: amount,
      status: status ?? this.status,
      receiptUploadedAt: receiptUploadedAt,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      receivedAt: receivedAt ?? this.receivedAt,
      rejectionNote: rejectionNote ?? this.rejectionNote,
    );
  }
}
