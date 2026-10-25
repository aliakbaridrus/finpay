import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/transaction_service.dart';
import 'widgets/history_header.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/transaction_list_group.dart';

/// Halaman Riwayat Transaksi FinPay terintegrasi TransactionService (Bagian Ali).
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  TransactionFilter _selectedFilter = TransactionFilter.all;
  String _searchQuery = '';
  String _selectedMonth = 'Okt 2024';

  final List<String> _months = [
    'Okt 2024',
    'Sep 2024',
    'Agus 2024',
    'Juli 2024',
  ];

  @override
  void initState() {
    super.initState();
    TransactionService.instance.fetchTransactionsFromFirebase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> get _filteredTransactions {
    return TransactionService.instance.getTransactions(
      filter: _selectedFilter,
      searchQuery: _searchQuery,
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

  void _showMonthPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Bulan', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              for (final m in _months)
                ListTile(
                  title: Text(
                    m,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: m == _selectedMonth
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: m == _selectedMonth
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: m == _selectedMonth
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedMonth = m);
                    Navigator.pop(context);
                  },
                ),
            ],
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
                        selectedMonth: _selectedMonth,
                        onSelectMonthTap: _showMonthPicker,
                      ),
                    ),
                  ),

                  // Kartu Ringkasan Bulan Ini
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: MonthlySummaryCard(
                        totalIncome: _totalIncome > 0 ? _totalIncome : 5850000,
                        totalExpense:
                            _totalExpense > 0 ? _totalExpense : 1828500,
                        periodLabel: _selectedMonth,
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
