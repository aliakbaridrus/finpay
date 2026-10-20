import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../widgets/sub_page_scaffold.dart';

/// Verifikasi Identitas: status KYC, riwayat tahapan, dan manfaatnya.
class IdentityVerificationPage extends StatelessWidget {
  const IdentityVerificationPage({super.key});

  static const List<_Step> _steps = [
    _Step('Data diri diisi', '12 Jan 2024, 09:14'),
    _Step('Foto KTP diunggah', '12 Jan 2024, 09:16'),
    _Step('Selfie & deteksi wajah', '12 Jan 2024, 09:18'),
    _Step('Pencocokan data Dukcapil', '12 Jan 2024, 09:21'),
  ];

  static const List<String> _benefits = [
    'Limit transaksi hingga Rp 50.000.000 per hari',
    'Akses Pinjaman Instan hingga Rp 25.000.000',
    'Tarik tunai dan investasi tanpa batasan tambahan',
    'Prioritas layanan CS FinPay',
  ];

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Verifikasi Identitas',
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.successLight,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 34,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Identitas Terverifikasi', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Akun atas nama ${DummyData.userName} sudah memenuhi '
                  'standar verifikasi (KYC).',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                ),
                const SizedBox(height: AppSpacing.md),
                PillBadge(
                  label: DummyData.membership,
                  leadingIcon: Icons.workspace_premium_rounded,
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: const Color(0xFF92400E),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        Text('Riwayat Verifikasi', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < _steps.length; i++)
                _StepRow(step: _steps[i], isLast: i == _steps.length - 1),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        Text('Manfaat Akun Terverifikasi', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              for (final benefit in _benefits)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: AppSizes.iconMd,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          benefit,
                          style: AppTextStyles.body.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step {
  const _Step(this.title, this.time);

  final String title;
  final String time;
}

/// Satu langkah di timeline: lingkaran centang + garis penghubung ke bawah.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final _Step step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.successLight,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.successLight),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(step.time, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
