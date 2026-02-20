import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<DateTime> _availableDays = {};
  final Set<DateTime> _unavailableDays = {};

  void _toggleDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    if (_availableDays.contains(normalized)) {
      setState(() {
        _availableDays.remove(normalized);
        _unavailableDays.add(normalized);
      });
    } else if (_unavailableDays.contains(normalized)) {
      setState(() {
        _unavailableDays.remove(normalized);
      });
    } else {
      setState(() {
        _availableDays.add(normalized);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Availability'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Availability saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                  _toggleDay(selected);
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, focusedDay) {
                  final normalized = DateTime(day.year, day.month, day.day);
                  Color? bgColor;
                  if (_availableDays.contains(normalized)) {
                    bgColor = AppColors.success.withValues(alpha: 0.3);
                  } else if (_unavailableDays.contains(normalized)) {
                    bgColor = AppColors.error.withValues(alpha: 0.3);
                  }

                  if (bgColor == null) return null;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                weekendTextStyle: const TextStyle(
                  color: AppColors.textSecondary,
                ),
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.success, label: 'Available'),
                const SizedBox(width: 24),
                _LegendDot(color: AppColors.error, label: 'Unavailable'),
                const SizedBox(width: 24),
                _LegendDot(color: AppColors.surfaceVariant, label: 'Not set'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tap a date to set it as Available → Unavailable → Not Set',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
