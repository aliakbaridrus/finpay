import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

/// Kerangka standar untuk semua sub-halaman Akun: app bar dengan tombol
/// kembali bulat, latar yang sama dengan Beranda, dan lebar konten dibatasi.
///
/// Isi salah satu:
/// - [children]: otomatis dibungkus ListView dengan padding standar.
/// - [body]: widget bebas (mis. chat atau keypad yang butuh layout sendiri).
///
/// [bottom] adalah widget yang menempel di bawah (mis. tombol Simpan).
class SubPageScaffold extends StatelessWidget {
  const SubPageScaffold({
    super.key,
    required this.title,
    this.children,
    this.body,
    this.bottom,
    this.actions,
  }) : assert(children != null || body != null, 'Isi children atau body');

  final String title;
  final List<Widget>? children;
  final Widget? body;
  final Widget? bottom;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final content = body ??
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: children!,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.maybePop(context),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: AppSizes.iconMd,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: Text(title, style: AppTextStyles.h2),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Column(
              children: [
                Expanded(child: content),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
