import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repository/notification_repository.dart';
import '../../data/model/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  // List of notifications
  var notifications = <NotificationModel>[].obs;
  
  // Pagination
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;

  // Unread Count
  var unreadCount = 0.obs;

  // Selected notifications for bulk delete
  var selectedNotifications = <String>[].obs;

  // Is select mode active
  var isSelectMode = false.obs;

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
    
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage.value < lastPage.value && !isMoreLoading.value) {
          loadMoreNotifications();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final response = await repository.getNotifications(page: 1);
      if (response.success == true && response.data != null) {
        notifications.value = response.data!.notifications ?? [];
        unreadCount.value = response.data!.unreadCount ?? 0;
        
        if (response.data!.pagination != null) {
          currentPage.value = response.data!.pagination!.currentPage ?? 1;
          lastPage.value = response.data!.pagination!.lastPage ?? 1;
        }
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    try {
      isMoreLoading.value = true;
      int nextPage = currentPage.value + 1;
      final response = await repository.getNotifications(page: nextPage);
      if (response.success == true && response.data != null) {
        notifications.addAll(response.data!.notifications ?? []);
        
        if (response.data!.pagination != null) {
          currentPage.value = response.data!.pagination!.currentPage ?? nextPage;
          lastPage.value = response.data!.pagination!.lastPage ?? currentPage.value;
        }
      }
    } catch (e) {
      print('Error loading more notifications: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final response = await repository.getUnreadCount();
      if (response.success == true && response.data != null) {
        unreadCount.value = response.data!.unreadCount ?? 0;
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
      // Determine if we should decrement unread count? 
      // API doesn't return updated count, so maybe reload count or just leave it.
      // Usually deleting implies it's gone, so count might change if it was unread.
      // For now, let's reload count to be safe.
      loadUnreadCount();
      Get.snackbar('Success', 'Notification deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notification');
    }
  }

  Future<void> deleteSelected() async {
    if (selectedNotifications.isEmpty) return;

    try {
      // Create a copy of IDs because selectedNotifications will be cleared
      List<String> idsToDelete = List.from(selectedNotifications);
      
      await repository.deleteMultipleNotifications(idsToDelete);
      
      notifications.removeWhere((n) => idsToDelete.contains(n.id));
      selectedNotifications.clear();
      isSelectMode.value = false;
      loadUnreadCount();
      Get.snackbar('Success', 'Selected notifications deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notifications');
    }
  }

  void toggleSelection(String id) {
    if (selectedNotifications.contains(id)) {
      selectedNotifications.remove(id);
    } else {
      selectedNotifications.add(id);
    }
  }

  void selectAll() {
    // Only select currently loaded notifications
    selectedNotifications.value = notifications.map((n) => n.id!).toList();
  }

  void clearSelection() {
    selectedNotifications.clear();
  }

  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
    if (!isSelectMode.value) {
      selectedNotifications.clear();
    }
  }
}