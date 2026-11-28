import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pbs_pawsitivecode/main.dart';
import 'package:pbs_pawsitivecode/core/auth/auth_state.dart';
import 'package:pbs_pawsitivecode/core/router/app_router.dart';
import 'package:pbs_pawsitivecode/core/theme/app_theme.dart';
import 'package:pbs_pawsitivecode/features/auth/admin_auth_screen.dart';
import 'package:pbs_pawsitivecode/features/auth/customer_auth_screen.dart';
import 'package:pbs_pawsitivecode/features/auth/role_selection_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_bookings_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_customers_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_dashboard_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_reviews_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_settings_screen.dart';
import 'package:pbs_pawsitivecode/features/customer/customer_booking_screen.dart';
import 'package:pbs_pawsitivecode/features/customer/customer_explore_screen.dart';
import 'package:pbs_pawsitivecode/features/customer/customer_home_screen.dart';
import 'package:pbs_pawsitivecode/features/customer/customer_profile_screen.dart';
import 'package:pbs_pawsitivecode/features/customer/customer_app_shell.dart';
import 'package:pbs_pawsitivecode/theme/design_tokens.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_booking_detail_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/admin_packages_screen.dart';
import 'package:pbs_pawsitivecode/features/admin/models/payment_review.dart';
import 'package:pbs_pawsitivecode/features/admin/models/studio_package.dart';

AuthState signedInAdmin() => AuthState()..signInAs(AuthRole.admin);
AuthState signedInCustomer() => AuthState()..signInAs(AuthRole.customer);

Future<void> pumpAppRouter(
  WidgetTester tester, {
  String initialLocation = '/',
  AuthState? auth,
}) async {
  final authState = auth ?? AuthState();
  final router = createAppRouter(authState, initialLocation: initialLocation);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
  );
}

void main() {
  testWidgets('app starts at role selection', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BlackboxStudioApp());

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('How would you like to continue?'), findsOneWidget);
    expect(find.text('Admin password required'), findsOneWidget);
  });

  testWidgets('admin role routes through auth to the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester);
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back!'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('admin pages redirect to admin login when signed out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester, initialLocation: '/admin/dashboard');
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardScreen), findsNothing);
    expect(find.byType(AdminAuthScreen), findsOneWidget);
  });

  testWidgets('customer role goes straight to home without login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester);
    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerHomeScreen), findsOneWidget);
    expect(find.text('Welcome back!'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('booking asks guests to sign in first', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester, initialLocation: '/customer/booking');
    await tester.pumpAndSettle();

    expect(find.byType(CustomerBookingScreen), findsNothing);
    expect(find.byType(CustomerAuthScreen), findsOneWidget);
  });

  testWidgets('sign in shows credentials, remember option, and mode toggle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminAuthScreen()));

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Remember for 30 days'), findsOneWidget);
    expect(find.text('Don’t have an account?'), findsOneWidget);
  });

  testWidgets('sign up includes name and requires terms acceptance', (
    tester,
  ) async {
    AuthFormData? submitted;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminAuthScreen(onSubmit: (data) => submitted = data),
      ),
    );

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Get Started Now'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('terms'), findsOneWidget);
    expect(find.text('policy'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Taylor Reed');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'taylor@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'securepass123');
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up').first);
    await tester.pumpAndSettle();

    expect(submitted, isNull);
    expect(find.text('Please agree to the terms and policy.'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up').first);
    await tester.pumpAndSettle();

    expect(submitted?.mode, AuthMode.signUp);
    expect(submitted?.name, 'Taylor Reed');
    expect(submitted?.acceptedTerms, isTrue);
  });

  testWidgets('auth fields remain constrained on wide layouts', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminAuthScreen()));

    final fieldWidth = tester.getSize(find.byType(TextFormField).first).width;
    expect(fieldWidth, lessThanOrEqualTo(520));
    expect(fieldWidth, greaterThan(400));
  });

  testWidgets('admin dashboard shows metrics, alerts, and schedule actions', (
    tester,
  ) async {
    var paymentReviewTapped = false;
    var scheduleTapped = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminDashboardScreen(
          username: 'Dana',
          onPaymentReviewTap: () => paymentReviewTapped = true,
          onScheduleTap: () => scheduleTapped = true,
        ),
      ),
    );

    expect(find.text('Good morning, Dana!'), findsOneWidget);
    expect(find.text('RM x,xxx'), findsOneWidget);
    expect(find.text('Total bookings'), findsOneWidget);
    expect(find.text('Pending request'), findsOneWidget);
    expect(find.text('Confirmed'), findsWidgets);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Payment pending'), findsOneWidget);
    expect(find.text('3 payments need review'), findsOneWidget);

    await tester.ensureVisible(find.text('Payment pending'));
    await tester.tap(find.text('Payment pending'));
    expect(paymentReviewTapped, isTrue);

    await tester.scrollUntilVisible(find.text('Graduation'), 300);
    expect(find.text('Graduation'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);

    await tester.ensureVisible(find.text('See full schedule'));
    await tester.tap(find.text('See full schedule'));
    expect(scheduleTapped, isTrue);
  });

  testWidgets('admin dashboard metrics expand on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminDashboardScreen()));

    final revenueCard = find.byKey(
      const ValueKey('dashboard-metric-Monthly revenue'),
    );
    final bookingCard = find.byKey(
      const ValueKey('dashboard-metric-Total bookings'),
    );
    expect(tester.getSize(revenueCard).width, greaterThan(400));
    expect(tester.getSize(bookingCard).width, greaterThan(200));
  });

  testWidgets('admin bookings show deposit, balance, filters, and details', (
    tester,
  ) async {
    AdminBooking? selected;
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminBookingsScreen(
          store: BookingStore(),
          onBookingSelected: (b) => selected = b,
        ),
      ),
    );

    expect(find.text('Showing 5 of 5 bookings'), findsOneWidget);
    expect(find.text('Fong'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Wedding Classic · RM 1,400'), findsNWidgets(3));
    expect(find.text('Locked'), findsNWidgets(3));
    expect(find.text('See details'), findsNWidgets(5));

    await tester.tap(find.text('Rejected').first); // filter chip
    await tester.pumpAndSettle();
    expect(find.text('Showing 1 of 5 bookings'), findsOneWidget);
    expect(find.text('Ros'), findsOneWidget);
    expect(find.text('Fong'), findsNothing);

    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('See details').first);
    expect(selected?.customerName, 'Fong');
  });

  testWidgets('admin can approve a QR deposit and it turns paid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = BookingStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminBookingDetailScreen(
          bookingRef: 'BBS-261212-014',
          store: store,
        ),
      ),
    );

    await tester.tap(find.text('Approve deposit'));
    await tester.pumpAndSettle();
    expect(find.text('Review deposit'), findsOneWidget);

    final checks = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(CheckboxListTile),
    );
    for (var i = 0; i < 3; i++) {
      await tester.tap(checks.at(i));
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Approve deposit'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Deposit payment approved'), findsOneWidget);
    expect(find.text('Back to booking'), findsOneWidget);
    expect(store.byRef('BBS-261212-014')!.deposit.status, PaymentStatus.paid);
  });

  testWidgets('packages list shows prices and filters by category', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminPackagesScreen(store: PackageStore()),
      ),
    );

    expect(find.text('Wedding Classic'), findsOneWidget);
    expect(find.text('RM 1,200 · 2 hr'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);

    await tester.ensureVisible(find.text('Maternity').first);
    await tester.tap(find.text('Maternity').first); // filter chip
    await tester.pumpAndSettle();
    expect(find.text('Wedding Classic'), findsNothing);
    expect(find.text('Maternity Glow'), findsOneWidget);
  });

  testWidgets('Booking destination opens AdminBookingsScreen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/dashboard',
      auth: signedInAdmin(),
    );

    await tester.tap(find.text('Booking').last);
    await tester.pumpAndSettle();
    expect(find.byType(AdminBookingsScreen), findsOneWidget);
    expect(find.text('Fong'), findsOneWidget);
  });

  testWidgets('customer list search and filters update grouped bookings', (
    tester,
  ) async {
    CustomerBooking? selectedBooking;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminCustomerScreen(
          onBookingSelected: (booking) => selectedBooking = booking,
        ),
      ),
    );

    expect(find.text('Customer'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Unpaid'), findsWidgets);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('Dayang'), findsOneWidget);
    expect(find.text('Fong'), findsOneWidget);
    expect(find.text('Ros'), findsOneWidget);

    await tester.tap(find.text('Unpaid'));
    await tester.pumpAndSettle();
    expect(find.text('Fong'), findsOneWidget);
    expect(find.text('Dayang'), findsNothing);
    expect(find.text('Ros'), findsNothing);

    await tester.tap(find.text('ALL'));
    await tester.enterText(find.byType(TextField), 'Ros');
    await tester.pumpAndSettle();
    expect(find.text('Ros'), findsNWidgets(2));
    expect(find.text('Fong'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Dayang'), findsOneWidget);

    await tester.tap(find.text('Dayang'));
    expect(selectedBooking?.customerName, 'Dayang');
  });

  testWidgets('Customer destination opens AdminCustomerScreen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/dashboard',
      auth: signedInAdmin(),
    );

    await tester.tap(find.text('Customer').last);
    await tester.pumpAndSettle();
    expect(find.byType(AdminCustomerScreen), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('admin reviews filter and update public profile visibility', (
    tester,
  ) async {
    AdminReview? replyReview;
    AdminReview? visibilityReview;
    bool? visibilityValue;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminReviewsScreen(
          onReplySelected: (review) => replyReview = review,
          onPublicProfileChanged: (review, isPublic) {
            visibilityReview = review;
            visibilityValue = isPublic;
          },
        ),
      ),
    );

    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('653 reviews'), findsOneWidget);
    expect(find.text('Wedding'), findsWidgets);
    expect(find.text('Maternity'), findsWidgets);
    expect(find.text('Pre-Wed'), findsWidgets);
    expect(find.text('Convocation'), findsWidgets);
    expect(find.text('Fong'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
    expect(
      find.text('Your reply: Thank you, Siti for your review.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Wedding').last);
    await tester.pumpAndSettle();
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Fong'), findsNothing);

    await tester.ensureVisible(find.byType(Switch));
    final toggleMouseRegion = find
        .ancestor(of: find.byType(Switch), matching: find.byType(MouseRegion))
        .first;
    expect(
      tester.widget<MouseRegion>(toggleMouseRegion).cursor,
      SystemMouseCursors.click,
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(visibilityReview?.customerName, 'Siti');
    expect(visibilityValue, isTrue);

    await tester.tap(find.text('Edit Reply'));
    expect(replyReview?.customerName, 'Siti');
  });

  testWidgets('Reviews destination opens AdminReviewsScreen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/dashboard',
      auth: signedInAdmin(),
    );

    await tester.tap(find.text('Reviews').last);
    await tester.pumpAndSettle();
    expect(find.byType(AdminReviewsScreen), findsOneWidget);
    expect(find.text('653 reviews'), findsOneWidget);
  });

  testWidgets('admin settings show contact info and management actions', (
    tester,
  ) async {
    BusinessManagementSection? selectedSection;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AdminSettingsScreen(
          accountName: 'ADMIN',
          phone: '+60 12-3456789',
          email: 'admin@example.com',
          onSectionSelected: (section) => selectedSection = section,
        ),
      ),
    );

    expect(find.text('Setting'), findsOneWidget);
    expect(find.text('ADMIN'), findsOneWidget);
    expect(find.text('Admin account'), findsOneWidget);
    expect(find.text('+60 12-3456789'), findsOneWidget);
    expect(find.text('admin@example.com'), findsOneWidget);
    expect(find.text('Business management'), findsOneWidget);
    expect(find.text('Packages & prices'), findsOneWidget);
    expect(find.text('Working hours'), findsOneWidget);
    expect(find.text('Offer'), findsOneWidget);
    expect(find.text('Social media'), findsOneWidget);

    await tester.tap(find.text('Packages & prices'));
    expect(selectedSection, BusinessManagementSection.packagesAndPrices);
  });

  testWidgets('Setting destination opens AdminSettingsScreen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/dashboard',
      auth: signedInAdmin(),
    );

    await tester.tap(find.text('Setting').last);
    await tester.pumpAndSettle();
    expect(find.byType(AdminSettingsScreen), findsOneWidget);
    expect(find.text('Packages & prices'), findsOneWidget);
  });

  testWidgets('AdminAppShell uses AdminDashboardScreen for dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/dashboard',
      auth: signedInAdmin(),
    );

    expect(find.byType(AdminDashboardScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('customer home shows booking categories and calendar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester, initialLocation: '/customer/home');

    expect(find.text('Good morning, Username!'), findsOneWidget);
    expect(find.text('Capture your moments'), findsOneWidget);
    expect(find.text('Make it timeless'), findsOneWidget);
    expect(find.text('Book for photoshoots'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);
    expect(find.text('Maternity'), findsOneWidget);
    expect(find.text('Graduation'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Mini portrait weekend'), findsOneWidget);
  });

  testWidgets('customer explore filters style cards', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester, initialLocation: '/customer/explore');

    expect(find.byType(CustomerExploreScreen), findsOneWidget);
    expect(find.text('Find your style with us!'), findsOneWidget);
    expect(find.text('Golden hour'), findsOneWidget);
    await tester.tap(find.text('Graduation').first);
    await tester.pumpAndSettle();
    expect(find.text('A new chapter'), findsOneWidget);
    expect(find.text('Golden hour'), findsNothing);
  });

  testWidgets('customer booking enables confirmation after date selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/customer/booking',
      auth: signedInCustomer(),
    );

    expect(find.byType(CustomerBookingScreen), findsOneWidget);

    // Scroll until AI Day Finder is visible.
    await tester.scrollUntilVisible(
      find.text('AI day finder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('AI day finder'), findsOneWidget);

    // Find the calendar availability information.
    await tester.scrollUntilVisible(
      find.text('Fully booked'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Fully booked'), findsOneWidget);

    // Select October 9.
    await tester.scrollUntilVisible(
      find.text('9'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('9'));
    await tester.tap(find.text('9'));
    await tester.pumpAndSettle();

    expect(find.text('9 Oct 2026'), findsOneWidget);

    // Confirm booking.
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.text('Selected October 9, 2026 for your booking.'),
      findsOneWidget,
    );
  });

  testWidgets('customer profile includes reminder and social links', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester, initialLocation: '/customer/profile');

    expect(find.byType(CustomerProfileScreen), findsOneWidget);
    expect(find.text('Dayang'), findsOneWidget);
    expect(find.text('Upcoming shoots'), findsOneWidget);
    expect(find.text('Portrait session'), findsOneWidget);
    expect(find.text('Confirmed'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Booking reminder'), 300);
    expect(find.text('Booking reminder'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    final reminderEnabled = tester.widget<Switch>(find.byType(Switch)).value;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, !reminderEnabled);
    await tester.scrollUntilVisible(find.text('Facebook'), 300);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
  });

  testWidgets('customer shell uses a navigation rail on wide viewports', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(tester, initialLocation: '/customer/home');

    expect(find.byType(CustomerAppShell), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('admin settings back button returns to dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/settings',
      auth: signedInAdmin(),
    );

    final backButton = find.byTooltip('Back');
    final backMouseRegion = find
        .ancestor(of: backButton, matching: find.byType(MouseRegion))
        .first;
    expect(
      tester.widget<MouseRegion>(backMouseRegion).cursor,
      SystemMouseCursors.click,
    );
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardScreen), findsOneWidget);
  });

  testWidgets('customer booking back button returns home', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/customer/booking',
      auth: signedInCustomer(),
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerHomeScreen), findsOneWidget);
  });

  testWidgets('role cards describe each role and report selections', (
    tester,
  ) async {
    final selectedRoles = <UserRole>[];
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: RoleSelectionScreen(onRoleSelected: selectedRoles.add),
      ),
    );

    expect(find.text('Welcome!'), findsOneWidget);
    expect(
      find.text('Browse styles, check dates and book your photoshoot'),
      findsOneWidget,
    );
    expect(find.text('Admin password required'), findsOneWidget);
    final clickableMouseRegions = tester
        .widgetList<MouseRegion>(find.byType(MouseRegion))
        .where((region) => region.cursor == SystemMouseCursors.click);
    expect(clickableMouseRegions, hasLength(2));

    await tester.tap(find.text('Customer'));
    await tester.pump();
    expect(selectedRoles, [UserRole.customer]);

    await tester.ensureVisible(find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pump();
    expect(selectedRoles, [UserRole.customer, UserRole.admin]);
  });

  testWidgets('role cards expand responsively on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));

    final cardFinder = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedContainer &&
          widget.duration == const Duration(milliseconds: 150),
    );
    final cards = tester.widgetList<AnimatedContainer>(cardFinder);
    expect(cards, hasLength(2));
    expect(tester.getSize(cardFinder.first).width, greaterThan(400));
  });

  testWidgets('role cards fit compact phone widths', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));

    expect(tester.takeException(), isNull);
    expect(find.text('Admin password required'), findsOneWidget);
  });

  test('design tokens define the shared studio palette and card radius', () {
    expect(DesignTokens.background, const Color(0xFF1A1A1A));
    expect(DesignTokens.studioYellow, const Color(0xFFFFD600));
    expect(DesignTokens.alertPink, const Color(0xFFFFCDD2));
    expect(DesignTokens.confirmedGreen, const Color(0xFF2E7D32));
    expect(DesignTokens.cardRadius, 16);
  });

  test('app theme assigns Fraunces headings and PT Sans body styles', () {
    final textTheme = AppTheme.dark.textTheme;

    expect(
      textTheme.displayLarge?.fontFamily,
      GoogleFonts.fraunces().fontFamily,
    );
    expect(
      textTheme.headlineMedium?.fontFamily,
      GoogleFonts.fraunces().fontFamily,
    );
    expect(textTheme.titleLarge?.fontFamily, GoogleFonts.fraunces().fontFamily);
    expect(textTheme.bodyLarge?.fontFamily, GoogleFonts.ptSans().fontFamily);
    expect(textTheme.bodyMedium?.fontFamily, GoogleFonts.ptSans().fontFamily);
    expect(textTheme.labelLarge?.fontFamily, GoogleFonts.ptSans().fontFamily);
    expect(AppTheme.dark.scaffoldBackgroundColor, const Color(0xFF1A1A1A));
    expect(AppTheme.dark.colorScheme.primary, const Color(0xFFFFD600));
  });

  testWidgets('See full schedule opens the admin schedule', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppRouter(
      tester,
      initialLocation: '/admin/dashboard',
      auth: signedInAdmin(),
    );

    await tester.ensureVisible(find.text('See full schedule'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See full schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('December 2026'), findsOneWidget);
    expect(find.text('2 bookings'), findsOneWidget);
  });
}
