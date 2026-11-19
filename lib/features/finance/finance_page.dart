import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/wallet_model.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/wallet_service.dart';
import '../../data/services/wealth_service.dart';
import '../home/widgets/financial_services_section.dart';
import '../home/widgets/instant_loan_banner.dart';
import '../services/service_navigation_helper.dart';
import 'widgets/finance_header.dart';
import 'widgets/financial_health_card.dart';
import 'widgets/saving_goals_section.dart';
import 'widgets/total_wealth_card.dart';

/// Halaman Keuangan & Portofolio FinPay terintegrasi [WealthService] & [WalletService] (Bagian Tugas Pidi).
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
    return ValueListenableBuilder<WalletModel>(
      valueListenable: WalletService.instance.walletNotifier,
      builder: (context, wallet, _) {
        return ValueListenableBuilder(
          valueListenable: TransactionService.instance.transactionsNotifier,
          builder: (context, _, __) {
            final summary = WealthService.instance.calculateCashFlowSummary();

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
                              totalWealth: wallet.totalWealth,
                              cashBalance: wallet.cashBalance,
                              savingBalance: wallet.savingBalance,
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
                              child: FinancialHealthCard(
                                income: summary.totalIncome,
                                expense: summary.totalExpense,
                                incomeGrowth: summary.incomeGrowthLabel,
                                expenseNote: summary.expenseRatioLabel,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),

                            // Target Menabung & Impian
                            SavingGoalsSection(
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
          },
        );
      },
    );
  }
}
