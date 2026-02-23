import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

// Dummy data model for Payslip
class Payslip {
  final String id;
  final String date;
  final double amount;
  final String taxCode;
  final double taxDeducted;

  Payslip({
    required this.id,
    required this.date,
    required this.amount,
    required this.taxCode,
    required this.taxDeducted,
  });
}

// Mock provider
final allPayslipsProvider = Provider<List<Payslip>>((ref) {
  return [
    Payslip(
        id: '1',
        date: 'February 2026',
        amount: 1560.00,
        taxCode: '1257L',
        taxDeducted: 210.00),
    Payslip(
        id: '2',
        date: 'January 2026',
        amount: 1380.00,
        taxCode: '1257L',
        taxDeducted: 180.50),
    Payslip(
        id: '3',
        date: 'December 2025',
        amount: 900.00,
        taxCode: '1257L',
        taxDeducted: 0.00),
    Payslip(
        id: '4',
        date: 'November 2025',
        amount: 1820.00,
        taxCode: '1257L',
        taxDeducted: 250.00),
    Payslip(
        id: '5',
        date: 'October 2025',
        amount: 1450.00,
        taxCode: '1257L',
        taxDeducted: 195.00),
    Payslip(
        id: '6',
        date: 'September 2025',
        amount: 1600.00,
        taxCode: '1257L',
        taxDeducted: 215.00),
  ];
});

class AllPayslipsScreen extends ConsumerStatefulWidget {
  const AllPayslipsScreen({super.key});

  @override
  ConsumerState<AllPayslipsScreen> createState() => _AllPayslipsScreenState();
}

class _AllPayslipsScreenState extends ConsumerState<AllPayslipsScreen> {
  String _dateFilter = 'All'; // 'All', '2026', '2025'
  String _amountFilter = 'All'; // 'All', '> £1000', '< £1000'

  @override
  Widget build(BuildContext context) {
    final payslips = ref.watch(allPayslipsProvider);

    // Apply filters
    final filteredPayslips = payslips.where((p) {
      bool dateMatch = true;
      if (_dateFilter != 'All') {
        dateMatch = p.date.contains(_dateFilter);
      }

      bool amountMatch = true;
      if (_amountFilter != 'All') {
        if (_amountFilter == '> £1000') {
          amountMatch = p.amount >= 1000;
        } else {
          amountMatch = p.amount < 1000;
        }
      }

      return dateMatch && amountMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Payslips'),
      ),
      body: Column(
        children: [
          // Filter Chips Scrollable Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.filter_list,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: 'All Dates',
                  isSelected: _dateFilter == 'All',
                  onSelected: (val) => setState(() => _dateFilter = 'All'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '2026',
                  isSelected: _dateFilter == '2026',
                  onSelected: (val) => setState(() => _dateFilter = '2026'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '2025',
                  isSelected: _dateFilter == '2025',
                  onSelected: (val) => setState(() => _dateFilter = '2025'),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.border,
                ),
                const SizedBox(width: 16),
                _buildFilterChip(
                  label: 'All Amounts',
                  isSelected: _amountFilter == 'All',
                  onSelected: (val) => setState(() => _amountFilter = 'All'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '> £1000',
                  isSelected: _amountFilter == '> £1000',
                  onSelected: (val) =>
                      setState(() => _amountFilter = '> £1000'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '< £1000',
                  isSelected: _amountFilter == '< £1000',
                  onSelected: (val) =>
                      setState(() => _amountFilter = '< £1000'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List View
          Expanded(
            child: filteredPayslips.isEmpty
                ? const Center(
                    child: Text(
                      'No payslips match your filters.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPayslips.length,
                    itemBuilder: (context, index) {
                      final p = filteredPayslips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            _showPayslipDetails(context, p);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_outlined,
                                    color: AppColors.success,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.date,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        'Monthly payslip',
                                        style: TextStyle(
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
                                      '£${p.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Paid',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  void _showPayslipDetails(BuildContext context, Payslip p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payslip Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Icon(Icons.receipt_long,
                        color: AppColors.primary, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow('Pay Period', p.date),
                const SizedBox(height: 12),
                _buildDetailRow('Tax Code', p.taxCode),
                const SizedBox(height: 12),
                _buildDetailRow('Tax Deducted (PAYE/NI)',
                    '£${p.taxDeducted.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Net Pay',
                  '£${p.amount.toStringAsFixed(2)}',
                  isHighlight: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                isHighlight ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.success : AppColors.textPrimary,
            fontSize: isHighlight ? 18 : 15,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
