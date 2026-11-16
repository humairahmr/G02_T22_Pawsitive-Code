import 'package:flutter/material.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';
import 'customer_calendar.dart';

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key, this.initialSessionType});

  final String? initialSessionType;

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  static const _sessionTypes = [
    'Maternity',
    'Wedding',
    'Pre-Wed',
    'Convocation',
  ];
  static const _locations = ['Outdoor', 'Indoor'];
  static const _times = ['Morning', 'Golden Hour', 'Evening'];

  late String _sessionType;
  String _location = 'Outdoor';
  String _timeOfDay = 'Morning';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _sessionType = _sessionTypes.contains(widget.initialSessionType)
        ? widget.initialSessionType!
        : _sessionTypes.first;
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
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              children: [
                const ScreenHeader(
                  title: 'Booking',
                  fallbackLocation: '/customer/home',
                ),
                Text(
                  'Start planning your book with us!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                _BookingStep(
                  number: 1,
                  title: 'Type of photoshoot',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in _sessionTypes)
                        _BookingChoiceChip(
                          label: type,
                          selected: _sessionType == type,
                          onSelected: () => setState(() => _sessionType = type),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _BookingStep(
                  number: 2,
                  title: 'What kind of location do you prefer?',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setting',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color.fromARGB(0, 200, 181, 9),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final location in _locations)
                            _BookingChoiceChip(
                              label: location,
                              selected: _location == location,
                              onSelected: () =>
                                  setState(() => _location = location),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Time of day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final time in _times)
                            _BookingChoiceChip(
                              label: time,
                              selected: _timeOfDay == time,
                              onSelected: () =>
                                  setState(() => _timeOfDay = time),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _AiDayFinderCard(
                  sessionType: _sessionType,
                  timeOfDay: _timeOfDay,
                ),
                const SizedBox(height: 20),
                CustomerCalendar(
                  showAvailabilityLegend: true,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = date);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BookingConfirmationBar(
        selectedDate: _selectedDate,
        onConfirm: () => _confirmBooking(context),
      ),
    );
  }

  void _confirmBooking(BuildContext context) {
    final date = _selectedDate;
    if (date == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${_formatDate(date)} for your booking.'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _BookingStep extends StatelessWidget {
  const _BookingStep({
    required this.number,
    required this.title,
    required this.child,
  });

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: DesignTokens.studioYellow,
          foregroundColor: DesignTokens.cardText,
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: DesignTokens.cardText, fontSize: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingChoiceChip extends StatelessWidget {
  const _BookingChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: selected ? DesignTokens.cardText : Colors.white,
          letterSpacing: 1,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: DesignTokens.studioYellow,
      backgroundColor: const Color(0xFF48453F),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

class _AiDayFinderCard extends StatelessWidget {
  const _AiDayFinderCard({required this.sessionType, required this.timeOfDay});

  final String sessionType;
  final String timeOfDay;

  String get _recommendedTime => switch (timeOfDay) {
    'Golden Hour' => '5:30 p.m.',
    'Evening' => '7:00 p.m.',
    _ => '8:00 a.m.',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A463D),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AI day finder',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.auto_awesome,
                color: DesignTokens.studioYellow,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: Colors.white, height: 1.5),
              children: [
                const TextSpan(text: 'Best day for your '),
                TextSpan(
                  text: '$timeOfDay $sessionType',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      ' photo session is around $_recommendedTime. We marked suggested dates in green.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingConfirmationBar extends StatelessWidget {
  const _BookingConfirmationBar({
    required this.selectedDate,
    required this.onConfirm,
  });

  final DateTime? selectedDate;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDate != null;
    final dateLabel = isSelected
        ? '${selectedDate!.day} ${_monthName(selectedDate!.month)} ${selectedDate!.year}'
        : 'Choose your date to continue';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your booking',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: DesignTokens.cardText, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? DesignTokens.cardText
                          : const Color(0xFF858585),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 130,
              height: 54,
              child: FilledButton(
                onPressed: isSelected ? onConfirm : null,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.studioYellow,
                  foregroundColor: DesignTokens.cardText,
                  disabledBackgroundColor: const Color(0xFFD8D8D8),
                  disabledForegroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Confirm',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
