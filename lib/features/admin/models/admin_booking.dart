import 'package:flutter/foundation.dart';

import 'payment_review.dart';

@immutable
class AdminBooking {
  const AdminBooking({
    required this.ref,
    required this.customerName,
    required this.packageName,
    required this.total,
    required this.dateLabel,
    required this.sortKey,
    required this.dueKey,
    required this.balanceDue,
    required this.deposit,
    required this.balance,
  });

  final String ref;
  final String customerName;
  final String packageName;
  final double total;
  final String dateLabel;

  /// Higher = booked more recently (used by "Newest first").
  final int sortKey;

  /// yyyymmdd of the balance due date (used by "Balance due date").
  final int dueKey;
  final String balanceDue;
  final PaymentReview deposit;
  final PaymentReview balance;

  /// The balance can only be handled after the deposit is paid.
  bool get balanceLocked => deposit.status != PaymentStatus.paid;

  /// Paid both deposit and balance. Only these show in the Customer tab.
  bool get isConfirmed =>
      deposit.status == PaymentStatus.paid &&
      balance.status == PaymentStatus.paid;

  /// The payment the admin should look at next.
  PaymentReview get current => balanceLocked ? deposit : balance;

  PaymentReview paymentFor(PaymentStage stage) =>
      stage == PaymentStage.deposit ? deposit : balance;

  AdminBooking withPayment(PaymentReview payment) {
    final isDeposit = payment.stage == PaymentStage.deposit;
    return AdminBooking(
      ref: ref,
      customerName: customerName,
      packageName: packageName,
      total: total,
      dateLabel: dateLabel,
      sortKey: sortKey,
      dueKey: dueKey,
      balanceDue: balanceDue,
      deposit: isDeposit ? payment : deposit,
      balance: isDeposit ? balance : payment,
    );
  }
}

PaymentReview _pay(
  String ref,
  String name,
  PaymentStage stage,
  PaymentMethod method,
  double amount,
  PaymentStatus status, {
  DateTime? receipt,
  DateTime? receivedAt,
  String? note,
}) {
  return PaymentReview(
    bookingRef: ref,
    customerName: name,
    email: 'xxxxx@gmail.com',
    method: method,
    stage: stage,
    amount: amount,
    status: status,
    receiptUploadedAt: receipt,
    receivedAt: receivedAt,
    receivedAmount: receivedAt == null ? null : amount,
    rejectionNote: note,
  );
}

const _dep = PaymentStage.deposit;
const _bal = PaymentStage.balance;
const _qr = PaymentMethod.qrCode;
const _cash = PaymentMethod.cash;

/// Placeholder data until the real backend exists.
final sampleAdminBookings = <AdminBooking>[
  AdminBooking(
    ref: 'BBS-261212-014',
    customerName: 'Fong',
    packageName: 'Wedding Classic',
    total: 1400,
    dateLabel: '12 Dec 2026',
    sortKey: 5,
    dueKey: 20261205,
    balanceDue: '5 Dec',
    deposit: _pay(
      'BBS-261212-014',
      'Fong',
      _dep,
      _qr,
      420,
      PaymentStatus.pendingVerification,
      receipt: DateTime(2026, 11, 24, 15, 42),
    ),
    balance: _pay(
      'BBS-261212-014',
      'Fong',
      _bal,
      _qr,
      980,
      PaymentStatus.unpaid,
    ),
  ),
  AdminBooking(
    ref: 'BBS-261214-015',
    customerName: 'Siti',
    packageName: 'Maternity Glow',
    total: 650,
    dateLabel: '14 Dec 2026',
    sortKey: 4,
    dueKey: 20261207,
    balanceDue: '7 Dec',
    deposit: _pay(
      'BBS-261214-015',
      'Siti',
      _dep,
      _cash,
      195,
      PaymentStatus.unpaid,
    ),
    balance: _pay(
      'BBS-261214-015',
      'Siti',
      _bal,
      _cash,
      455,
      PaymentStatus.unpaid,
    ),
  ),
  AdminBooking(
    ref: 'BBS-261213-013',
    customerName: 'Ros',
    packageName: 'Graduation Day',
    total: 450,
    dateLabel: '13 Dec 2026',
    sortKey: 3,
    dueKey: 20261206,
    balanceDue: '6 Dec',
    deposit: _pay(
      'BBS-261213-013',
      'Ros',
      _dep,
      _cash,
      135,
      PaymentStatus.rejected,
      note: 'Deposit was not received.',
    ),
    balance: _pay(
      'BBS-261213-013',
      'Ros',
      _bal,
      _cash,
      315,
      PaymentStatus.unpaid,
    ),
  ),
  AdminBooking(
    ref: 'BBS-261219-012',
    customerName: 'Umang',
    packageName: 'Wedding Classic',
    total: 1400,
    dateLabel: '19 Dec 2026',
    sortKey: 2,
    dueKey: 20261212,
    balanceDue: '12 Dec',
    deposit: _pay(
      'BBS-261219-012',
      'Umang',
      _dep,
      _cash,
      420,
      PaymentStatus.paid,
      receivedAt: DateTime(2026, 11, 20, 10, 30),
    ),
    balance: _pay(
      'BBS-261219-012',
      'Umang',
      _bal,
      _cash,
      980,
      PaymentStatus.unpaid,
    ),
  ),
  AdminBooking(
    ref: 'BBS-261220-011',
    customerName: 'Dayang',
    packageName: 'Wedding Classic',
    total: 1400,
    dateLabel: '20 Dec 2026',
    sortKey: 1,
    dueKey: 20261213,
    balanceDue: '13 Dec',
    deposit: _pay(
      'BBS-261220-011',
      'Dayang',
      _dep,
      _qr,
      420,
      PaymentStatus.paid,
      receipt: DateTime(2026, 11, 10, 9, 5),
    ),
    balance: _pay(
      'BBS-261220-011',
      'Dayang',
      _bal,
      _qr,
      980,
      PaymentStatus.paid,
      receipt: DateTime(2026, 12, 6, 14, 20),
    ),
  ),
];

/// Holds all bookings in memory. Replace with real backend calls later.
class BookingStore extends ChangeNotifier {
  BookingStore([List<AdminBooking>? initial])
    : _bookings = List.of(initial ?? sampleAdminBookings);

  final List<AdminBooking> _bookings;

  List<AdminBooking> get bookings => List.unmodifiable(_bookings);

  /// Customers who paid both deposit and balance.
  List<AdminBooking> get confirmed =>
      _bookings.where((b) => b.isConfirmed).toList();

  AdminBooking? byRef(String ref) {
    for (final b in _bookings) {
      if (b.ref == ref) return b;
    }
    return null;
  }

  void updatePayment(PaymentReview payment) {
    final i = _bookings.indexWhere((b) => b.ref == payment.bookingRef);
    if (i == -1) return;
    _bookings[i] = _bookings[i].withPayment(payment);
    notifyListeners();
  }
}

final bookingStore = BookingStore();
