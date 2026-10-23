import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../data/dummy/dummy_data.dart';
import '../home/widgets/financial_services_section.dart';
import '../home/widgets/instant_loan_banner.dart';
import '../services/service_navigation_helper.dart';

import 'widgets/finance_header.dart';
import 'widgets/financial_health_card.dart';
import 'widgets/investment_portfolio_card.dart';
import 'widgets/saving_goals_section.dart';
import 'widgets/total_wealth_card.dart';

/// Halaman Keuangan & Portofolio FinPay.
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  void _refreshData() {
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
              // Header Title & Health Status
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(child: FinanceHeader()),
              ),

              // Content List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.list(
                  children: [
                    // Total Wealth Card (Interaktif & Clickable)
                    TotalWealthCard(
                      totalWealth: DummyData.totalWealth,
                      cashBalance: DummyData.cashBalance,
                      savingBalance: DummyData.savingBalance,
                      investmentBalance: DummyData.investmentBalance,
                      onStateChanged: _refreshData,
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Grid Layanan Keuangan Full Page Navigation
                    FinancialServicesSection(
                      items: DummyData.services,
                      onItemTap: (item) {
                        ServiceNavigationHelper.openService(
                          context,
                          item.label,
                          onStateChanged: _refreshData,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Analisis Arus Kas & Kesehatan Finansial
                    GestureDetector(
                      onTap: () {
                        ServiceNavigationHelper.openService(
                          context,
                          'Cash Flow',
                          onStateChanged: _refreshData,
                        );
                      },
                      child: const FinancialHealthCard(
                        income: DummyData.monthlyIncome,
                        expense: DummyData.monthlyExpense,
                        incomeGrowth: DummyData.incomeGrowth,
                        expenseNote: DummyData.expenseNote,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Target Menabung & Impian
                    SavingGoalsSection(
                      onStateChanged: _refreshData,
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Portofolio Investasi
                    InvestmentPortfolioCard(
                      investmentBalance: DummyData.investmentBalance,
                      investmentReturn: DummyData.investmentReturn,
                      onStateChanged: _refreshData,
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Banner Pinjaman Instan OJK
                    InstantLoanBanner(
                      maxAmount: DummyData.loanMaxAmount,
                      minInstallment: DummyData.loanMinInstallment,
                      interestLabel: DummyData.loanInterest,
                      onApplyTap: () {
                        ServiceNavigationHelper.openService(
                          context,
                          'Pinjaman',
                          onStateChanged: _refreshData,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
