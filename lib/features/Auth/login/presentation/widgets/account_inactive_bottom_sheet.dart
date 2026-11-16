import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../../core/controllers/support_controller.dart';

/// Bottom sheet shown when login fails due to an inactive account / pending administrator activation.
class AccountInactiveBottomSheet extends StatelessWidget {
  final String? message;
  final String? userEmail;

  const AccountInactiveBottomSheet({
    super.key,
    this.message,
    this.userEmail,
  });

  /// Displays the Account Inactive bottom sheet
  static Future<void> show({
    BuildContext? context,
    String? message,
    String? userEmail,
  }) async {
    await Get.bottomSheet(
      AccountInactiveBottomSheet(
        message: message,
        userEmail: userEmail,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'en';
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    final String title = isMr
        ? "खाते निष्क्रिय आहे"
        : (isHi ? "खाता अक्रिय है" : "Account Inactive");

    final String badgeText = isMr
        ? "प्रशासक मंजुरी प्रलंबित"
        : (isHi ? "एडमिन मंजूरी प्रतीक्षित" : "Pending Admin Approval");

    final String displayMessage = (message != null && message!.trim().isNotEmpty)
        ? message!.trim()
        : (isMr
            ? "आपले खाते सध्या निष्क्रिय आहे. कृपया प्रशासकाद्वारे सक्रिय करण्याची प्रतीक्षा करा."
            : (isHi
                ? "आपका खाता अभी अक्रिय है। कृपया एडमिन द्वारा सक्रिय करने की प्रतीक्षा करें।"
                : "Your account is inactive. Please wait for administrator activation."));

    final String infoNote = isMr
        ? "आपली नोंदणी यशस्वीरीत्या प्राप्त झाली आहे. पडताळणी पूर्ण झाल्यानंतर आपले खाते सक्रिय केले जाईल."
        : (isHi
            ? "आपका पंजीकरण सफलतापूर्वक प्राप्त हो चुका है। सत्यापन पूर्ण होने के बाद आपका खाता सक्रिय कर दिया जाएगा।"
            : "Your registration has been received. Our team will verify and activate your account shortly.");

    final String whatsappBtnText = isMr
        ? "सपोर्टशी संपर्क साधा (WhatsApp)"
        : (isHi ? "सपोर्ट से संपर्क करें (WhatsApp)" : "Contact Support on WhatsApp");

    final String closeBtnText = isMr ? "समजले" : (isHi ? "ठीक है" : "Okay, Got it");

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Shield / Admin pending icon
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Warm amber tint
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFEDD5),
                width: 2.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: Color(0xFFF97316),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 5),
                Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),

          // Message
          Text(
            displayMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    infoNote,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Support Button (WhatsApp)
          InkWell(
            onTap: () {
              Get.back();
              final emailText = (userEmail != null && userEmail!.trim().isNotEmpty)
                  ? " (Email: ${userEmail!.trim()})"
                  : "";
              SupportController.to.openSupportChat(
                message:
                    "Hello Mali Setu Support Team, my account$emailText is inactive. Please activate my account.",
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    whatsappBtnText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Close Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                closeBtnText,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
