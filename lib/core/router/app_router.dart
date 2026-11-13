import 'package:go_router/go_router.dart';

import '../../features/auth/admin_auth_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/admin/admin_bookings_screen.dart';
import '../../features/admin/admin_customers_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_reviews_screen.dart';
import '../../features/admin/admin_settings_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/customer/customer_app_shell.dart';
import '../../features/customer/customer_booking_screen.dart';
import '../../features/customer/customer_explore_screen.dart';
import '../../features/customer/customer_home_screen.dart';
import '../../features/customer/customer_profile_screen.dart';

final appRouter = createAppRouter();

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => RoleSelectionScreen(
          onRoleSelected: (role) {
            context.go(
              role == UserRole.admin ? '/admin/login' : '/customer/login',
            );
          },
        ),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => AdminAuthScreen(
          onSubmit: (_) => context.go('/admin/dashboard'),
        ),
      ),
      GoRoute(
        path: '/customer/login',
        builder: (context, state) => AdminAuthScreen(
          onSubmit: (_) => context.go('/customer/home'),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminAppShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/bookings',
            builder: (context, state) => const AdminBookingsScreen(),
          ),
          GoRoute(
            path: '/admin/customers',
            builder: (context, state) => const AdminCustomerScreen(),
          ),
          GoRoute(
            path: '/admin/reviews',
            builder: (context, state) => const AdminReviewsScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => CustomerAppShell(
          location: state.uri.path,
          child: child,
        ),
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
