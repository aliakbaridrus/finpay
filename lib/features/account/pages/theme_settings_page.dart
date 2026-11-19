import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Halaman Penuh: Tampilan & Tema.
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  String _selectedTheme = 'Mode Terang (Light Mode)';
  final List<String> _themes = ['Mode Terang (Light Mode)', 'Mode Gelap (Dark Mode)', 'Ikuti Sistem Perangkat'];

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
        title: Text('Tampilan & Tema', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            children: [
              for (final th in _themes)
                RadioListTile<String>(
                  value: th,
                  groupValue: _selectedTheme,
                  title: Text(th, style: const TextStyle(fontWeight: FontWeight.bold)),
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTheme = val);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
