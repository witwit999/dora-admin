import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales
class AppLocales {
  static const english = Locale('en');
  static const arabic = Locale('ar');
  
  static const List<Locale> supported = [english, arabic];
  
  static Locale fromCode(String code) {
    switch (code) {
      case 'ar':
        return arabic;
      case 'en':
      default:
        return english;
    }
  }
}

/// Locale state notifier with persistent storage
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;
  
  LocaleNotifier(this._prefs) : super(AppLocales.english) {
    _loadSavedLocale();
  }
  
  /// Load saved locale from shared preferences
  Future<void> _loadSavedLocale() async {
    final savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null) {
      state = AppLocales.fromCode(savedLocale);
    } else {
      // Auto-detect device locale on first launch
      final deviceLocale = PlatformDispatcher.instance.locale;
      if (deviceLocale.languageCode == 'ar') {
        state = AppLocales.arabic;
        await _saveLocale(AppLocales.arabic);
      } else {
        state = AppLocales.english;
        await _saveLocale(AppLocales.english);
      }
    }
  }
  
  /// Set locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _saveLocale(locale);
  }
  
  /// Save locale to shared preferences
  Future<void> _saveLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }
  
  /// Get current locale
  Locale getCurrentLocale() {
    return state;
  }
  
  /// Check if current locale is RTL
  bool get isRTL => state.languageCode == 'ar';
}

/// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});
