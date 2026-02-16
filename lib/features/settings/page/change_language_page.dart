import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/language_controller.dart';
import '../../../widgets/custom_snack_bar.dart';

class ChangeLanguagePage extends GetView<LanguageController> {
  const ChangeLanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already done
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController());
    }
    
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('select_language'.tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'select_language'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'choose_your_preferred_language'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // English Option
            Obx(() => _buildLanguageTile(
              context: context,
              languageCode: 'en',
              languageName: 'English',
              nativeName: 'English',
              flag: '🇬🇧',
              isSelected: controller.currentLanguageCode == 'en',
              onTap: () => _changeLanguage('en'),
            )),
            
            const SizedBox(height: 16),
            
            // Marathi Option
            Obx(() => _buildLanguageTile(
              context: context,
              languageCode: 'mr',
              languageName: 'Marathi',
              nativeName: 'मराठी',
              flag: '🇮🇳',
              isSelected: controller.currentLanguageCode == 'mr',
              onTap: () => _changeLanguage('mr'),
            )),
            

          ],
        ),
      ),
    );
  }

 /* Widget _buildLanguageTile({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              // Flag
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey[300]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Language details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.primaryColor : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nativeName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }*/


  Widget _buildLanguageTile({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Flag
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade100,
              child: Text(flag, style: const TextStyle(fontSize: 18)),
            ),

            const SizedBox(width: 14),

            // Language text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Check
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.primaryColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _changeLanguage(String languageCode) async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Change language
      await controller.changeLanguage(languageCode);
      
      // Small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Close loading
      Get.back();
      
      // Show success message
      CustomSnackBar.showSuccess(
        message: 'language_changed_success'.tr,
      );
      
      // Go back to settings
      Get.back();
      
    } catch (e) {
      // Close loading if open
      if (Get.isDialogOpen == true) Get.back();
      
      CustomSnackBar.showError(
        message: 'Failed to change language: $e',
      );
    }
  }
}
