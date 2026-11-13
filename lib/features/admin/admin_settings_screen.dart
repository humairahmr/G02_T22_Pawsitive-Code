import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

enum BusinessManagementSection {
  packagesAndPrices,
  workingHours,
  offer,
  socialMedia,
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({
    super.key,
    this.accountName = 'ADMIN',
    this.accountLabel = 'Admin account',
    this.avatarInitial = 'D',
    this.phone = '+60 xx-xxxxxxx',
    this.email = 'xxxxx@gmail.com',
    this.onSectionSelected,
  });

  final String accountName;
  final String accountLabel;
  final String avatarInitial;
  final String phone;
  final String email;
  final ValueChanged<BusinessManagementSection>? onSectionSelected;

  static const _sections = [
    (
      BusinessManagementSection.packagesAndPrices,
      Icons.camera_alt_outlined,
      'Packages & prices',
      'Manage package prices',
    ),
    (
      BusinessManagementSection.workingHours,
      Icons.schedule_outlined,
      'Working hours',
      'Set available hours',
    ),
    (
      BusinessManagementSection.offer,
      Icons.percent,
      'Offer',
      'Manage offer prices',
    ),
    (
      BusinessManagementSection.socialMedia,
      Icons.link,
      'Social media',
      'Manage social accounts',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const ScreenHeader(
                  title: 'Setting',
                  fallbackLocation: '/admin/dashboard',
                ),
                const SizedBox(height: 32),
                _AccountHeader(
                  accountName: accountName,
                  accountLabel: accountLabel,
                  avatarInitial: avatarInitial,
                ),
                const SizedBox(height: 28),
                _ContactDetailsCard(phone: phone, email: email),
                const SizedBox(height: 36),
                Text(
                  'Business management',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      for (final (section, icon, title, subtitle) in _sections)
                        _ManagementItem(
                          icon: icon,
                          title: title,
                          subtitle: subtitle,
                          onTap: () => onSectionSelected?.call(section),
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
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.accountName,
    required this.accountLabel,
    required this.avatarInitial,
  });

  final String accountName;
  final String accountLabel;
  final String avatarInitial;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: DesignTokens.studioYellow,
          foregroundColor: DesignTokens.cardText,
          child: Text(
            avatarInitial,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: DesignTokens.cardText,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                accountName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                accountLabel,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactDetailsCard extends StatelessWidget {
  const _ContactDetailsCard({required this.phone, required this.email});

  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            _ContactDetailRow(label: 'Phone', value: phone),
            const SizedBox(height: 8),
            _ContactDetailRow(label: 'Email', value: email),
          ],
        ),
      ),
    );
  }
}

class _ContactDetailRow extends StatelessWidget {
  const _ContactDetailRow({required this.label, required this.value});

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
                  ?.copyWith(color: const Color(0xFF858585), fontSize: 15),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.cardText,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementItem extends StatelessWidget {
  const _ManagementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: DesignTokens.cardText, size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: DesignTokens.cardText, fontSize: 17),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Color(0xFF858585), fontSize: 13),
                  ),
                ],
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
