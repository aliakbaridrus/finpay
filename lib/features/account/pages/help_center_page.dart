import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/info_note.dart';
import '../widgets/sub_page_scaffold.dart';
import 'contact_cs_page.dart';

class _Faq {
  const _Faq(this.category, this.question, this.answer);

  final String category;
  final String question;
  final String answer;
}

/// Pusat Bantuan: pencarian, filter kategori, dan FAQ yang bisa dibuka-tutup.
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  static const List<String> _categories = [
    'Semua',
    'Akun',
    'Transfer',
    'Top Up',
    'Keamanan',
  ];

  static const List<_Faq> _faqs = [
    _Faq(
      'Akun',
      'Bagaimana cara mengubah nomor HP?',
      'Buka Akun > Profil Saya, lalu ketuk baris Nomor HP. Kamu akan '
          'menerima kode OTP di nomor baru untuk konfirmasi.',
    ),
    _Faq(
      'Akun',
      'Kenapa nama saya tidak bisa diubah?',
      'Nama mengikuti data KTP saat verifikasi identitas. Jika ada '
          'kesalahan penulisan, hubungi CS dengan melampirkan foto KTP.',
    ),
    _Faq(
      'Transfer',
      'Transfer sudah berhasil tapi saldo penerima belum masuk?',
      'Transfer antar FinPay masuk seketika. Untuk transfer antar bank, '
          'dana bisa memakan waktu hingga 15 menit. Jika lebih lama, '
          'hubungi CS dengan menyertakan bukti transfer.',
    ),
    _Faq(
      'Transfer',
      'Berapa biaya transfer ke bank lain?',
      'Transfer antar FinPay gratis. Transfer ke bank lain dikenakan '
          'biaya admin sesuai tabel biaya yang tampil sebelum konfirmasi.',
    ),
    _Faq(
      'Top Up',
      'Berapa lama top up saldo lewat QRIS diproses?',
      'Umumnya instan. Jika saldo belum bertambah setelah 10 menit, '
          'simpan bukti pembayaran dan ajukan pengecekan lewat CS.',
    ),
    _Faq(
      'Top Up',
      'Berapa minimal top up?',
      'Minimal top up adalah Rp 10.000 per transaksi dengan batas '
          'maksimal sesuai limit akun kamu.',
    ),
    _Faq(
      'Keamanan',
      'Saya lupa PIN, apa yang harus dilakukan?',
      'Ketuk Lupa PIN di layar masukkan PIN, lalu verifikasi dengan OTP '
          'dan selfie. Setelah itu kamu bisa membuat PIN baru.',
    ),
    _Faq(
      'Keamanan',
      'Bagaimana jika kartu atau HP saya hilang?',
      'Segera bekukan kartu di Akun > Rekening & Kartu, lalu keluarkan '
          'perangkat yang hilang di Perangkat Terpercaya. Hubungi CS untuk '
          'bantuan lebih lanjut.',
    ),
  ];

  String _category = 'Semua';
  String _query = '';

  List<_Faq> get _filtered {
    final q = _query.trim().toLowerCase();
    return _faqs.where((faq) {
      final matchCategory = _category == 'Semua' || faq.category == _category;
      final matchQuery = q.isEmpty ||
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);
      return matchCategory && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return SubPageScaffold(
      title: 'Pusat Bantuan',
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Cari pertanyaan...',
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textTertiary),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: AppRadius.lgAll,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) {
              final name = _categories[i];
              final selected = name == _category;
              return ChoiceChip(
                label: Text(name),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => setState(() => _category = name),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
                labelStyle: AppTextStyles.label.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (results.isEmpty)
          _buildEmpty()
        else
          for (final faq in results) ...[
            _FaqTile(faq: faq),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.lg),
        InfoNote(
          icon: Icons.support_agent_rounded,
          title: 'Belum ketemu jawabannya?',
          text: 'Tim CS FinPay siap membantu setiap hari, 24 jam.',
          actionLabel: 'Hubungi CS',
          onActionTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ContactCsPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Pertanyaan tidak ditemukan', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Coba kata kunci lain atau ganti kategori.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      // Hilangkan garis pemisah bawaan ExpansionTile.
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textTertiary,
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          title: Text(faq.question, style: AppTextStyles.bodyLarge),
          children: [
            Text(
              faq.answer,
              style: AppTextStyles.bodySmall.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
