import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../shared/data/models/shift_model.dart';
import '../../../shared/data/repositories/shift_repository.dart';

final staffShiftsProvider = StreamProvider.family<List<ShiftModel>, String>((
  ref,
  staffId,
) {
  return ref.watch(shiftRepositoryProvider).getStaffShifts(staffId);
});

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final shiftsAsync = user != null
        ? ref.watch(staffShiftsProvider(user.id))
        : const AsyncValue<List<ShiftModel>>.data([]);

    final upcomingShifts = shiftsAsync.maybeWhen(
      data: (shifts) => shifts.where((s) => s.isFuture || s.isToday).toList(),
      orElse: () => <ShiftModel>[],
    );

    ShiftModel? activeShift = shiftsAsync.maybeWhen(
      data: (shifts) {
        try {
          return shifts.firstWhere((s) => s.isActive);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, ${user?.fullName.split(' ').first ?? 'there'} 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.go(AppRoutes.notifications),
                icon: const Icon(Icons.notifications_outlined),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () => context.push(AppRoutes.profile),
                  borderRadius: BorderRadius.circular(18),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.staff,
                    child: Text(
                      (user?.fullName.isNotEmpty == true)
                          ? user!.fullName.substring(0, 1).toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.screenPaddingH),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active shift card (if any)
                if (activeShift != null)
                  _ActiveShiftCard(
                    shift: activeShift,
                  ).animate().fade(duration: 400.ms).slideY(begin: -0.1),

                if (activeShift != null) const SizedBox(height: 20),

                // Quick stats
                _buildQuickStats(upcomingShifts)
                    .animate()
                    .fade(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ).animate().fade(duration: 400.ms, delay: 150.ms),
                const SizedBox(height: 12),
                _buildQuickActions(
                  context,
                ).animate().fade(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 24),

                // Upcoming shifts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Shifts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.myShifts),
                      child: const Text('See All'),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 250.ms),
                const SizedBox(height: 8),

                ...List<Widget>.from(
                  upcomingShifts.isEmpty
                      ? [_buildNoShifts()]
                      : upcomingShifts
                          .take(3)
                          .map((s) => _UpcomingShiftCard(shift: s)),
                ).map(
                  (w) => w.animate().fade(duration: 400.ms, delay: 300.ms),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<ShiftModel> shifts) {
    final thisWeek = shifts.where((s) {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return s.startTime.isAfter(monday) && s.startTime.isBefore(sunday);
    }).length;

    return Row(
      children: [
        _MiniStat(
          label: 'This Week',
          value: '$thisWeek shifts',
          icon: Icons.date_range,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _MiniStat(
          label: 'Next Shift',
          value: shifts.isNotEmpty
              ? DateFormat('d MMM').format(shifts.first.startTime)
              : 'None',
          icon: Icons.schedule,
          color: AppColors.info,
        ),
        const SizedBox(width: 12),
        _MiniStat(
          label: 'Hours',
          value: '24h',
          icon: Icons.timer_outlined,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'label': 'Clock In',
        'icon': Icons.fingerprint,
        'color': AppColors.success,
        'route': AppRoutes.clockInOut,
      },
      {
        'label': 'My Shifts',
        'icon': Icons.work_outline,
        'color': AppColors.info,
        'route': AppRoutes.myShifts,
      },
      {
        'label': 'Availability',
        'icon': Icons.calendar_today_outlined,
        'color': AppColors.warning,
        'route': AppRoutes.availability,
      },
      {
        'label': 'My Pay',
        'icon': Icons.payments_outlined,
        'color': AppColors.primary,
        'route': AppRoutes.paySummary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () => context.go(action['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: (action['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (action['color'] as Color).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: action['color'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoShifts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, color: AppColors.textHint, size: 40),
          SizedBox(height: 12),
          Text(
            'No upcoming shifts',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActiveShiftCard extends StatelessWidget {
  final ShiftModel shift;
  const _ActiveShiftCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Active Shift',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${timeFormat.format(shift.startTime)} – ${timeFormat.format(shift.endTime)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            shift.role,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            shift.area ?? shift.venueName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.clockInOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Clock Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingShiftCard extends StatelessWidget {
  final ShiftModel shift;
  const _UpcomingShiftCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEE, d MMM');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.work_outline,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.role,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(shift.startTime)} • ${timeFormat.format(shift.startTime)} – ${timeFormat.format(shift.endTime)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (shift.estimatedPay != null)
            Text(
              '£${shift.estimatedPay!.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
