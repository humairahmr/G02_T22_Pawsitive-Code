import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

enum ReviewCategory { wedding, maternity, preWed, convocation }

@immutable
class AdminReview {
  const AdminReview({
    required this.id,
    required this.customerName,
    required this.category,
    required this.session,
    required this.date,
    required this.rating,
    required this.review,
    required this.isPublic,
    this.adminReply,
  });

  final String id;
  final String customerName;
  final ReviewCategory category;
  final String session;
  final String date;
  final int rating;
  final String review;
  final bool isPublic;
  final String? adminReply;
}

const sampleAdminReviews = [
  AdminReview(
    id: 'review-fong',
    customerName: 'Fong',
    category: ReviewCategory.maternity,
    session: 'Maternity Photo',
    date: '28 August 2026',
    rating: 5,
    review: 'I felt comfortable the whole time.',
    isPublic: true,
  ),
  AdminReview(
    id: 'review-siti',
    customerName: 'Siti',
    category: ReviewCategory.wedding,
    session: 'Wedding Photo',
    date: '30 August 2026',
    rating: 3,
    review:
        'I felt uncomfortable the whole time and the price is too expensive.',
    isPublic: false,
    adminReply: 'Thank you, Siti for your review.',
  ),
];

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({
    super.key,
    this.reviews = sampleAdminReviews,
    this.onBack,
    this.onReplySelected,
    this.onPublicProfileChanged,
  });

  final List<AdminReview> reviews;
  final VoidCallback? onBack;
  final ValueChanged<AdminReview>? onReplySelected;
  final void Function(AdminReview review, bool isPublic)?
  onPublicProfileChanged;

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  ReviewCategory? _selectedCategory;
  final _publicVisibility = <String, bool>{};

  static const _filters = [
    (null, 'ALL'),
    (ReviewCategory.wedding, 'Wedding'),
    (ReviewCategory.maternity, 'Maternity'),
    (ReviewCategory.preWed, 'Pre-Wed'),
    (ReviewCategory.convocation, 'Convocation'),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleReviews = _selectedCategory == null
        ? widget.reviews
        : widget.reviews
              .where((review) => review.category == _selectedCategory)
              .toList();

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
                ScreenHeader(
                  title: 'Reviews',
                  fallbackLocation: '/admin/dashboard',
                  onBack: widget.onBack,
                ),
                const SizedBox(height: 28),
                const _RatingSummaryCard(),
                const SizedBox(height: 28),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final (category, label) in _filters) ...[
                        _ReviewFilterChip(
                          label: label,
                          selected: _selectedCategory == category,
                          onSelected: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                        if (category != ReviewCategory.convocation)
                          const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (visibleReviews.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No reviews in this category yet.',
                        style: TextStyle(color: DesignTokens.cardText),
                      ),
                    ),
                  )
                else
                  for (final review in visibleReviews) ...[
                    _ReviewCard(
                      review: review,
                      isPublic: _publicVisibility[review.id] ?? review.isPublic,
                      onReplySelected: widget.onReplySelected,
                      onPublicProfileChanged: (value) {
                        setState(() {
                          _publicVisibility[review.id] = value;
                        });
                        widget.onPublicProfileChanged?.call(review, value);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  const _RatingSummaryCard();

  static const _categoryScores = [
    ('Wedding', 4.9),
    ('Maternity', 3.8),
    ('Pre-Wed', 4.8),
    ('Convocation', 5.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scoreBreakdown = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (category, score) in _categoryScores)
                  _CategoryScoreRow(category: category, score: score),
              ],
            );
            final overallScore = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '4.5',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: DesignTokens.cardText,
                    fontSize: 68,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star,
                  color: DesignTokens.studioYellow,
                  size: 32,
                ),
              ],
            );
            final reviewCount = DecoratedBox(
              decoration: const ShapeDecoration(
                color: DesignTokens.cardText,
                shape: StadiumBorder(),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  '653 reviews',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );

            if (constraints.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  overallScore,
                  reviewCount,
                  const SizedBox(height: 16),
                  scoreBreakdown,
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 142,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [overallScore, reviewCount],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: scoreBreakdown),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryScoreRow extends StatelessWidget {
  const _CategoryScoreRow({required this.category, required this.score});

  final String category;
  final double score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              category,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: score / 5,
                minHeight: 5,
                backgroundColor: const Color(0xFFE8E8E8),
                color: DesignTokens.studioYellow,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              score.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewFilterChip extends StatelessWidget {
  const _ReviewFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? DesignTokens.studioYellow : const Color(0xFF48453F),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? DesignTokens.cardText : Colors.white,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isPublic,
    required this.onReplySelected,
    required this.onPublicProfileChanged,
  });

  final AdminReview review;
  final bool isPublic;
  final ValueChanged<AdminReview>? onReplySelected;
  final ValueChanged<bool> onPublicProfileChanged;

  @override
  Widget build(BuildContext context) {
    final hasReply = review.adminReply?.trim().isNotEmpty ?? false;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    review.customerName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: DesignTokens.cardText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StarRating(rating: review.rating),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${review.session} - ${review.date}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF858585), fontSize: 14),
            ),
            const SizedBox(height: 14),
            Text(
              '"${review.review}"',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: DesignTokens.cardText, height: 1.4),
            ),
            if (hasReply) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2BF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Your reply: ${review.adminReply}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.cardText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: DesignTokens.studioYellow),
            LayoutBuilder(
              builder: (context, constraints) {
                final replyButton = TextButton.icon(
                  onPressed: () => onReplySelected?.call(review),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.cardText,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(
                    hasReply ? Icons.edit_outlined : Icons.reply,
                    size: 18,
                  ),
                  label: Text(hasReply ? 'Edit Reply' : 'Reply'),
                );
                final profileSwitch = MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Switch.adaptive(
                    value: isPublic,
                    onChanged: onPublicProfileChanged,
                    activeTrackColor: DesignTokens.studioYellow,
                    activeThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFB0B0B0),
                    inactiveThumbColor: const Color(0xFF555555),
                  ),
                );
                final profileLabel = Text(
                  'Show on public profile',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFF858585), fontSize: 13),
                );

                if (constraints.maxWidth < 440) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: replyButton,
                      ),
                      Row(
                        children: [
                          Expanded(child: profileLabel),
                          profileSwitch,
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    replyButton,
                    const Spacer(),
                    profileLabel,
                    const SizedBox(width: 4),
                    profileSwitch,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
        return Semantics(
      label: 'Rated $rating out of 5 stars',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 1; index <= 5; index++)
                Icon(
                  Icons.star,
                  size: 20,
                  color: index <= rating
                      ? DesignTokens.studioYellow
                      : const Color(0xFFBDBDBD),
                ),
            ],
          ),
          Text(
            'Rated ${rating.toStringAsFixed(1)}/5.0 by users',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
