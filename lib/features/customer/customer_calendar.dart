import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

class CustomerCalendar extends StatefulWidget {
  const CustomerCalendar({
    super.key,
    this.initialDate,
    this.compact = false,
    this.showAvailabilityLegend = false,
    this.onDateSelected,
  });

  final DateTime? initialDate;
  final bool compact;
  final bool showAvailabilityLegend;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  State<CustomerCalendar> createState() => _CustomerCalendarState();
}

class _CustomerCalendarState extends State<CustomerCalendar> {
  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _months = [
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
  static const _fullyBookedDays = {6, 7, 13};
  static const _aiPickDays = {9, 15, 17};

  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.initialDate ?? DateTime(2026, 10, 1);
    _visibleMonth = DateTime(initialDate.year, initialDate.month);
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstWeekday = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
    ).weekday;
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final itemCount = ((firstWeekday - 1 + daysInMonth + 6) ~/ 7) * 7;
    final padding = widget.compact ? 14.0 : 20.0;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: DesignTokens.cardText,
                      fontSize: widget.compact ? 20 : 24,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  tooltip: 'Previous month',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_left),
                  color: DesignTokens.cardText,
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  tooltip: 'Next month',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_right),
                  color: DesignTokens.cardText,
                ),
              ],
            ),
            if (widget.showAvailabilityLegend) ...[
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _LegendItem(
                    color: const Color(0xFFD8D8D8),
                    label: 'Fully booked',
                  ),
                  _LegendItem(
                    color: DesignTokens.studioYellow,
                    label: 'Today',
                  ),
                  _LegendItem(
                    color: DesignTokens.confirmedGreen,
                    label: 'AI pick',
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                for (final weekday in _weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.cardText,
                          fontWeight: FontWeight.w600,
                          fontSize: widget.compact ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: widget.compact ? 36 : 46,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final day = index - firstWeekday + 2;
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  day,
                );
                return _buildDay(context, date);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(BuildContext context, DateTime date) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isFullyBooked =
        widget.showAvailabilityLegend &&
        date.year == _visibleMonth.year &&
        date.month == _visibleMonth.month &&
        _fullyBookedDays.contains(date.day);
    final isAiPick =
        widget.showAvailabilityLegend &&
        date.year == _visibleMonth.year &&
        date.month == _visibleMonth.month &&
        _aiPickDays.contains(date.day);

    final backgroundColor = isSelected || isToday
        ? DesignTokens.studioYellow
        : isFullyBooked
        ? const Color(0xFFD8D8D8)
        : isAiPick
        ? DesignTokens.confirmedGreen
        : Colors.transparent;
    final foregroundColor = isSelected || isToday
        ? DesignTokens.cardText
        : isAiPick
        ? Colors.white
        : const Color(0xFF666666);

    return Center(
      child: Semantics(
        button: !isFullyBooked,
        selected: isSelected,
        label: '${_months[date.month - 1]} ${date.day}, ${date.year}',
        child: InkWell(
          onTap: isFullyBooked ? null : () => _selectDate(date),
          customBorder: const CircleBorder(),
          child: Container(
            width: widget.compact ? 32 : 40,
            height: widget.compact ? 32 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: DesignTokens.studioYellow, width: 2)
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontSize: widget.compact ? 13 : 15,
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  bool _isSameDay(DateTime first, DateTime? second) {
    return second != null &&
        first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: DesignTokens.cardText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
