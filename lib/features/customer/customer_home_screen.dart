import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/design_tokens.dart';
import 'customer_calendar.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    this.username = 'Username',
    this.avatarInitial = 'D',
  });

  final String username;
  final String avatarInitial;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  static const _promotions = [
    ('Make it timeless', Icons.favorite_outline, Color(0xFF465047)),
    ('Every frame tells a story', Icons.camera_alt_outlined, Color(0xFF70594A)),
    ('Memories to keep', Icons.auto_awesome_outlined, Color(0xFF5C5360)),
  ];

  static const _categories = [
    ('Wedding', Icons.favorite, Color(0xFF786256), Color(0xFF352C29)),
    ('Maternity', Icons.child_friendly, Color(0xFF7C8B6B), Color(0xFF3B4A3C)),
    ('Graduation', Icons.school, Color(0xFF5C7882), Color(0xFF283D49)),
  ];

  final _bannerController = PageController(viewportFraction: 1);
  int _currentBanner = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning, ${widget.username}!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Capture your moments',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: DesignTokens.studioYellow,
                      foregroundColor: DesignTokens.cardText,
                      child: Text(
                        widget.avatarInitial,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: DesignTokens.cardText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 164,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: _promotions.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBanner = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final promotion = _promotions[index];
                      return _PromotionCarouselCard(
                        title: promotion.$1,
                        icon: promotion.$2,
                        startColor: promotion.$3,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < _promotions.length; index++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: index == _currentBanner ? 18 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _currentBanner
                              ? DesignTokens.studioYellow
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Book for photoshoots',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var index = 0; index < _categories.length; index++) ...[
                      if (index > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _PhotoCategoryCard(
                          title: _categories[index].$1,
                          icon: _categories[index].$2,
                          startColor: _categories[index].$3,
                          endColor: _categories[index].$4,
                          onTap: () => context.go(
                            '/customer/booking?category=${Uri.encodeQueryComponent(_categories[index].$1)}',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                CustomerCalendar(
                  initialDate: DateTime(2026, 10, 8),
                  compact: true,
                ),
                const SizedBox(height: 22),
                const _MiniPortraitBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromotionCarouselCard extends StatelessWidget {
  const _PromotionCarouselCard({
    required this.title,
    required this.icon,
    required this.startColor,
  });

  final String title;
  final IconData icon;
  final Color startColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, const Color(0xFF1E2320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24,
            bottom: 8,
            child: Icon(
              icon,
              size: 130,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF17120E),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCategoryCard extends StatelessWidget {
  const _PhotoCategoryCard({
    required this.title,
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: startColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 142,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                top: 10,
                child: Icon(
                  icon,
                  size: 82,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                left: 12,
                right: 4,
                bottom: 12,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPortraitBanner extends StatelessWidget {
  const _MiniPortraitBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.alertPink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mini portrait weekend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: DesignTokens.cardText,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '15 - 27 Nov 2026',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.cardText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.photo_camera_back_outlined,
            size: 52,
            color: DesignTokens.cardText,
          ),
          IconButton(
            onPressed: () => context.go('/customer/booking'),
            tooltip: 'Book a mini portrait',
            color: DesignTokens.cardText,
            icon: const Icon(Icons.chevron_right, size: 30),
          ),
        ],
      ),
    );
  }
}
