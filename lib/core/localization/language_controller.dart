import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/shared_prefs.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'app_language';
  
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }
  
  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final languageCode = SharedPrefs.getString(_languageKey);
      
      print("DEBUG_LANGUAGE: ========================================");
      print("DEBUG_LANGUAGE: Loading saved language...");
      print("DEBUG_LANGUAGE: Saved language code: $languageCode");
      
      if (languageCode != null && languageCode.isNotEmpty) {
        if (languageCode == 'mr') {
          currentLocale.value = const Locale('mr', 'IN');
          Get.updateLocale(const Locale('mr', 'IN'));
          print("DEBUG_LANGUAGE: ✅ Loaded Marathi language");
        } else {
          currentLocale.value = const Locale('en', 'US');
          Get.updateLocale(const Locale('en', 'US'));
          print("DEBUG_LANGUAGE: ✅ Loaded English language");
        }
      } else {
        // Default to English
        currentLocale.value = const Locale('en', 'US');
        print("DEBUG_LANGUAGE: ℹ️ No saved language, using default (English)");
      }
      print("DEBUG_LANGUAGE: ========================================");
    } catch (e) {
      print('DEBUG_LANGUAGE: ❌ Error loading language: $e');
      // Default to English on error
      currentLocale.value = const Locale('en', 'US');
    }
  }
  
  /// Change app language and save to SharedPreferences
  Future<void> changeLanguage(String languageCode) async {
    try {
      isLoading.value = true;
      
      print("DEBUG_LANGUAGE: ========================================");
      print("DEBUG_LANGUAGE: Changing language to: $languageCode");
      
      Locale newLocale;
      
      if (languageCode == 'mr') {
        newLocale = const Locale('mr', 'IN');
        print("DEBUG_LANGUAGE: Setting locale to Marathi (mr_IN)");
      } else {
        newLocale = const Locale('en', 'US');
        print("DEBUG_LANGUAGE: Setting locale to English (en_US)");
      }
      
      // Update locale in GetX
      currentLocale.value = newLocale;
      Get.updateLocale(newLocale);
      print("DEBUG_LANGUAGE: ✅ Locale updated in GetX");
      
      // Save to SharedPreferences
      await SharedPrefs.setString(_languageKey, languageCode);
      print("DEBUG_LANGUAGE: ✅ Language saved to SharedPreferences");
      
      // Verify save
      final savedLang = SharedPrefs.getString(_languageKey);
      print("DEBUG_LANGUAGE: Verification - Saved language: $savedLang");
      print("DEBUG_LANGUAGE: ========================================");
      
    } catch (e) {
      print('DEBUG_LANGUAGE: ❌ Error changing language: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Get current language code
  String get currentLanguageCode {
    return currentLocale.value.languageCode;
  }
  
  /// Check if current language is English
  bool get isEnglish => currentLanguageCode == 'en';
  
  /// Check if current language is Marathi
  bool get isMarathi => currentLanguageCode == 'mr';
  
  /// Get current language name
  String get currentLanguageName {
    return isMarathi ? 'मराठी' : 'English';
  }
}
