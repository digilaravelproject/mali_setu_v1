import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/localization/language_controller.dart';
import '../widgets/custom_snack_bar.dart';

/// Language selection dialog matching modern app styling
class LanguageSelectionDialog extends StatefulWidget {
  const LanguageSelectionDialog({super.key});

  /// Helper static method to show the language dialog easily from any screen
  static Future<void> show(BuildContext context) {
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController());
    }
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }

  @override
  State<LanguageSelectionDialog> createState() => _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  late final LanguageController _controller;
  late String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LanguageController>();
    _selectedLanguageCode = _controller.currentLanguageCode;
  }

  final List<Map<String, String>> _languages = const [
    {
      'code': 'en',
      'title': 'ENG',
      'subtitle': 'English',
    },
    {
      'code': 'hi',
      'title': 'हिंदी',
      'subtitle': 'Hindi',
    },
    {
      'code': 'mr',
      'title': 'मराठी',
      'subtitle': 'Marathi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar with Title and Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 28), // Balance close button spacing
                Expanded(
                  child: Text(
                    'choose_your_app_language'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3 Language Cards Row
            Row(
              children: _languages.map((lang) {
                final isSelected = _selectedLanguageCode == lang['code'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildLanguageCard(
                      title: lang['title']!,
                      subtitle: lang['subtitle']!,
                      isSelected: isSelected,
                      primaryColor: primaryColor,
                      onTap: () {
                        setState(() {
                          _selectedLanguageCode = lang['code']!;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // More languages coming soon note
            Text(
              'more_languages_coming_soon'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.normal,
              ),
            ),

            const SizedBox(height: 20),

            // Apply Button
            Obx(() => SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _controller.isLoading.value
                    ? null
                    : () async {
                        try {
                          await _controller.changeLanguage(_selectedLanguageCode);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            CustomSnackBar.showSuccess(
                              message: 'language_changed_success'.tr,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            CustomSnackBar.showError(
                              message: 'language_change_failed'.trParams({'error': e.toString()}),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'apply'.tr.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? primaryColor.withValues(alpha: 0.9) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stylized Language AppBar Action Button displaying A ⇄ अ
class LanguageAppBarButton extends StatelessWidget {
  const LanguageAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LanguageSelectionDialog.show(context),
      borderRadius: BorderRadius.circular(20),
      child: Tooltip(
        message: 'select_language'.tr,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Stack(
              children: [
                const Positioned(
                  left: 1,
                  top: 1,
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1,
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Positioned(
                  right: 1,
                  bottom: 1,
                  child: Text(
                    'अ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
