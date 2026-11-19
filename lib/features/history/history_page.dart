import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/wealth_service.dart';
import 'widgets/history_header.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/transaction_list_group.dart';

/// Halaman Riwayat Transaksi FinPay terintegrasi TransactionService & WealthService.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  TransactionFilter _selectedFilter = TransactionFilter.all;
  String _searchQuery = '';
  String _selectedPeriod = 'Semua Waktu';

  List<String> get _periodOptions => [
        ...WealthService.availablePeriods,
        'Pilih Rentang Tanggal (Kustom)',
      ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> get _filteredTransactions {
    final bySearchAndType = TransactionService.instance.getTransactions(
      filter: _selectedFilter,
      searchQuery: _searchQuery,
    );
    return WealthService.instance.filterTransactionsByPeriod(
      bySearchAndType,
      _selectedPeriod,
    );
  }

  int get _totalIncome {
    return _filteredTransactions
        .where((t) => t.isIncoming)
        .fold(0, (sum, item) => sum + item.amount);
  }

  int get _totalExpense {
    return _filteredTransactions
        .where((t) => !t.isIncoming)
        .fold(0, (sum, item) => sum + item.amount.abs());
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    if (range != null && mounted) {
      final startStr = AuthService.formatDeviceDate(
        range.start,
        shortMonthOnly: false,
      );
      final endStr = AuthService.formatDeviceDate(
        range.end,
        shortMonthOnly: false,
      );
      setState(() {
        _selectedPeriod = '$startStr - $endStr';
      });
    }
  }

  void _showPeriodPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Rentang Waktu (Hari, Bulan, Tahun)',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final p in _periodOptions)
                  ListTile(
                    leading: Icon(
                      p.contains('Kustom')
                          ? Icons.date_range_rounded
                          : Icons.calendar_today_rounded,
                      size: 18,
                      color: p == _selectedPeriod
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      p,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: p == _selectedPeriod
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: p == _selectedPeriod
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: p == _selectedPeriod
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      if (p.contains('Kustom')) {
                        await _pickCustomDateRange();
                      } else {
                        setState(() => _selectedPeriod = p);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TransactionModel>>(
      valueListenable: TransactionService.instance.transactionsNotifier,
      builder: (context, _, __) {
        final filtered = _filteredTransactions;

        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: CustomScrollView(
                slivers: [
                  // Header & Search
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.md,
                      AppSpacing.page,
                      AppSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: HistoryHeader(
                        searchController: _searchController,
                        onSearchChanged: (val) =>
                            setState(() => _searchQuery = val),
                        onClearSearch: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        selectedMonth: _selectedPeriod,
                        onSelectMonthTap: _showPeriodPicker,
                      ),
                    ),
                  ),

                  // Kartu Ringkasan Arus Kas (Murni dari transaksi user; jika kosong maka Rp 0)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: MonthlySummaryCard(
                        totalIncome: _totalIncome,
                        totalExpense: _totalExpense,
                        periodLabel: _selectedPeriod,
                      ),
                    ),
                  ),

                  // Filter Chips
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.lg,
                      AppSpacing.page,
                      AppSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _FilterChips(
                        selected: _selectedFilter,
                        onSelected: (filter) =>
                            setState(() => _selectedFilter = filter),
                      ),
                    ),
                  ),

                  // Daftar Transaksi Terkelompok
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.xxxl,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TransactionListGroup(transactions: filtered),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final filter in TransactionFilter.values) ...[
            _FilterChip(
              label: filter.label,
              isSelected: filter == selected,
              onTap: () => onSelected(filter),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected ? AppShadows.glow(AppColors.primary) : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
