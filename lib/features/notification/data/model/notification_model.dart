/*class NotificationResponse {
  final bool? success;
  final NotificationData? data;
  final String? message;

  NotificationResponse({
    this.success,
    this.data,
    this.message,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'],
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class NotificationData {
  final List<NotificationModel>? notifications;
  final Pagination? pagination;
  final int? unreadCount;

  NotificationData({
    this.notifications,
    this.pagination,
    this.unreadCount,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notifications: json['notifications'] != null
          ? List<NotificationModel>.from(json['notifications'].map((x) => NotificationModel.fromJson(x)))
          : null,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      unreadCount: json['unread_count'],
    );
  }
}

class NotificationModel {
  final String? id;
  final String? type;
  final String? notifiableType;
  final int? notifiableId;
  final Map<String, dynamic>? data;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  NotificationModel({
    this.id,
    this.type,
    this.notifiableType,
    this.notifiableId,
    this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      notifiableType: json['notifiable_type'],
      notifiableId: json['notifiable_id'],
      data: json['data'],
      readAt: json['read_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Pagination {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? from;
  final int? to;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
      from: json['from'],
      to: json['to'],
    );
  }
}*/




class NotificationResponse {
  final bool? success;
  final NotificationData? data;
  final String? message;

  NotificationResponse({
    this.success,
    this.data,
    this.message,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'],
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class NotificationData {
  final List<NotificationModel>? notifications;
  final Pagination? pagination;
  final int? unreadCount;

  NotificationData({
    this.notifications,
    this.pagination,
    this.unreadCount,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notifications: json['notifications'] != null
          ? List<NotificationModel>.from(
          json['notifications'].map((x) => NotificationModel.fromJson(x)))
          : null,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      unreadCount: json['unread_count'],
    );
  }
}

class NotificationModel {
  final String? id; // Modified from int? to String? for consistency
  final String? userId; // Modified from int? to String?
  final String? type;
  final String? title;
  final String? message;
  final Map<String, dynamic>? data;
  final String? actionUrl; // JSON me "action_url"
  final String? priority;
  final String? channel;
  final bool? isRead; // JSON me "is_read"
  final String? readAt;
  final bool? emailSent; // JSON me "email_sent"
  final String? emailSentAt;
  final bool? pushSent; // JSON me "push_sent"
  final String? pushSentAt;
  final String? relatedType; // JSON me "related_type"
  final int? relatedId; // JSON me "related_id"
  final String? createdAt;
  final String? updatedAt;

  NotificationModel({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.message,
    this.data,
    this.actionUrl,
    this.priority,
    this.channel,
    this.isRead,
    this.readAt,
    this.emailSent,
    this.emailSentAt,
    this.pushSent,
    this.pushSentAt,
    this.relatedType,
    this.relatedId,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      actionUrl: json['action_url'],
      priority: json['priority'],
      channel: json['channel'],
      isRead: json['is_read'],
      readAt: json['read_at'],
      emailSent: json['email_sent'],
      emailSentAt: json['email_sent_at'],
      pushSent: json['push_sent'],
      pushSentAt: json['push_sent_at'],
      relatedType: json['related_type'],
      relatedId: json['related_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Pagination {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? from;
  final int? to;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
      from: json['from'],
      to: json['to'],
    );
  }
}




class UnreadCountResponse {
  final bool? success;
  final UnreadCountData? data;

  UnreadCountResponse({this.success, this.data});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'],
      data: json['data'] != null ? UnreadCountData.fromJson(json['data']) : null,
    );
  }
}

class UnreadCountData {
  final int? unreadCount;

  UnreadCountData({this.unreadCount});

  factory UnreadCountData.fromJson(Map<String, dynamic> json) {
    return UnreadCountData(
      unreadCount: json['unread_count'],
    );
  }
}
