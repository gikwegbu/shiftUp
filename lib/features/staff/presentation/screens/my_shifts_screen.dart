import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../shared/data/models/shift_model.dart';
import '../../presentation/screens/staff_dashboard_screen.dart';

class MyShiftsScreen extends ConsumerStatefulWidget {
  const MyShiftsScreen({super.key});

  @override
  ConsumerState<MyShiftsScreen> createState() => _MyShiftsScreenState();
}

class _MyShiftsScreenState extends ConsumerState<MyShiftsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Upcoming', 'Past'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final shiftsAsync = user != null
        ? ref.watch(staffShiftsProvider(user.id))
        : const AsyncValue<List<ShiftModel>>.data([]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Shifts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: shiftsAsync.when(
        data: (shifts) {
          final upcoming = shifts
              .where((s) => s.isFuture || s.isToday)
              .toList();
          final past = shifts.where((s) => s.isPast).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ShiftList(shifts: upcoming, emptyMessage: 'No upcoming shifts'),
              _ShiftList(shifts: past, emptyMessage: 'No past shifts'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _ShiftList extends StatelessWidget {
  final List<ShiftModel> shifts;
  final String emptyMessage;

  const _ShiftList({required this.shifts, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 60, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.screenPaddingH),
      itemCount: shifts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _DetailedShiftCard(shift: shifts[index]),
    );
  }
}

class _DetailedShiftCard extends StatelessWidget {
  final ShiftModel shift;

  const _DetailedShiftCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _statusColor(shift.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.work_outline, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.role,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        shift.area ?? shift.venueName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: shift.statusString, color: statusColor),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: dateFormat.format(shift.startTime),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value:
                      '${timeFormat.format(shift.startTime)} – ${timeFormat.format(shift.endTime)} (${shift.hoursWorked.toStringAsFixed(1)}h)',
                ),
                if (shift.estimatedPay != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Est. Pay',
                    value: '£${shift.estimatedPay!.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ShiftStatus status) {
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

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
