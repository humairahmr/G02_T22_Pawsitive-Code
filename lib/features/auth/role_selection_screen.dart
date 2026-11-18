import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

enum UserRole { customer, admin }

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.onRoleSelected});

  final ValueChanged<UserRole>? onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewportConstraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LayoutBuilder(
                      builder: (context, contentConstraints) {
                        final isWide = contentConstraints.maxWidth >= 800;

                        // Width of one card, used to decide the compact layout.
                        final cardWidth = isWide
                            ? (contentConstraints.maxWidth - 24) / 2
                            : contentConstraints.maxWidth;
                        final isCompact = cardWidth < 320;

                        final customerCard = _RoleCard(
                          title: 'Customer',
                          description: 'Browse styles, check dates and book your photoshoot',
                          icon: Icons.account_circle_outlined,
                          isCompact: isCompact,
                          minHeight: isWide ? 0 : 200,
                          onTap: () => onRoleSelected?.call(UserRole.customer),
                        );
                        final adminCard = _RoleCard(
                          title: 'Admin',
                          description: 'Manage orders, calendar and customers',
                          icon: Icons.manage_accounts_outlined,
                          requiresPassword: true,
                          isCompact: isCompact,
                          minHeight: isWide ? 0 : 200,
                          onTap: () => onRoleSelected?.call(UserRole.admin),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 44),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'How would you like to continue?',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 48),
                              if (isWide)
                                // IntrinsicHeight + stretch makes both cards
                                // the same height (the taller one wins).
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: customerCard),
                                      const SizedBox(width: 24),
                                      Expanded(child: adminCard),
                                    ],
                                  ),
                                )
                              else ...[
                                customerCard,
                                const SizedBox(height: 24),
                                adminCard,
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.isCompact,
    this.minHeight = 0,
    this.requiresPassword = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isCompact;
  final double minHeight;
  final bool requiresPassword;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  // Active = mouse is over the card OR it is being pressed (touch screens).
  bool get _isActive => _isHovered || _isPressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;

    // Not active: white card, black circle, white arrow.
    // Active:     yellow card, white circle, black arrow.
    final cardColor = _isActive ? DesignTokens.studioYellow : Colors.white;
    final circleColor = _isActive ? Colors.white : DesignTokens.cardText;
    final arrowColor = _isActive ? DesignTokens.cardText : Colors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(minHeight: widget.minHeight),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _isActive
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _isPressed = value),
            borderRadius: BorderRadius.circular(28),
            splashColor: DesignTokens.studioYellow.withValues(alpha: 0.2),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 16 : 24),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: isCompact ? 64 : 88,
                    color: DesignTokens.cardText,
                  ),
                  SizedBox(width: isCompact ? 12 : 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: isCompact ? 24 : 32,
                                color: DesignTokens.cardText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: DesignTokens.cardText,
                                fontSize: isCompact ? 15 : 17,
                                height: 1.4,
                              ),
                        ),
                        if (widget.requiresPassword) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: DesignTokens.cardText,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Admin password required',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: DesignTokens.cardText,
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: isCompact ? 8 : 16),
                  CircleAvatar(
                    radius: isCompact ? 18 : 22,
                    backgroundColor: circleColor,
                    child: Icon(
                      Icons.chevron_right,
                      size: isCompact ? 24 : 28,
                      color: arrowColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
