import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/models/shift_model.dart';
import '../../../shared/data/repositories/shift_repository.dart';

class ClockInOutScreen extends ConsumerStatefulWidget {
  const ClockInOutScreen({super.key});

  @override
  ConsumerState<ClockInOutScreen> createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends ConsumerState<ClockInOutScreen> {
  bool _isClockedIn = false;
  DateTime? _clockInTime;

  String get _elapsed {
    if (_clockInTime == null) return '00:00:00';
    final diff = DateTime.now().difference(_clockInTime!);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _toggleClock(ShiftModel? activeShift) async {
    if (activeShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active shift to clock in for.')),
      );
      return;
    }
    final repo = ref.read(shiftRepositoryProvider);
    if (!_isClockedIn) {
      await repo.clockIn(activeShift.id);
      setState(() {
        _isClockedIn = true;
        _clockInTime = DateTime.now();
      });
    } else {
      await repo.clockOut(activeShift.id);
      setState(() {
        _isClockedIn = false;
        _clockInTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Clock In / Out')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isClockedIn
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isClockedIn ? AppColors.success : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color:
                        _isClockedIn ? AppColors.success : AppColors.textHint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isClockedIn ? 'On the Clock' : 'Off Duty',
                    style: TextStyle(
                      color: _isClockedIn
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms),

            const SizedBox(height: 48),

            // Timer
            Text(
              _elapsed,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ).animate().fade(duration: 500.ms),

            const SizedBox(height: 8),
            Text(
              _isClockedIn
                  ? 'Clocked in at ${DateFormat('HH:mm').format(_clockInTime!)}'
                  : 'Not currently clocked in',
              style: const TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 60),

            // Big clock button
            GestureDetector(
              onTap: () => _toggleClock(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isClockedIn ? AppColors.error : AppColors.success,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isClockedIn ? AppColors.error : AppColors.success)
                              .withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isClockedIn ? Icons.stop : Icons.fingerprint,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isClockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(
                  duration: 400.ms,
                  delay: 200.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 48),

            // Location info placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.info),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Geofence Check',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Location verified – within venue zone',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_outline, color: AppColors.success),
                ],
              ),
            ).animate().fade(duration: 400.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
