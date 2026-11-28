import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';

enum ScheduleStatus { confirmed, unpaid, pendingVerification }

@immutable
class ScheduleEntry {
  const ScheduleEntry({
    required this.date,
    required this.sessionType,
    required this.client,
    required this.photographer,
    required this.status,
    this.time,
  });

  final DateTime date;
  final String? time; // e.g. '08:00 AM'. Null for "action" items.
  final String sessionType;
  final String client;
  final String photographer;
  final ScheduleStatus status;

  bool get needsAction => status != ScheduleStatus.confirmed;
}

/// Placeholder data until the real backend exists.
final sampleScheduleEntries = [
  ScheduleEntry(
    date: DateTime(2026, 12, 5),
    time: '10:00 AM',
    sessionType: 'Maternity',
    client: 'Siti',
    photographer: 'Miri',
    status: ScheduleStatus.confirmed,
  ),
  ScheduleEntry(
    date: DateTime(2026, 12, 12),
    time: '08:00 AM',
    sessionType: 'Graduation',
    client: 'Ros',
    photographer: 'Miri',
    status: ScheduleStatus.confirmed,
  ),
  ScheduleEntry(
    date: DateTime(2026, 12, 12),
    time: '11:00 AM',
    sessionType: 'Wedding',
    client: 'Umang',
    photographer: 'Miri',
    status: ScheduleStatus.confirmed,
  ),
  ScheduleEntry(
    date: DateTime(2026, 12, 13),
    sessionType: 'Graduation',
    client: 'Ros',
    photographer: 'Miri',
    status: ScheduleStatus.unpaid,
  ),
  ScheduleEntry(
    date: DateTime(2026, 12, 13),
    sessionType: 'Wedding',
    client: 'Umang',
    photographer: 'Miri',
    status: ScheduleStatus.pendingVerification,
  ),
  ScheduleEntry(
    date: DateTime(2026, 12, 19),
    time: '09:00 AM',
    sessionType: 'Pre-Wed',
    client: 'Fong',
    photographer: 'Miri',
    status: ScheduleStatus.confirmed,
  ),
];

final sampleBlockedDays = {DateTime(2026, 12, 25), DateTime(2026, 12, 26)};

const _red = Color(0xFFC0392B);
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _shortMonth(int m) => _months[m - 1].substring(0, 3);

String _dayLabel(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_shortMonth(d.month)}';

enum _ScheduleView { month, week, day }

class AdminScheduleScreen extends StatefulWidget {
  AdminScheduleScreen({
    super.key,
    List<ScheduleEntry>? entries,
    Set<DateTime>? blockedDays,
    DateTime? initialDate,
    this.onEntrySelected,
  }) : entries = entries ?? sampleScheduleEntries,
       blockedDays = blockedDays ?? sampleBlockedDays,
       initialDate = initialDate ?? DateTime(2026, 12, 12);

  final List<ScheduleEntry> entries;
  final Set<DateTime> blockedDays;
  final DateTime initialDate;
  final ValueChanged<ScheduleEntry>? onEntrySelected;

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  _ScheduleView _view = _ScheduleView.month;
  late DateTime _selected = widget.initialDate;
  late DateTime _month = DateTime(_selected.year, _selected.month);

  List<ScheduleEntry> _entriesFor(DateTime d) =>
      widget.entries.where((e) => _sameDay(e.date, d)).toList();

  bool _isBlocked(DateTime d) => widget.blockedDays.any((b) => _sameDay(b, d));

  void _select(DateTime d) => setState(() {
    _selected = d;
    _month = DateTime(d.year, d.month);
  });

  void _shiftMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    setState(() {
      _month = next;
      _selected = next;
    });
  }

  void _shiftDays(int days) => _select(_selected.add(Duration(days: days)));

  @override
  Widget build(BuildContext context) {
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
                  title: 'Schedule',
                  fallbackLocation: '/admin/dashboard',
                ),
                const SizedBox(height: 20),
                _ViewSwitcher(
                  view: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
                const SizedBox(height: 20),
                switch (_view) {
                  _ScheduleView.month => _buildMonth(),
                  _ScheduleView.week => _buildWeek(),
                  _ScheduleView.day => _buildDay(),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Month ---------------------------------------------------------------

  Widget _buildMonth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthCalendar(
          month: _month,
          selected: _selected,
          entriesFor: _entriesFor,
          isBlocked: _isBlocked,
          onSelect: _select,
          onPrev: () => _shiftMonth(-1),
          onNext: () => _shiftMonth(1),
        ),
        const SizedBox(height: 24),
        _DaySection(
          date: _selected,
          entries: _entriesFor(_selected),
          blocked: _isBlocked(_selected),
          onEntrySelected: widget.onEntrySelected,
        ),
      ],
    );
  }

  // ---- Week ----------------------------------------------------------------

  Widget _buildWeek() {
    final monday = DateTime(
      _selected.year,
      _selected.month,
      _selected.day - (_selected.weekday - 1),
    );
    final sunday = monday.add(const Duration(days: 6));
    final title = monday.month == sunday.month
        ? '${monday.day} – ${sunday.day} ${_shortMonth(sunday.month)} ${sunday.year}'
        : '${monday.day} ${_shortMonth(monday.month)} – '
              '${sunday.day} ${_shortMonth(sunday.month)} ${sunday.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RangeHeader(
          title: title,
          onPrev: () => _shiftDays(-7),
          onNext: () => _shiftDays(7),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < 7; i++) ...[
          _DaySection(
            date: monday.add(Duration(days: i)),
            entries: _entriesFor(monday.add(Duration(days: i))),
            blocked: _isBlocked(monday.add(Duration(days: i))),
            onEntrySelected: widget.onEntrySelected,
            compact: true,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // ---- Day -----------------------------------------------------------------

  Widget _buildDay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RangeHeader(
          title: '${_dayLabel(_selected)} ${_selected.year}',
          onPrev: () => _shiftDays(-1),
          onNext: () => _shiftDays(1),
        ),
        const SizedBox(height: 16),
        _DaySection(
          date: _selected,
          entries: _entriesFor(_selected),
          blocked: _isBlocked(_selected),
          onEntrySelected: widget.onEntrySelected,
        ),
      ],
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.view, required this.onChanged});

  final _ScheduleView view;
  final ValueChanged<_ScheduleView> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _ScheduleView.month: 'Month',
      _ScheduleView.week: 'Week',
      _ScheduleView.day: 'Day',
    };
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF48453F),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          for (final entry in labels.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: view == entry.key,
                child: GestureDetector(
                  onTap: () => onChanged(entry.key),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: view == entry.key
                          ? DesignTokens.studioYellow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: view == entry.key
                            ? DesignTokens.cardText
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

class _RangeHeader extends StatelessWidget {
  const _RangeHeader({
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous',
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: 'Next',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.selected,
    required this.entriesFor,
    required this.isBlocked,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final DateTime selected;
  final List<ScheduleEntry> Function(DateTime) entriesFor;
  final bool Function(DateTime) isBlocked;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month, 1).weekday - 1;
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${_months[month.month - 1]} ${month.year}',
                    style: const TextStyle(
                      color: DesignTokens.cardText,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Previous month',
                onPressed: onPrev,
                icon: const Icon(
                  Icons.chevron_left,
                  color: DesignTokens.cardText,
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: onNext,
                icon: const Icon(
                  Icons.chevron_right,
                  color: DesignTokens.cardText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final d in const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        color: Color(0xFF858585),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var row = 0; row < cells.length ~/ 7; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      date: cells[row * 7 + col],
                      selected:
                          cells[row * 7 + col] != null &&
                          _sameDay(cells[row * 7 + col]!, selected),
                      blocked:
                          cells[row * 7 + col] != null &&
                          isBlocked(cells[row * 7 + col]!),
                      entries: cells[row * 7 + col] == null
                          ? const []
                          : entriesFor(cells[row * 7 + col]!),
                      onTap: onSelect,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _LegendDot(color: DesignTokens.studioYellow, label: 'Selected'),
              _LegendDot(color: DesignTokens.confirmedGreen, label: 'Booked'),
              _LegendDot(color: _red, label: 'Action'),
              _LegendDot(color: Color(0xFFD9D9D9), label: 'Blocked'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.blocked,
    required this.entries,
    required this.onTap,
  });

  final DateTime? date;
  final bool selected;
  final bool blocked;
  final List<ScheduleEntry> entries;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox(height: 62);

    final hasAction = entries.any((e) => e.needsAction);
    final dotColor = hasAction
        ? _red
        : entries.isNotEmpty
        ? DesignTokens.confirmedGreen
        : null;

    final bg = selected
        ? DesignTokens.studioYellow
        : blocked
        ? const Color(0xFFD9D9D9)
        : Colors.transparent;
    final fg = blocked && !selected
        ? const Color(0xFF858585)
        : DesignTokens.cardText;

    return InkWell(
      onTap: () => onTap(date!),
      customBorder: const CircleBorder(),
      child: SizedBox(
        height: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Text(
                '${date!.day}',
                style: TextStyle(
                  color: fg,
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 7,
              child: dotColor == null
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 7, height: 7),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF858585))),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.date,
    required this.entries,
    required this.blocked,
    required this.onEntrySelected,
    this.compact = false,
  });

  final DateTime date;
  final List<ScheduleEntry> entries;
  final bool blocked;
  final ValueChanged<ScheduleEntry>? onEntrySelected;
  final bool compact;

  String get _countLabel {
    if (blocked) return 'Blocked';
    if (entries.isEmpty) return 'No bookings';
    if (entries.every((e) => e.needsAction)) return '${entries.length} action';
    return entries.length == 1 ? '1 booking' : '${entries.length} bookings';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]
      ..sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _dayLabel(date),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 18 : 24,
                ),
              ),
            ),
            Text(_countLabel, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        if (sorted.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  _EntryTile(
                    entry: sorted[i],
                    onTap: onEntrySelected == null
                        ? null
                        : () => onEntrySelected!(sorted[i]),
                  ),
                  if (i < sorted.length - 1)
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, this.onTap});

  final ScheduleEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            if (entry.time != null)
              SizedBox(
                width: 106,
                child: Text(
                  entry.time!,
                  style: const TextStyle(
                    color: Color(0xFF858585),
                    fontSize: 17,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.sessionType,
                    style: const TextStyle(
                      color: DesignTokens.cardText,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    '${entry.client} · ${entry.photographer}',
                    style: const TextStyle(
                      color: Color(0xFF858585),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(status: entry.status),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ScheduleStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case ScheduleStatus.confirmed:
        label = 'Confirmed';
        bg = DesignTokens.confirmedGreen;
        fg = Colors.white;
      case ScheduleStatus.unpaid:
        label = 'Unpaid';
        bg = _red;
        fg = Colors.white;
      case ScheduleStatus.pendingVerification:
        label = 'Pending verification';
        bg = DesignTokens.studioYellow;
        fg = DesignTokens.cardText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
