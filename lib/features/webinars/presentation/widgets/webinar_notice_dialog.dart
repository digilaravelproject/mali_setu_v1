import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';

enum WebinarNoticeType {
  info,
  warning,
  registrationClosed,
  completed,
  success,
  error,
}

class WebinarNoticeDialog extends StatelessWidget {
  final String title;
  final String message;
  final WebinarNoticeType type;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const WebinarNoticeDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = WebinarNoticeType.info,
    this.buttonText = "Got It",
    this.onButtonPressed,
  });

  static Future<void> show({
    BuildContext? context,
    required String title,
    required String message,
    WebinarNoticeType type = WebinarNoticeType.info,
    String buttonText = "Got It",
    VoidCallback? onButtonPressed,
  }) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return Future.value();

    return showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => WebinarNoticeDialog(
        title: title,
        message: message,
        type: type,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  static void showRegistrationClosed({
    BuildContext? context,
    String? message,
  }) {
    show(
      context: context,
      title: "Registration Closed",
      message: message ??
          "This webinar has already started and registration is now closed. Only registered participants can join.",
      type: WebinarNoticeType.registrationClosed,
      buttonText: "Understood",
    );
  }

  static void showUpcoming({
    BuildContext? context,
    required String dateString,
    required String timeString,
  }) {
    show(
      context: context,
      title: "Webinar Starts Soon",
      message:
          "You are successfully registered for this webinar!\n\nThe live room will open when the host goes live on $dateString at $timeString.",
      type: WebinarNoticeType.info,
      buttonText: "Got It",
    );
  }

  static void showCompleted({
    BuildContext? context,
  }) {
    show(
      context: context,
      title: "Webinar Completed",
      message:
          "This webinar session has already concluded. Please check out other upcoming webinars.",
      type: WebinarNoticeType.completed,
      buttonText: "Close",
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color iconBgColor;
    IconData iconData;

    switch (type) {
      case WebinarNoticeType.registrationClosed:
        primaryColor = const Color(0xFFEA580C); // Warm Orange
        iconBgColor = const Color(0xFFFFF7ED);
        iconData = Icons.lock_clock_rounded;
        break;
      case WebinarNoticeType.warning:
        primaryColor = const Color(0xFFD97706); // Amber
        iconBgColor = const Color(0xFFFEF3C7);
        iconData = Icons.warning_amber_rounded;
        break;
      case WebinarNoticeType.completed:
        primaryColor = const Color(0xFF64748B); // Slate
        iconBgColor = const Color(0xFFF1F5F9);
        iconData = Icons.event_available_rounded;
        break;
      case WebinarNoticeType.success:
        primaryColor = const Color(0xFF10B981); // Emerald
        iconBgColor = const Color(0xFFECFDF5);
        iconData = Icons.check_circle_rounded;
        break;
      case WebinarNoticeType.error:
        primaryColor = const Color(0xFFEF4444); // Red
        iconBgColor = const Color(0xFFFEF2F2);
        iconData = Icons.error_outline_rounded;
        break;
      case WebinarNoticeType.info:
        primaryColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        iconData = Icons.event_note_rounded;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Right Close Icon
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),

            // Top Icon with soft ripple ring
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 10),

            // Message Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (onButtonPressed != null) {
                    onButtonPressed!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
