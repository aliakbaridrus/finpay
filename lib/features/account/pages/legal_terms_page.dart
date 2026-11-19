import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Syarat & Kebijakan Privasi.
class LegalTermsPage extends StatelessWidget {
  const LegalTermsPage({super.key});

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
        title: Text('Syarat & Kebijakan Privasi', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ketentuan Penggunaan FinPay', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Selamat datang di aplikasi FinPay. Dengan mengunduh, mendaftar, atau menggunakan aplikasi ini, Anda menyetujui untuk terikat dengan syarat dan ketentuan serta kebijakan privasi yang berlaku.\n\n'
                '1. Perlindungan Data Pribadi\n'
                'FinPay berkomitmen melindungi seluruh kerahasiaan data pribadi pengguna sesuai dengan perundang-undangan Republik Indonesia dan standar keamanan perbankan digital.\n\n'
                '2. Penggunaan Akun\n'
                'Pengguna bertanggung jawab penuh atas keamanan PIN, sandi, serta perangkat yang digunakan untuk mengakses aplikasi FinPay.\n\n'
                '3. Perizinan OJK & LPS\n'
                'PT FinPay Indonesia berizin dan diawasi oleh Bank Indonesia serta Otoritas Jasa Keuangan (OJK).',
                style: AppTextStyles.bodySmall.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
