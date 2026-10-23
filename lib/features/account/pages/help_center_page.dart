import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Pusat Bantuan (FinCare 24/7).
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
        title: Text('Pusat Bantuan FinCare', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.balanceGradient,
                borderRadius: AppRadius.xlAll,
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: Colors.white),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Layanan Pelanggan 24/7', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                        const SizedBox(height: 2),
                        const Text('Ada kendala transaksi? Tim FinCare siap membantu Anda.', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            Text('Pertanyaan Populer (FAQ)', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: const [
                  ExpansionTile(
                    title: Text('Bagaimana cara melakukan Top Up Saldo?', style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [Padding(padding: EdgeInsets.all(16), child: Text('Anda dapat melakukan top up melalui menu Isi Saldo dengan memilih Virtual Account BCA, Mandiri, BRI, atau di gerai Indomaret terdekat.'))],
                  ),
                  Divider(height: 1, color: AppColors.border),
                  ExpansionTile(
                    title: Text('Apakah saldo FinPay dijamin aman?', style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [Padding(padding: EdgeInsets.all(16), child: Text('Ya, saldo Anda dijamin oleh LPS dan diawasi langsung oleh Otoritas Jasa Keuangan (OJK).'))],
                  ),
                  Divider(height: 1, color: AppColors.border),
                  ExpansionTile(
                    title: Text('Bagaimana cara mereset PIN FinPay yang lupa?', style: TextStyle(fontWeight: FontWeight.bold)),
                    children: [Padding(padding: EdgeInsets.all(16), child: Text('Buka menu Akun > Keamanan & PIN > Ubah PIN, atau verifikasi melalui OTP nomor handphone terdaftar.'))],
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
