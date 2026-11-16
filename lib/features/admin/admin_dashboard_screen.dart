import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

@immutable
class DashboardScheduleItem {
  const DashboardScheduleItem({
    required this.time,
    required this.category,
    required this.client,
  });

  final String time;
  final String category;
  final String client;
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    this.username = 'Username',
    this.onPaymentReviewTap,
    this.onScheduleTap,
  });

  final String username;
  final VoidCallback? onPaymentReviewTap;
  final VoidCallback? onScheduleTap;

  static const _schedule = [
    DashboardScheduleItem(
      time: '08:00 AM',
      category: 'Graduation',
      client: 'Ros',
    ),
    DashboardScheduleItem(
      time: '11:00 AM',
      category: 'Wedding',
      client: 'Umang',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmedUsername = username.trim();
    final avatarLetter = trimmedUsername.isEmpty
        ? '?'
        : trimmedUsername.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _DashboardHeader(
                  username: trimmedUsername,
                  avatarLetter: avatarLetter,
                ),
                const SizedBox(height: 28),
                const _MetricsGrid(),
                const SizedBox(height: 32),
                Text(
                  'Needs attention',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 14),
                _PaymentAlert(onTap: onPaymentReviewTap),
                const SizedBox(height: 32),
                Text(
                  'Today’s schedule',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 14),
                _TodaySchedule(schedule: _schedule, onTap: onScheduleTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.username, required this.avatarLetter});

  final String username;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, $username!',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontSize: 17, color: Colors.white),
              ),
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 38),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 34,
          backgroundColor: DesignTokens.studioYellow,
          foregroundColor: DesignTokens.cardText,
          child: Text(
            avatarLetter,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: DesignTokens.cardText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 980
            ? 4
            : width >= 640
            ? 3
            : 2;
        const spacing = 16.0;
        final tileWidth = (width - spacing * (columns - 1)) / columns;
        final revenueWidth = width < 560 ? width : tileWidth * 2 + spacing;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _MetricTile(
              key: const ValueKey('dashboard-metric-Monthly revenue'),
              width: revenueWidth,
              value: 'RM x,xxx',
              label: 'Monthly revenue',
              prominent: true,
            ),
            _MetricTile(
              key: const ValueKey('dashboard-metric-Total bookings'),
              width: tileWidth,
              value: '2',
              label: 'Total bookings',
            ),
            _MetricTile(
              key: const ValueKey('dashboard-metric-Pending request'),
              width: tileWidth,
              value: '4',
              label: 'Pending request',
              color: DesignTokens.alertPink,
            ),
            _MetricTile(
              key: const ValueKey('dashboard-metric-Confirmed'),
              width: tileWidth,
              value: '2',
              label: 'Confirmed',
            ),
            _MetricTile(
              key: const ValueKey('dashboard-metric-Completed'),
              width: tileWidth,
              value: '5',
              label: 'Completed',
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    super.key,
    required this.width,
    required this.value,
    required this.label,
    this.color = Colors.white,
    this.prominent = false,
  });

  final double width;
  final String value;
  final String label;
  final Color color;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DesignTokens.cardText,
                  fontSize: prominent ? 32 : 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: DesignTokens.cardText, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentAlert extends StatelessWidget {
  const _PaymentAlert({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignTokens.alertPink,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: DesignTokens.cardText,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment pending',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: DesignTokens.cardText,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3 payments need review',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: DesignTokens.cardText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: DesignTokens.cardText,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule({required this.schedule, required this.onTap});

  final List<DashboardScheduleItem> schedule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var index = 0; index < schedule.length; index++) ...[
              _ScheduleRow(item: schedule[index]),
              if (index < schedule.length - 1)
                const Divider(height: 20, color: Color(0xFFE6E6E6)),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF757575),
                  padding: EdgeInsets.zero,
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right),
                label: const Text('See full schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});

  final DashboardScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              item.time,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: DesignTokens.cardText),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DesignTokens.cardText,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.client,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: const Color(0xFF757575)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
