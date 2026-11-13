import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    this.name = 'Dayang',
    this.email = 'xxxx@gmail.com',
    this.phone = '+60 xx-xxxxxxx',
  });

  final String name;
  final String email;
  final String phone;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _bookingReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
              children: [
                const ScreenHeader(
                  title: 'Profile',
                  fallbackLocation: '/customer/home',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: DesignTokens.studioYellow,
                      foregroundColor: DesignTokens.cardText,
                      child: Text(
                        widget.name.isEmpty
                            ? 'D'
                            : widget.name[0].toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: DesignTokens.cardText,
                          fontSize: 38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _ProfileContactCard(phone: widget.phone, email: widget.email),
                const SizedBox(height: 28),
                Text(
                  'Upcoming shoots',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 12),
                const _UpcomingShootCard(),
                const SizedBox(height: 28),
                Text(
                  'Settings',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _ProfileSettingRow(
                        icon: Icons.person_outline,
                        label: 'Personal details',
                        onTap: () => _showMessage('Personal details'),
                      ),
                      _ProfileSettingRow(
                        icon: Icons.favorite_border,
                        label: 'Saved',
                        onTap: () => _showMessage('Saved photoshoots'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              color: DesignTokens.cardText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Booking reminder',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: DesignTokens.cardText,
                                ),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Switch.adaptive(
                                value: _bookingReminderEnabled,
                                activeTrackColor: DesignTokens.studioYellow,
                                activeThumbColor: DesignTokens.cardText,
                                onChanged: (value) {
                                  setState(() {
                                    _bookingReminderEnabled = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Stay connected',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _SocialLinkRow(
                        label: 'Facebook',
                        icon: Icons.facebook,
                        onTap: () => _openSocialLink(
                          Uri.parse('https://www.facebook.com/'),
                        ),
                      ),
                      _SocialLinkRow(
                        label: 'Instagram',
                        icon: Icons.camera_alt_outlined,
                        onTap: () => _openSocialLink(
                          Uri.parse('https://www.instagram.com/'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label is coming soon.')));
  }

  Future<void> _openSocialLink(Uri uri) async {
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this social link.')),
      );
    }
  }
}

class _ProfileContactCard extends StatelessWidget {
  const _ProfileContactCard({required this.phone, required this.email});

  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            _ContactLine(label: 'Phone', value: phone),
            _ContactLine(label: 'Email', value: email),
          ],
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF858585)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.cardText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingShootCard extends StatelessWidget {
  const _UpcomingShootCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 62,
                  height: 72,
                  decoration: BoxDecoration(
                    color: DesignTokens.studioYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Oct',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: DesignTokens.cardText),
                      ),
                      Text(
                        '2',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: DesignTokens.cardText,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portrait session',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: DesignTokens.cardText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sat · 16:30 · Studio',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: const Color(0xFF858585)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.confirmedGreen,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Confirmed',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFB7B0A9)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking details are coming soon.'),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF858585),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right),
                label: const Text('See details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSettingRow extends StatelessWidget {
  const _ProfileSettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: DesignTokens.cardText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: DesignTokens.cardText),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: DesignTokens.cardText,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLinkRow extends StatelessWidget {
  const _SocialLinkRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: DesignTokens.cardText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DesignTokens.cardText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: DesignTokens.cardText,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
