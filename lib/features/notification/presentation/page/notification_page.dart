import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/notification_controller.dart';
import '../../../../core/widgets/custom_confirm_dialog.dart';
import '../../data/model/notification_model.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: Stack(
        children: [
          Column(
            children: [
              // App Bar
              _buildAppBar(context, theme),

              // Notifications List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerLoading();
                  }

                  if (controller.notifications.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), // Bottom padding for FAB/Action bar
                    itemCount: controller.notifications.length + (controller.isMoreLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.notifications.length) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      
                      final notification = controller.notifications[index];
                      return _buildNotificationCard(
                        context: context,
                        notification: notification,
                        theme: theme,
                        isDarkMode: isDarkMode,
                      );
                    },
                  );
                }),
              ),
            ],
          ),

          // Sticky Bottom Action Bar (Select Mode)
          Obx(() => controller.isSelectMode.value 
              ? _buildBottomActionBar(context, theme)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Container(
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
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => controller.unreadCount.value > 0 
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.unreadCount.value} New',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ) 
                      : const SizedBox.shrink()),
                ],
              ),
              Obx(() => controller.isSelectMode.value
                  ? TextButton(
                      onPressed: controller.toggleSelectMode,
                      child: const Text("Done"),
                    )
                  : IconButton(
                        onPressed: controller.notifications.isNotEmpty 
                            ? controller.toggleSelectMode 
                            : null, 
                        icon: const Icon(Icons.checklist),
                    )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notification,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    // Determine data from map
    final data = notification.data ?? {};
    final title = notification.type ?? 'Notification';
    final message = notification.message ?? 'You have a new notification';
    final isRead = notification.readAt != null;
    
    // Determine visuals based on type or content
    IconData icon = Icons.notifications_outlined;
    Color iconColor = Colors.blue;
    
    // Example logic based on hypothetical types (adjust as needed)
    final type = notification.type ?? '';
    if (type.contains('Order')) {
      icon = Icons.shopping_bag_outlined;
      iconColor = Colors.green;
    } else if (type.contains('Payment')) {
      icon = Icons.payment_outlined;
      iconColor = Colors.purple;
    } else if (type.contains('Alert')) {
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.red;
    }

    // Format Date
    String timeString = "Just now";
    if (notification.createdAt != null) {
      try {
        final date = DateTime.parse(notification.createdAt!);
        final now = DateTime.now();
        final diff = now.difference(date);
        
        if (diff.inDays > 0) {
          timeString = DateFormat('MMM d, y').format(date);
        } else if (diff.inHours > 0) {
          timeString = "${diff.inHours}h ago";
        } else if (diff.inMinutes > 0) {
          timeString = "${diff.inMinutes}m ago";
        }
      } catch (e) {
        timeString = "";
      }
    }

    return Obx(() {
      final isSelected = controller.selectedNotifications.contains(notification.id);
      final isMode = controller.isSelectMode.value;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.05)
              : (isRead ? theme.cardColor : theme.primaryColor.withOpacity(0.02)),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                    if (notification.id != null) {
                      controller.toggleSelection(notification.id.toString());
                    }
                  }
                : () {
                    // Tap to view detail or mark as read logic could go here
                  },
            onLongPress: () {
              if (!isMode && notification.id != null) {
                controller.isSelectMode.value = true;
                controller.selectedNotifications.add(notification.id.toString());
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Checkbox
                   if (isMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 12),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? theme.primaryColor : Colors.grey,
                        size: 24,
                      ),
                    ),

                  // Notification Icon
                  if (!isMode)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 22,
                      ),
                    ),

                  if (!isMode) const SizedBox(width: 16),

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
                                title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                  color: isRead ? Colors.grey.shade700 : theme.textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              timeString,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 11
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildBottomActionBar(BuildContext context, ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.selectAll,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Select All"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed: controller.selectedNotifications.isNotEmpty 
                      ? () => _showDeleteConfirmDialog(context) 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text("Delete (${controller.selectedNotifications.length})"),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    CustomConfirmDialog.show(
      title: 'Delete Notifications',
      message: 'Are you sure you want to delete ${controller.selectedNotifications.length} notifications?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
      icon: Icons.delete_outline,
      onConfirm: () {
        controller.deleteSelected();
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No Notifications",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading.rounded(height: 80),
        );
      },
    );
  }
}
