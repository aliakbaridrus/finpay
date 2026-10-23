import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pill_badge.dart';

/// Halaman Penuh 8: Promo & Voucher FinPay.
class PromosPage extends StatefulWidget {
  const PromosPage({super.key});

  @override
  State<PromosPage> createState() => _PromosPageState();
}

class _PromosPageState extends State<PromosPage> {
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Cashback', 'Diskon Tagihan', 'Investasi'];

  final List<Map<String, dynamic>> _promos = const [
    {
      'title': 'Cashback 50% QRIS Indomaret & Alfamart',
      'desc': 'Maksimal cashback Rp 10.000 dengan minimal belanja Rp 20.000 di seluruh gerai Indomaret & Alfamart.',
      'code': 'FINQRIS50',
      'category': 'Cashback',
      'validity': 'Berlaku s.d 31 Oktober 2024',
      'icon': Icons.qr_code_2_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Diskon Tagihan PLN & PDAM Rp 15.000',
      'desc': 'Potongan langsung Rp 15.000 untuk pembayaran tagihan PLN dan Air PDAM via FinPay.',
      'code': 'HEMATPLN',
      'category': 'Diskon Tagihan',
      'validity': 'Berlaku s.d 15 November 2024',
      'icon': Icons.bolt_rounded,
      'color': AppColors.gold,
    },
    {
      'title': 'Bonus Unit Reksa Dana Rp 25.000',
      'desc': 'Top Up investasi Reksa Dana Pasar Uang min. Rp 500.000 dan dapatkan unit bonus gratis.',
      'code': 'INVESTBONUS',
      'category': 'Investasi',
      'validity': 'Berlaku s.d 30 November 2024',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFF0F766E),
    },
  ];

  List<Map<String, dynamic>> get _filteredPromos {
    if (_selectedCategory == 'Semua') return _promos;
    return _promos.where((p) => p['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredPromos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Promo & Voucher FinPay', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka daftar Kupon Saya...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Promo Utama
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.balanceGradient,
                borderRadius: AppRadius.xlAll,
                boxShadow: AppShadows.glow(AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, size: 48, color: Colors.white),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROMO SPESIAL OKTOBER 🎉', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('Pakai Voucher & Hemat Hingga Rp 100.000!', style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // Category Chips
            Text('Kategori Promo', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final cat in _categories) ...[
                    GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedCategory == cat ? AppColors.primary : AppColors.surface,
                          borderRadius: AppRadius.pillAll,
                          border: Border.all(color: _selectedCategory == cat ? AppColors.primary : AppColors.border),
                          boxShadow: _selectedCategory == cat ? AppShadows.glow(AppColors.primary) : AppShadows.card,
                        ),
                        child: Text(
                          cat,
                          style: AppTextStyles.label.copyWith(
                            color: _selectedCategory == cat ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),

            // List Banner Promos
            for (final promo in items) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: (promo['color'] as Color).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(promo['icon'] as IconData, size: 28, color: promo['color'] as Color),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(promo['title'] as String, style: AppTextStyles.h3),
                              const SizedBox(height: 2),
                              PillBadge(
                                label: promo['category'] as String,
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      promo['desc'] as String,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(promo['validity'] as String, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kode voucher "${promo['code']}" berhasil disalin!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                          label: const Text('Klaim Promo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
