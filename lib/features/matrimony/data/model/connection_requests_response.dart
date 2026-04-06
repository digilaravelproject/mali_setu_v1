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
    
    // Helper to parse User or MatrimonyProfile structure
    User? parseUser(dynamic data) {
      if (data == null) return null;
      // Check if it's the nested MatrimonyProfile structure
      if (data['personal_details'] != null) {
        final personal = data['personal_details'];
        final professional = data['professional_details'];
        final location = data['location_details'];
        
        List<String> photos = [];
        if (personal['photos'] != null) {
          photos = List<String>.from(personal['photos']);
        }

        return User(
          id: data['user_id'] ?? data['id'],
         // name: personal['name'] ?? "Unknown",
          name: [
            personal['title'],
            personal['first_name'],
            personal['last_name']
          ]
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .join(' ')
              .isNotEmpty
              ? [
            personal['title'],
            personal['first_name'],
            personal['last_name']
          ]
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .join(' ')
              : '',
          age: data['age'],
          occupation: personal['occupation'] ?? professional?['job_title'],
          city: location?['city'],
          state: location?['state'],
          profileImage: photos.isNotEmpty ? photos.first : null,
          // Map other fields if necessary
        );
      } else {
        // Standard User structure
        return User.fromJson(data);
      }
    }

    sender = parseUser(json['sender'] ?? json['sender_profile']);
    receiver = parseUser(json['receiver'] ?? json['receiver_profile']);
    connectedProfile = parseUser(json['connected_profile']);
  }
}
