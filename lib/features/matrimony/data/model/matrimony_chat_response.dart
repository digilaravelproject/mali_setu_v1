import '../../../Auth/login/data/model/res_login_model.dart';

class MatrimonyConversationResponse {
  bool? success;
  MatrimonyConversationData? data;

  MatrimonyConversationResponse({this.success, this.data});

  MatrimonyConversationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatrimonyConversationData.fromJson(json['data']) : null;
  }
}

class MatrimonyConversationData {
  List<MatrimonyConversation>? conversations;

  MatrimonyConversationData({this.conversations});

  MatrimonyConversationData.fromJson(Map<String, dynamic> json) {
    if (json['conversations'] != null) {
      conversations = <MatrimonyConversation>[];
      json['conversations'].forEach((v) {
        conversations!.add(MatrimonyConversation.fromJson(v));
      });
    }
  }
}

class MatrimonyConversation {
  int? id;
  int? user1Id;
  int? user2Id;
  String? lastMessageAt;
  String? createdAt;
  String? updatedAt;
  User? user1;
  User? user2;
  List<MatrimonyMessage>? messages;

  MatrimonyConversation({
    this.id,
    this.user1Id,
    this.user2Id,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
    this.user1,
    this.user2,
    this.messages,
  });

  MatrimonyConversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user1Id = json['user1_id'];
    user2Id = json['user2_id'];
    lastMessageAt = json['last_message_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user1 = json['user1'] != null ? User.fromJson(json['user1']) : null;
    user2 = json['user2'] != null ? User.fromJson(json['user2']) : null;
    if (json['messages'] != null) {
      messages = <MatrimonyMessage>[];
      json['messages'].forEach((v) {
        messages!.add(MatrimonyMessage.fromJson(v));
      });
    }
  }
}

class MatrimonyMessagesResponse {
  bool? success;
  MatrimonyMessagesData? data;

  MatrimonyMessagesResponse({this.success, this.data});

  MatrimonyMessagesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatrimonyMessagesData.fromJson(json['data']) : null;
  }
}

class MatrimonyMessagesData {
  MatrimonyConversation? conversation;
  MatrimonyMessagesList? messages;

  MatrimonyMessagesData({this.conversation, this.messages});

  MatrimonyMessagesData.fromJson(Map<String, dynamic> json) {
    conversation = json['conversation'] != null ? MatrimonyConversation.fromJson(json['conversation']) : null;
    messages = json['messages'] != null ? MatrimonyMessagesList.fromJson(json['messages']) : null;
  }
}

class MatrimonyMessagesList {
  int? currentPage;
  List<MatrimonyMessage>? data;
  int? lastPage;
  int? total;

  MatrimonyMessagesList({this.currentPage, this.data, this.lastPage, this.total});

  MatrimonyMessagesList.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <MatrimonyMessage>[];
      json['data'].forEach((v) {
        data!.add(MatrimonyMessage.fromJson(v));
      });
    }
    lastPage = json['last_page'];
    total = json['total'];
  }
}

class MatrimonyMessage {
  int? id;
  int? conversationId;
  int? senderId;
  String? messageText;
  String? messageType;
  String? attachmentPath;
  bool? isRead;
  String? createdAt;
  String? updatedAt;
  User? sender;

  MatrimonyMessage({
    this.id,
    this.conversationId,
    this.senderId,
    this.messageText,
    this.messageType,
    this.attachmentPath,
    this.isRead,
    this.createdAt,
    this.updatedAt,
    this.sender,
  });

  MatrimonyMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'] is String ? int.tryParse(json['conversation_id']) : json['conversation_id'];
    senderId = json['sender_id'];
    messageText = json['message_text'];
    messageType = json['message_type'];
    attachmentPath = json['attachment_path'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = json['sender'] != null ? User.fromJson(json['sender']) : null;
  }
}
