import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

enum SnackBarType { success, warning, error, info }

class CustomSnackBar {
  static void show({
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    _showBottom(
      message: message,
      type: type,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void _showBottom({
    required String message,
    required SnackBarType type,
    required Duration duration,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    // Using Get.showSnackbar ensures it appears above BottomSheets and Dialogs
    Get.showSnackbar(GetSnackBar(
      messageText: _SnackBarContent(message: message, type: type, onTap: onTap),
      backgroundColor: Colors.transparent,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      borderRadius: 16,
      padding: EdgeInsets.zero,
      duration: duration,
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
    ));
  }

  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    // Translate message if it's a translation key
    final translatedMessage = message.tr;
    show(
      message: translatedMessage,
      type: SnackBarType.success,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    // Translate message if it's a translation key
    final translatedMessage = message.tr;
    show(
      message: translatedMessage,
      type: SnackBarType.warning,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    // Translate message if it's a translation key
    final translatedMessage = message.tr;
    show(
      message: translatedMessage,
      type: SnackBarType.error,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void showInfo({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    // Translate message if it's a translation key
    final translatedMessage = message.tr;
    show(
      message: translatedMessage,
      type: SnackBarType.info,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback? onTap;

  const _SnackBarContent({
    required this.message,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: () {
             ScaffoldMessenger.of(context).hideCurrentSnackBar();
             onTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor().withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getShadowColor(),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: TextStyle(
                          color: _getIconColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message.length > 1000 ? "${message.substring(0, 1000)}..." : message,
                        maxLines: 15,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _getTextColor(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: _getTextColor(context).withOpacity(0.6),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case SnackBarType.success: return 'Success';
      case SnackBarType.warning: return 'Warning';
      case SnackBarType.error: return 'Error';
      case SnackBarType.info: return 'Info';
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    return context.theme.cardColor;
  }

  Color _getBorderColor() {
    switch (type) {
      case SnackBarType.success: return Colors.green.withOpacity(0.3);
      case SnackBarType.warning: return Colors.orange.withOpacity(0.3);
      case SnackBarType.error: return Colors.red.withOpacity(0.3);
      case SnackBarType.info: return Colors.blue.withOpacity(0.3);
    }
  }

  Color _getShadowColor() {
    return Colors.black.withOpacity(0.08);
  }

  Color _getTextColor(BuildContext context) {
    return context.theme.textTheme.bodyMedium?.color ?? Colors.black87;
  }

  Color _getIconColor() {
    switch (type) {
      case SnackBarType.success: return Colors.green[600]!;
      case SnackBarType.warning: return Colors.orange[600]!;
      case SnackBarType.error: return Colors.red[600]!;
      case SnackBarType.info: return Colors.blue[600]!;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case SnackBarType.success: return Icons.check_circle_rounded;
      case SnackBarType.warning: return Icons.warning_rounded;
      case SnackBarType.error: return Icons.error_rounded;
      case SnackBarType.info: return Icons.info_rounded;
    }
  }
}
