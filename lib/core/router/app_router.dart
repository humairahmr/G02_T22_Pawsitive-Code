import 'package:go_router/go_router.dart';

import '../../features/auth/admin_auth_screen.dart';
import '../../features/auth/customer_auth_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/admin/admin_booking_detail_screen.dart';
import '../../features/admin/admin_bookings_screen.dart';
import '../../features/admin/admin_client_detail_screen.dart';
import '../../features/admin/admin_customers_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_package_edit.dart';
import '../../features/admin/admin_packages_screen.dart';
import '../../features/admin/admin_reviews_screen.dart';
import '../../features/admin/admin_schedule_screen.dart';
import '../../features/admin/admin_settings_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/models/payment_review.dart';
import '../../features/admin/models/studio_package.dart';
import '../../features/customer/customer_app_shell.dart';
import '../../features/customer/customer_booking_screen.dart';
import '../../features/customer/customer_explore_screen.dart';
import '../../features/customer/customer_home_screen.dart';
import '../../features/customer/customer_profile_screen.dart';
import '../auth/auth_state.dart';

final authState = AuthState();
final appRouter = createAppRouter(authState);

GoRouter createAppRouter(AuthState auth, {String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Admin pages: must be signed in as admin
      final isAdminArea = loc.startsWith('/admin') && loc != '/admin/login';
      if (isAdminArea && !auth.isAdmin) return '/admin/login';

      // Booking: must be signed in (browsing stays open)
      if (loc == '/customer/booking' && !auth.isSignedIn) {
        final from = Uri.encodeComponent(state.uri.toString());
        return '/customer/login?from=$from';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => RoleSelectionScreen(
          onRoleSelected: (role) {
            context.go(
              role == UserRole.admin ? '/admin/login' : '/customer/home',
            );
          },
        ),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => AdminAuthScreen(
          onSubmit: (_) {
            auth.signInAs(AuthRole.admin);
            context.go('/admin/dashboard');
          },
        ),
      ),
      GoRoute(
        path: '/customer/login',
        builder: (context, state) => CustomerAuthScreen(
          onBack: () => context.go('/customer/home'),
          onSubmit: () {
            auth.signInAs(AuthRole.customer);
            context.go(state.uri.queryParameters['from'] ?? '/customer/home');
          },
        ),
      ),

      // ---- Admin pages without the bottom navigation -----------------------
      GoRoute(
        path: '/admin/bookings/:ref',
        builder: (context, state) {
          final stage = state.uri.queryParameters['stage'] == 'balance'
              ? PaymentStage.balance
              : PaymentStage.deposit;
          return AdminBookingDetailScreen(
            bookingRef: state.pathParameters['ref']!,
            stage: stage,
          );
        },
      ),
      GoRoute(
        path: '/admin/schedule',
        builder: (context, state) => AdminScheduleScreen(
          onEntrySelected: (_) => context.go('/admin/bookings'),
        ),
      ),
      GoRoute(
        path: '/admin/packages',
        builder: (context, state) => AdminPackagesScreen(
          onAdd: () => context.go('/admin/packages/new'),
          onEdit: (p) => context.go('/admin/packages/${p.id}'),
        ),
      ),
      // "new" must come before ":id"
      GoRoute(
        path: '/admin/packages/new',
        builder: (context, state) =>
            AdminPackageEditScreen(onDone: () => context.go('/admin/packages')),
      ),
      GoRoute(
        path: '/admin/packages/:id',
        redirect: (context, state) =>
            packageStore.byId(state.pathParameters['id']!) == null
            ? '/admin/packages'
            : null,
        builder: (context, state) => AdminPackageEditScreen(
          package: packageStore.byId(state.pathParameters['id']!),
          onDone: () => context.go('/admin/packages'),
        ),
      ),
      GoRoute(
        path: '/admin/customers/:name',
        builder: (context, state) => AdminClientDetailScreen(
          name: state.pathParameters['name']!,
          onReply: () => context.go('/admin/reviews'),
        ),
      ),

      // ---- Admin shell (bottom navigation) ---------------------------------
      ShellRoute(
        builder: (context, state, child) =>
            AdminAppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => AdminDashboardScreen(
              onScheduleTap: () => context.go('/admin/schedule'),
              onPaymentReviewTap: () => context.go('/admin/bookings'),
            ),
          ),
          GoRoute(
            path: '/admin/bookings',
            builder: (context, state) => AdminBookingsScreen(
              onBookingSelected: (booking) => context.go(
                '/admin/bookings/${booking.ref}'
                '?stage=${booking.current.stage.name}',
              ),
              onPaymentSelected: (payment) => context.go(
                '/admin/bookings/${payment.bookingRef}'
                '?stage=${payment.stage.name}',
              ),
            ),
          ),
          GoRoute(
            path: '/admin/customers',
            builder: (context, state) => AdminCustomerScreen(
              onBookingSelected: (booking) => context.go(
                '/admin/customers/${Uri.encodeComponent(booking.customerName)}',
              ),
            ),
          ),
          GoRoute(
            path: '/admin/reviews',
            builder: (context, state) => const AdminReviewsScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => AdminSettingsScreen(
              onSectionSelected: (section) {
                if (section == BusinessManagementSection.packagesAndPrices) {
                  context.go('/admin/packages');
                }
              },
            ),
          ),
        ],
      ),

      // ---- Customer shell --------------------------------------------------
      ShellRoute(
        builder: (context, state, child) =>
            CustomerAppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/customer/home',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/explore',
            builder: (context, state) => const CustomerExploreScreen(),
          ),
          GoRoute(
            path: '/customer/booking',
            builder: (context, state) => CustomerBookingScreen(
              initialSessionType: state.uri.queryParameters['category'],
            ),
          ),
          GoRoute(
            path: '/customer/profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
