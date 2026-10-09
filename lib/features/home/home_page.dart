import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
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
///
/// Setiap section dipisah menjadi widget tersendiri di folder `widgets/`
/// sehingga urutan, jarak, maupun isi section mudah diatur dari sini.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      const GreetingSection(
        userName: DummyData.userName,
        membership: DummyData.membership,
        points: DummyData.finPoin,
      ),
      const SizedBox(height: AppSpacing.lg),
      const BalanceCard(
        totalBalance: DummyData.totalBalance,
        cashBalance: DummyData.cashBalance,
        savingBalance: DummyData.savingBalance,
        phoneNumber: DummyData.phoneNumber,
      ),
      const SizedBox(height: AppSpacing.lg),
      const QuickActions(items: DummyData.quickActions),
      const SizedBox(height: AppSpacing.section),
      const FinancialServicesSection(items: DummyData.services),
      const SizedBox(height: AppSpacing.section),
      _buildHighlightsSection(),
      const SizedBox(height: AppSpacing.lg),
      const InstantLoanBanner(
        maxAmount: DummyData.loanMaxAmount,
        minInstallment: DummyData.loanMinInstallment,
        interestLabel: DummyData.loanInterest,
      ),
      const SizedBox(height: AppSpacing.section),
      const TransactionHistorySection(transactions: DummyData.transactions),
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
        const CashFlowCard(
          income: DummyData.monthlyIncome,
          expense: DummyData.monthlyExpense,
          incomeNote: DummyData.incomeGrowth,
          expenseNote: DummyData.expenseNote,
        ),
        const SizedBox(height: AppSpacing.md),
        const SavingGoalCard(
          title: DummyData.savingGoalTitle,
          monthlyDebit: DummyData.savingGoalMonthly,
          current: DummyData.savingGoalCurrent,
          target: DummyData.savingGoalTarget,
          eta: DummyData.savingGoalEta,
        ),
      ],
    );
  }
}
