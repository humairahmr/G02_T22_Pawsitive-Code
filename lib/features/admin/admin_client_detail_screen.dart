import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

@immutable
class ClientSession {
  const ClientSession({
    required this.title,
    required this.when,
    required this.completed,
    this.note,
    this.hasReceipt = false,
  });

  final String title;
  final String when;
  final bool completed;
  final String? note;
  final bool hasReceipt;
}

@immutable
class ClientReview {
  const ClientReview({
    required this.session,
    required this.when,
    required this.rating,
    required this.text,
    required this.isPublic,
  });

  final String session;
  final String when;
  final int rating;
  final String text;
  final bool isPublic;
}

@immutable
class ClientDetail {
  const ClientDetail({
    required this.name,
    required this.since,
    required this.phone,
    required this.email,
    required this.sessions,
    this.review,
  });

  final String name;
  final String since;
  final String phone;
  final String email;
  final List<ClientSession> sessions;
  final ClientReview? review;
}

/// Placeholder data until the real backend exists.
ClientDetail sampleClientDetail(String name) => ClientDetail(
  name: name,
  since: 'Aug 2026',
  phone: '+60 xx-xxxxxx',
  email: 'xxxxx@gmail.com',
  sessions: const [
    ClientSession(
      title: 'Wedding Photo',
      when: 'Sat · 16:30 · Studio',
      completed: false,
      note: 'FYI, I will bring along my 6 family members',
      hasReceipt: true,
    ),
    ClientSession(
      title: 'Graduation Photo',
      when: 'Sat · 13:30 · Studio',
      completed: true,
    ),
  ],
  review: const ClientReview(
    session: 'Wedding Photo',
    when: 'Sat · 16:30 · Studio',
    rating: 5,
    text: 'Calm, kind and so easy to work with. We loved every photo.',
    isPublic: true,
  ),
);

class AdminClientDetailScreen extends StatefulWidget {
  const AdminClientDetailScreen({
    super.key,
    required this.name,
    this.detail,
    this.onReply,
  });

  final String name;
  final ClientDetail? detail;
  final VoidCallback? onReply;

  @override
  State<AdminClientDetailScreen> createState() =>
      _AdminClientDetailScreenState();
}

class _AdminClientDetailScreenState extends State<AdminClientDetailScreen> {
  late final ClientDetail _detail =
      widget.detail ?? sampleClientDetail(widget.name);
  late bool _public = _detail.review?.isPublic ?? false;

  void _soon(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what will be connected later.')));
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final review = d.review;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const ScreenHeader(
                  title: 'Client Details',
                  fallbackLocation: '/admin/customers',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: DesignTokens.studioYellow,
                      child: Text(
                        d.name.isEmpty ? '?' : d.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: DesignTokens.cardText,
                          fontWeight: FontWeight.bold,
                          fontSize: 44,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 38,
                                ),
                          ),
                          Text('Customer since ${d.since}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _ActionTile(
                      icon: Icons.phone,
                      label: 'Call',
                      onTap: () => _soon('Calling'),
                    ),
                    const SizedBox(width: 12),
                    _ActionTile(
                      icon: Icons.chat_bubble,
                      label: 'Message',
                      onTap: () => _soon('Messaging'),
                    ),
                    const SizedBox(width: 12),
                    _ActionTile(
                      icon: Icons.email,
                      label: 'Email',
                      onTap: () => _soon('Email'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration,
                  child: Column(
                    children: [
                      _InfoRow(label: 'Phone', value: d.phone),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Email', value: d.email),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'History',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: _cardDecoration,
                  child: Column(
                    children: [
                      for (var i = 0; i < d.sessions.length; i++) ...[
                        _SessionTile(
                          session: d.sessions[i],
                          onReceipt: () => _soon('Receipt viewing'),
                        ),
                        if (i < d.sessions.length - 1)
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ],
                    ],
                  ),
                ),
                if (review != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.session,
                                    style: const TextStyle(
                                      color: DesignTokens.cardText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  Text(
                                    review.when,
                                    style: const TextStyle(
                                      color: Color(0xFF858585),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var i = 1; i <= 5; i++)
                                      Icon(
                                        Icons.star,
                                        size: 20,
                                        color: i <= review.rating
                                            ? DesignTokens.studioYellow
                                            : const Color(0xFFBDBDBD),
                                      ),
                                  ],
                                ),
                                Text(
                                  'Rated ${review.rating}.0/5.0 by users',
                                  style: const TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"${review.text}"',
                          style: const TextStyle(
                            color: DesignTokens.cardText,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 1,
                          color: DesignTokens.studioYellow,
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: widget.onReply,
                              style: TextButton.styleFrom(
                                foregroundColor: DesignTokens.cardText,
                                padding: EdgeInsets.zero,
                              ),
                              icon: const Icon(Icons.reply, size: 18),
                              label: const Text('Reply'),
                            ),
                            const Spacer(),
                            const Text(
                              'Show on public profile',
                              style: TextStyle(
                                color: Color(0xFF858585),
                                fontSize: 13,
                              ),
                            ),
                            Switch.adaptive(
                              value: _public,
                              onChanged: (v) => setState(() => _public = v),
                              activeTrackColor: DesignTokens.studioYellow,
                              activeThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFB0B0B0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(28),
);

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(icon, color: DesignTokens.studioYellow, size: 30),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: DesignTokens.cardText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF858585))),
        Text(
          value,
          style: const TextStyle(
            color: DesignTokens.cardText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onReceipt});

  final ClientSession session;
  final VoidCallback onReceipt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        color: DesignTokens.cardText,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      session.when,
                      style: const TextStyle(color: Color(0xFF858585)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: session.completed
                      ? const Color(0xFFB0B0B0)
                      : DesignTokens.confirmedGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  session.completed ? 'Completed' : 'Confirmed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (session.note != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Private notes',
                    style: TextStyle(
                      color: DesignTokens.cardText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    session.note!,
                    style: const TextStyle(
                      color: DesignTokens.cardText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (session.hasReceipt)
            InkWell(
              onTap: onReceipt,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, color: Color(0xFF858585)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'View uploaded receipt',
                        style: TextStyle(color: Color(0xFF858585)),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF858585)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
