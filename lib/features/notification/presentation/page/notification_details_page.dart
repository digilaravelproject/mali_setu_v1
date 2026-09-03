import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/model/notification_model.dart';

class NotificationDetailsPage extends StatelessWidget {
  const NotificationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationModel notification = Get.arguments;
    final theme = Theme.of(context);
    
    String timeString = "";
    if (notification.createdAt != null) {
      try {
        final date = DateTime.parse(notification.createdAt!);
        timeString = DateFormat('MMMM d, yyyy - h:mm a').format(date);
      } catch (e) {
        timeString = notification.createdAt ?? "";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title ?? 'Notification'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              timeString,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const Divider(height: 32),
            Text(
              notification.message ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
