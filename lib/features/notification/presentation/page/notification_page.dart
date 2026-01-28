import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/notification_controller.dart';


class NotificationPage extends GetWidget<NotificationController>{
  NotificationPage({super.key});



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: Column(
        children: [
          // App Bar
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return _buildNotificationCard(
                  context: context,
                  notification: notification,
                  index: index,
                  theme: theme,
                  isDarkMode: isDarkMode,
                );
              },
            ),
          ),

          // Delete Button (Sticky at bottom)
          _buildDeleteButton(context, theme),
        ],
      ),
    );
  }




  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationItem notification,
    required int index,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    final controller = Get.find<NotificationController>();

    return Obx(() {
      final isSelected = controller.selectedNotifications.contains(notification.id);
      final isMode = controller.isSelectMode.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.05)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isMode
                ? () {
              controller.toggleSelection(notification.id);
            }
                : () {
              // Handle notification tap (view details)
              Get.snackbar(
                notification.title,
                notification.message,
                backgroundColor: theme.primaryColor,
                colorText: Colors.white,
              );
            },
            onLongPress: () {
              if (!isMode) {
                controller.isSelectMode.value = true;
                controller.selectedNotifications.add(notification.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: notification.iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: notification.isRead
                                      ? Colors.grey.shade600
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                if (isMode) const SizedBox(width: 8),
                                Text(
                                  notification.time,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!notification.isRead && !isMode)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'New',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDeleteButton(BuildContext context, ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle delete selected notifications
                  Get.defaultDialog(
                    title: 'Delete Notifications',
                    middleText: 'Are you sure you want to delete selected notifications?',
                    textConfirm: 'Delete',
                    textCancel: 'Cancel',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back();
                      Get.snackbar(
                        'Deleted',
                        'Selected notifications removed',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    },
                    buttonColor: Colors.red,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                icon: const Icon(Icons.delete_outline, size: 22),
                label: const Text(
                  'Delete Selected (0)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
