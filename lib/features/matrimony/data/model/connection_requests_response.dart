import '../../../Auth/login/data/model/res_login_model.dart';

class ConnectionRequestsResponse {
  bool? success;
  ConnectionRequestsData? data;

  ConnectionRequestsResponse({this.success, this.data});

  ConnectionRequestsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? ConnectionRequestsData.fromJson(json['data']) : null;
  }
}

class ConnectionRequestsData {
  List<ConnectionRequest>? sentRequests;
  List<ConnectionRequest>? receivedRequests;
  List<ConnectionRequest>? connectedUsers;

  ConnectionRequestsData({this.sentRequests, this.receivedRequests, this.connectedUsers});

  ConnectionRequestsData.fromJson(Map<String, dynamic> json) {
    if (json['sent_requests'] != null) {
      sentRequests = <ConnectionRequest>[];
      json['sent_requests'].forEach((v) {
        sentRequests!.add(ConnectionRequest.fromJson(v));
      });
    }
    if (json['received_requests'] != null) {
      receivedRequests = <ConnectionRequest>[];
      json['received_requests'].forEach((v) {
        receivedRequests!.add(ConnectionRequest.fromJson(v));
      });
    }
    if (json['connected_users'] != null) {
      connectedUsers = <ConnectionRequest>[];
      json['connected_users'].forEach((v) {
        connectedUsers!.add(ConnectionRequest.fromJson(v));
      });
    }
  }
}

class ConnectionRequest {
  int? id;
  int? senderId;
  int? receiverId;
  String? status;
  String? message;
  String? responseMessage;
  String? respondedAt;
  String? createdAt;
  String? updatedAt;
  User? sender;
  User? receiver;
  User? connectedProfile;

  ConnectionRequest({
    this.id,
    this.senderId,
    this.receiverId,
    this.status,
    this.message,
    this.responseMessage,
    this.respondedAt,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
    this.connectedProfile,
  });

  ConnectionRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    status = json['status'];
    message = json['message'];
    responseMessage = json['response_message'];
    respondedAt = json['responded_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = json['sender'] != null ? User.fromJson(json['sender']) : null;
    receiver = json['receiver'] != null ? User.fromJson(json['receiver']) : null;
    connectedProfile = json['connected_profile'] != null ? User.fromJson(json['connected_profile']) : null;
  }
}
