enum PaymentMethod { cash, qrCode }

enum PaymentStatus { unpaid, pendingVerification, paid, rejected }

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

class PaymentReview {
  const PaymentReview({
    required this.bookingRef,
    required this.customerName,
    required this.email,
    required this.method,
    required this.amount,
    required this.status,
    this.depositAmount = 420,
    this.receiptUploadedAt,
    this.receivedAmount,
    this.receivedAt,
    this.rejectionNote,
  });

  final String bookingRef;
  final String customerName;
  final String email;
  final PaymentMethod method;
  final double amount;
  final double depositAmount;
  final PaymentStatus status;
  final DateTime? receiptUploadedAt;
  final double? receivedAmount;
  final DateTime? receivedAt;
  final String? rejectionNote;

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
      amount: amount,
      depositAmount: depositAmount,
      status: status ?? this.status,
      receiptUploadedAt: receiptUploadedAt,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      receivedAt: receivedAt ?? this.receivedAt,
      rejectionNote: rejectionNote ?? this.rejectionNote,
    );
  }

  /// Placeholder data until the real backend exists.
  /// Fong = unpaid cash booking, everyone else = QR receipt to verify.
  factory PaymentReview.demo(String customerName) {
    if (customerName == 'Fong') {
      return PaymentReview(
        bookingRef: 'BBS-261212-014',
        customerName: customerName,
        email: 'xxxxx@gmail.com',
        method: PaymentMethod.cash,
        amount: 1400,
        status: PaymentStatus.unpaid,
      );
    }
    return PaymentReview(
      bookingRef: 'BBS-261212-014',
      customerName: customerName,
      email: 'xxxxx@gmail.com',
      method: PaymentMethod.qrCode,
      amount: 1400,
      status: PaymentStatus.pendingVerification,
      receiptUploadedAt: DateTime(2026, 11, 24, 15, 42),
    );
  }
}
