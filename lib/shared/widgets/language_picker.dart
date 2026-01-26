import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import 'package:dora_admin/l10n/app_localizations.dart';

/// Language picker dialog
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            locale: AppLocales.english,
            languageName: l10n.languageEnglish,
            isSelected: currentLocale == AppLocales.english,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(AppLocales.english);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _LanguageOption(
            locale: AppLocales.arabic,
            languageName: l10n.languageArabic,
            isSelected: currentLocale == AppLocales.arabic,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(AppLocales.arabic);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Show language picker dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LanguagePicker(),
    );
  }
}

/// Language option tile
class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.locale,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            // Language flag/icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  locale.languageCode == 'ar' ? '🇮🇶' : '🇺🇸',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Language name
            Expanded(
              child: Text(
                languageName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact language picker button for app bar
class LanguagePickerButton extends ConsumerWidget {
  final bool showText;

  const LanguagePickerButton({super.key, this.showText = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
      onPressed: () => LanguagePicker.show(context),
      tooltip: AppLocalizations.of(context)!.language,
    );
  }
}
