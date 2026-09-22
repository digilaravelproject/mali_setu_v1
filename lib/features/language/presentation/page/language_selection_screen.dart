import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constent/app_constants.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_scaffold.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isFromSettings;

  const LanguageSelectionScreen({
    super.key,
    this.isFromSettings = false,
  });

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late final LanguageController _languageController;
  late String _selectedCode;
  bool _isSaving = false;

  final List<Map<String, String>> _languages = const [
    {
      'code': 'en',
      'title': 'English',
      'native': 'English',
      'letter': 'A',
      'greeting': 'Welcome to Mali Setu',
    },
    {
      'code': 'hi',
      'title': 'Hindi',
      'native': 'हिंदी',
      'letter': 'अ',
      'greeting': 'माली सेतु में आपका स्वागत है',
    },
    {
      'code': 'mr',
      'title': 'Marathi',
      'native': 'मराठी',
      'letter': 'म',
      'greeting': 'माळी सेतू मध्ये आपले स्वागत आहे',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController());
    }
    _languageController = Get.find<LanguageController>();
    _selectedCode = _languageController.currentLanguageCode;
    if (_selectedCode.isEmpty) {
      _selectedCode = 'en';
    }
  }

  Future<void> _onLanguageSelected(String code) async {
    setState(() {
      _selectedCode = code;
    });
    // Immediately apply language so UI reacts live
    await _languageController.changeLanguage(code);
  }

  Future<void> _onContinue() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Ensure the chosen language is persisted
      await _languageController.changeLanguage(_selectedCode);
      // Mark initial language selection as completed
      await SharedPrefs.setBool(AppConstants.hasSelectedLanguagePref, true);

      if (widget.isFromSettings) {
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error saving language: $e');
      if (mounted) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return CustomScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // App Logo
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CustomImageView(
                            imagePath: AppAssets.getAppLogo(),
                            height: 84,
                            width: 84,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App Name
                    Text(
                      'welcome_to_app'.tr,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'choose_your_preferred_language'.tr,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle description
                    Text(
                      'choose_language_desc'.tr,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Language Cards List
                    ..._languages.map((lang) {
                      final isSelected = _selectedCode == lang['code'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: _buildLanguageCard(
                          code: lang['code']!,
                          title: lang['title']!,
                          native: lang['native']!,
                          letter: lang['letter']!,
                          greeting: lang['greeting']!,
                          isSelected: isSelected,
                          primaryColor: primaryColor,
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Note on more languages
                    Text(
                      'more_languages_coming_soon'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Action Area
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Continue Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'continue_step'.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Reassurance note
                  Text(
                    'change_language_anytime_note'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String code,
    required String title,
    required String native,
    required String letter,
    required String greeting,
    required bool isSelected,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onLanguageSelected(code),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.07) : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : theme.dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Badge / Letter Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Language Text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          native,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (native != title) ...[
                          const SizedBox(width: 8),
                          Text(
                            '($title)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.85)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
