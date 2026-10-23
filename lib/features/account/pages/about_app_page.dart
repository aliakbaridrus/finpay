import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Tentang Aplikasi FinPay.
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tentang FinPay', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.balanceGradient,
                  borderRadius: AppRadius.xlAll,
                  boxShadow: AppShadows.glow(AppColors.primary),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 42, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('FinPay Mobile', style: AppTextStyles.h1),
            const Text('Versi 1.0.0 (Build 202410)', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.section),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Status Perizinan', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Berizin & Diawasi oleh OJK dan Bank Indonesia'),
                  ),
                  Divider(height: 1, color: AppColors.border),
                  ListTile(
                    title: Text('Penjamin Simpanan', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tergantung pada Lembaga Penjamin Simpanan (LPS)'),
                  ),
                  Divider(height: 1, color: AppColors.border),
                  ListTile(
                    title: Text('Pengembang', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('PT FinPay Digital Indonesia Tbk'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
