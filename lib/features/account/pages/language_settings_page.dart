import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Bahasa / Language.
class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLang = 'Bahasa Indonesia';
  final List<String> _langs = ['Bahasa Indonesia', 'English (US)', 'Mandarin (中文)'];

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
        title: Text('Bahasa / Language', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            children: [
              for (final lang in _langs)
                RadioListTile<String>(
                  value: lang,
                  groupValue: _selectedLang,
                  title: Text(lang, style: const TextStyle(fontWeight: FontWeight.bold)),
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLang = val);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
