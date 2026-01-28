import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NotificationController extends GetxController {
  // List of notifications
  var notifications = <NotificationItem>[].obs;

  // Selected notifications
  var selectedNotifications = <String>[].obs;

  // Is select mode active
  var isSelectMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    // Load dummy data - replace with API call
    notifications.value = [
      NotificationItem(
        id: '1',
        title: 'Order Confirmed',
        message: 'Your order #ORD-2024-001 has been confirmed',
        time: '10 min ago',
        isRead: false,
        icon: Icons.shopping_bag_outlined,
        iconColor: Colors.green,
      ),
      NotificationItem(
        id: '2',
        title: 'Payment Successful',
        message: 'Payment of ₹2,499 has been received',
        time: '1 hour ago',
        isRead: true,
        icon: Icons.payment_outlined,
        iconColor: Colors.blue,
      ),
      NotificationItem(
        id: '3',
        title: 'Delivery Update',
        message: 'Your package will be delivered by 5 PM today',
        time: '3 hours ago',
        isRead: false,
        icon: Icons.local_shipping_outlined,
        iconColor: Colors.orange,
      ),
      NotificationItem(
        id: '4',
        title: 'New Message',
        message: 'You have a new message from seller',
        time: '5 hours ago',
        isRead: true,
        icon: Icons.message_outlined,
        iconColor: Colors.purple,
      ),
      NotificationItem(
        id: '5',
        title: 'Discount Alert',
        message: 'Get 20% off on your next purchase',
        time: '1 day ago',
        isRead: false,
        icon: Icons.discount_outlined,
        iconColor: Colors.red,
      ),
      NotificationItem(
        id: '6',
        title: 'Account Security',
        message: 'New login detected from Mumbai',
        time: '2 days ago',
        isRead: true,
        icon: Icons.security_outlined,
        iconColor: Colors.teal,
      ),
      NotificationItem(
        id: '7',
        title: 'Review Request',
        message: 'Rate your recent purchase',
        time: '3 days ago',
        isRead: true,
        icon: Icons.star_outline,
        iconColor: Colors.amber,
      ),
    ];
  }

  void toggleSelection(String id) {
    if (selectedNotifications.contains(id)) {
      selectedNotifications.remove(id);
    } else {
      selectedNotifications.add(id);
    }
  }

  void selectAll() {
    selectedNotifications.value = notifications.map((n) => n.id).toList();
  }

  void clearSelection() {
    selectedNotifications.clear();
  }

  void deleteSelected() {
    notifications.removeWhere(
          (notification) => selectedNotifications.contains(notification.id),
    );
    selectedNotifications.clear();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifications.refresh();
  }

  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
    if (!isSelectMode.value) {
      selectedNotifications.clear();
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.iconColor,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    IconData? icon,
    Color? iconColor,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}