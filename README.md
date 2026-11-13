# Blackbox Studio

A Flutter photography studio booking app for iOS, Android, and Web.

## Design system

Shared typography, colors, surfaces, and card styling live in
`lib/core/theme/app_theme.dart` and `lib/theme/design_tokens.dart`:

- Near-black app background: `#121212` (dark surface: `#1A1A1A`)
- Studio yellow accent: `#FFD600`
- White content cards with 16 px rounded corners
- Soft pink alert cards: `#FFCDD2`
- Yellow Pending and green Confirmed status pills
- Fraunces display headings and PT Sans body typography

Admin and customer features are isolated under `lib/features/admin/` and
`lib/features/customer/`. Each side has its own responsive navigation shell:
five admin destinations and four customer destinations, with a NavigationRail
at widths of 600 px and above.

## Authentication

`lib/features/auth/admin_auth_screen.dart` provides the reusable
`AdminAuthScreen` in Sign In and Sign Up modes for either role. It validates
credentials, adapts its content width for mobile and web, and reports
submissions through the `onSubmit` callback. Provide callbacks for the terms
and privacy links when connecting the screen to the relevant policy pages.

`lib/features/auth/role_selection_screen.dart` provides `RoleSelectionScreen`
with Customer and Admin choices.

Admin screens live in `lib/features/admin/`. `AdminDashboardScreen` contains
responsive metrics and schedule content; `AdminAppShell` provides adaptive
navigation.

`AdminBookingsScreen` displays booking statuses, dates, and payment details.
`AdminCustomerScreen` provides the searchable customer list with Upcoming,
Unpaid, and Past filters. Admin reviews and settings remain available in the
same feature folder.

Customer routes expose Home, Explore, Booking, and Profile under `/customer/`.
The booking calendar supports date selection, availability indicators, and
confirmation feedback. Profile social links open in the external browser.

## Routing

`lib/core/router/app_router.dart` configures role selection,
`/admin/login`, `/admin/*`, `/customer/login`, and `/customer/*` routes. For
this UI prototype, a valid sign-in or sign-up form submission navigates to the
selected role's landing screen; credential verification must be connected to
an authentication service before production use.
