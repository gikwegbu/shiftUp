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

final todayShiftsProvider = StreamProvider.family<List<ShiftModel>, String>((
  ref,
  venueId,
) {
  return ref.watch(shiftRepositoryProvider).getVenueShifts(venueId);
});

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
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
                    'Good ${_getGreeting()}, ${user?.fullName.split(' ').first ?? 'Manager'} 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (user?.fullName.isNotEmpty == true)
                        ? user!.fullName[0].toUpperCase()
                        : 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                // Stats row
                _buildStatsRow(
                  context,
                ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ).animate().fade(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 12),
                _buildQuickActions(
                  context,
                ).animate().fade(duration: 400.ms, delay: 150.ms),

                const SizedBox(height: 24),

                // Today's Shifts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Shifts",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.roster),
                      child: const Text('See All'),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 8),

                if (user?.venueId != null)
                  _buildTodayShifts(
                    ref,
                    user!.venueId!,
                  ).animate().fade(duration: 400.ms, delay: 250.ms)
                else
                  _buildEmptyShifts().animate().fade(
                        duration: 400.ms,
                        delay: 250.ms,
                      ),

                const SizedBox(height: 24),

                // Team Overview
                Text(
                  'Team Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ).animate().fade(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 12),
                _buildTeamOverview(
                  context,
                ).animate().fade(duration: 400.ms, delay: 350.ms),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      // FAB: Add shift
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddShiftSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Today\'s Shifts',
          value: '8',
          icon: Icons.work_outline,
          color: AppColors.info,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Open Slots',
          value: '3',
          icon: Icons.add_circle_outline,
          color: AppColors.warning,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Staff Active',
          value: '5',
          icon: Icons.people_outline,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Add Shift',
        icon: Icons.add_circle_outline,
        color: AppColors.primary,
      ),
      _QuickAction(
        label: 'View Roster',
        icon: Icons.calendar_month_outlined,
        color: AppColors.info,
      ),
      _QuickAction(
        label: 'Team',
        icon: Icons.people_outline,
        color: AppColors.success,
      ),
      _QuickAction(
        label: 'Swaps',
        icon: Icons.swap_horiz,
        color: AppColors.warning,
      ),
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
          onTap: () {
            if (index == 1) context.go(AppRoutes.roster);
            if (index == 2) context.go(AppRoutes.staffManagement);
            if (index == 3) context.go(AppRoutes.shiftSwaps);
          },
          child: Container(
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: action.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: action.color, size: 28),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: action.color,
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

  Widget _buildTodayShifts(WidgetRef ref, String venueId) {
    final shiftsAsync = ref.watch(todayShiftsProvider(venueId));
    return shiftsAsync.when(
      data: (shifts) {
        final todayShifts = shifts.where((s) => s.isToday).toList();
        if (todayShifts.isEmpty) return _buildEmptyShifts();
        return Column(
          children: todayShifts
              .take(5)
              .map((shift) => _ShiftTile(shift: shift))
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildEmptyShifts(),
    );
  }

  Widget _buildEmptyShifts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.work_off_outlined, color: AppColors.textHint, size: 40),
          SizedBox(height: 12),
          Text(
            'No shifts scheduled today',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOverview(BuildContext context) {
    final teamMembers = [
      {'name': 'Alex Turner', 'role': 'Bartender', 'status': 'On Shift'},
      {'name': 'Emma Wilson', 'role': 'Server', 'status': 'Upcoming'},
      {'name': 'James Cole', 'role': 'Host', 'status': 'Off Today'},
    ];

    return Column(
      children: teamMembers.map((member) {
        final isOnShift = member['status'] == 'On Shift';
        final isUpcoming = member['status'] == 'Upcoming';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  member['name']![0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      member['role']!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOnShift
                      ? AppColors.success.withValues(alpha: 0.15)
                      : isUpcoming
                          ? AppColors.info.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member['status']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOnShift
                        ? AppColors.success
                        : isUpcoming
                            ? AppColors.info
                            : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddShiftSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddShiftSheet(),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  _QuickAction({required this.label, required this.icon, required this.color});
}

class _ShiftTile extends StatelessWidget {
  final ShiftModel shift;
  const _ShiftTile({required this.shift});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _getStatusColor(shift.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.staffName ?? 'Unassigned',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shift.role} • ${shift.area ?? shift.venueName}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${timeFormat.format(shift.startTime)} - ${timeFormat.format(shift.endTime)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shift.statusString,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.confirmed:
        return AppColors.success;
      case ShiftStatus.pending:
        return AppColors.warning;
      case ShiftStatus.cancelled:
        return AppColors.error;
      case ShiftStatus.completed:
        return AppColors.textHint;
      default:
        return AppColors.info;
    }
  }
}

class _AddShiftSheet extends StatefulWidget {
  const _AddShiftSheet();

  @override
  State<_AddShiftSheet> createState() => _AddShiftSheetState();
}

class _AddShiftSheetState extends State<_AddShiftSheet> {
  final _roleController = TextEditingController();
  final _areaController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Add New Shift',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Date
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: DateFormat('EEE, d MMM yyyy').format(_selectedDate),
            ),
          ),
          const SizedBox(height: 12),

          // Times
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (time != null) setState(() => _startTime = time);
                  },
                  child: _InfoTile(
                    icon: Icons.access_time,
                    label: 'Start',
                    value: _startTime.format(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (time != null) setState(() => _endTime = time);
                  },
                  child: _InfoTile(
                    icon: Icons.access_time_filled,
                    label: 'End',
                    value: _endTime.format(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _roleController,
            decoration: const InputDecoration(
              labelText: 'Role (e.g. Bartender)',
              prefixIcon: Icon(Icons.work_outline),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _areaController,
            decoration: const InputDecoration(
              labelText: 'Area (e.g. Main Bar)',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create Shift'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
