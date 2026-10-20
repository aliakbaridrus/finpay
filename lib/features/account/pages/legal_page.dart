import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../account_legal.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';

/// Halaman dokumen hukum yang dipakai bersama oleh Syarat & Ketentuan
/// dan Kebijakan Privasi. Cukup ganti judul dan daftar bagiannya.
class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: title,
      children: [
        Text(
          'Terakhir diperbarui ${AccountLegal.updatedAt}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(sections[i].heading, style: AppTextStyles.h3),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    sections[i].body,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.6),
                  ),
                ),
                if (i != sections.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoNote(
          icon: Icons.info_outline_rounded,
          text: 'Teks ini hanya contoh (dummy) untuk keperluan tugas dan '
              'belum merupakan dokumen hukum yang berlaku.',
        ),
      ],
    );
  }
}
