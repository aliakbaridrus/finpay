import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
import '../services/service_navigation_helper.dart';
import 'widgets/balance_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/financial_services_section.dart';
import 'widgets/greeting_section.dart';
import 'widgets/home_header.dart';
import 'widgets/instant_loan_banner.dart';
import 'widgets/quick_actions.dart';
import 'widgets/saving_goal_card.dart';
import 'widgets/security_info_card.dart';
import 'widgets/transaction_history_section.dart';

/// Halaman Beranda FinPay.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onNavigateToHistory});

  final VoidCallback? onNavigateToHistory;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxContentWidth,
          ),
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  0,
                ),
                sliver: SliverToBoxAdapter(child: HomeHeader()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.list(children: _buildSections()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    return [
      GreetingSection(
        userName: DummyData.userName,
        membership: DummyData.membership,
        points: DummyData.finPoin,
      ),
      const SizedBox(height: AppSpacing.lg),
      BalanceCard(
        totalBalance: DummyData.totalBalance,
        cashBalance: DummyData.cashBalance,
        savingBalance: DummyData.savingBalance,
        phoneNumber: DummyData.phoneNumber,
      ),
      const SizedBox(height: AppSpacing.lg),
      QuickActions(
        items: DummyData.quickActions,
        onItemTap: (item) {
          ServiceNavigationHelper.openService(
            context,
            item.label,
            onStateChanged: _refresh,
          );
        },
      ),
      const SizedBox(height: AppSpacing.section),
      FinancialServicesSection(
        items: DummyData.services,
        onItemTap: (item) {
          ServiceNavigationHelper.openService(
            context,
            item.label,
            onStateChanged: _refresh,
          );
        },
      ),
      const SizedBox(height: AppSpacing.section),
      _buildHighlightsSection(),
      const SizedBox(height: AppSpacing.lg),
      InstantLoanBanner(
        maxAmount: DummyData.loanMaxAmount,
        minInstallment: DummyData.loanMinInstallment,
        interestLabel: DummyData.loanInterest,
        onApplyTap: () {
          ServiceNavigationHelper.openService(
            context,
            'Pinjaman',
            onStateChanged: _refresh,
          );
        },
      ),
      const SizedBox(height: AppSpacing.section),
      TransactionHistorySection(
        transactions: DummyData.transactions,
        onSeeAllTap: widget.onNavigateToHistory,
      ),
      const SizedBox(height: AppSpacing.section),
      const SecurityInfoCard(),
    ];
  }

  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Sorotan Keuangan', style: AppTextStyles.h2),
            ),
            Text(
              DummyData.highlightPeriod,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () {
            ServiceNavigationHelper.openService(
              context,
              'Cash Flow',
              onStateChanged: _refresh,
            );
          },
          child: const CashFlowCard(
            income: DummyData.monthlyIncome,
            expense: DummyData.monthlyExpense,
            incomeNote: DummyData.incomeGrowth,
            expenseNote: DummyData.expenseNote,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () {
            ServiceNavigationHelper.openService(
              context,
              'Menabung',
              onStateChanged: _refresh,
            );
          },
          child: const SavingGoalCard(
            title: DummyData.savingGoalTitle,
            monthlyDebit: DummyData.savingGoalMonthly,
            current: DummyData.savingGoalCurrent,
            target: DummyData.savingGoalTarget,
            eta: DummyData.savingGoalEta,
          ),
        ),
      ],
    );
  }
}
