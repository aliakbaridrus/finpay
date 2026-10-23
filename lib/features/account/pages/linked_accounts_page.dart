import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';

/// Halaman Penuh: Rekening & Kartu Terhubung.
class LinkedAccountsPage extends StatelessWidget {
  const LinkedAccountsPage({super.key});

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
        title: Text('Rekening & Kartu Terhubung', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daftar Bank & E-Wallet Terhubung', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const ListTile(
                leading: Icon(Icons.account_balance, color: AppColors.primary, size: 32),
                title: Text('BCA Virtual Account'),
                subtitle: Text('No. Rek: 88012081234567890'),
                trailing: PillBadge(label: 'Utama', backgroundColor: AppColors.successLight, foregroundColor: AppColors.success),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const ListTile(
                leading: Icon(Icons.account_balance, color: AppColors.primary, size: 32),
                title: Text('Mandiri Rekening'),
                subtitle: Text('No. Rek: 1300098129381'),
                trailing: PillBadge(label: 'Aktif', backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const ListTile(
                leading: Icon(Icons.credit_card, color: Colors.purple, size: 32),
                title: Text('Visa / Mastercard FinPay'),
                subtitle: Text('Kartu •••• 4819'),
                trailing: PillBadge(label: 'Tersambung', backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka form tambah rekening bank baru...')),
                  );
                },
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('Tambah Rekening / Kartu Baru', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
