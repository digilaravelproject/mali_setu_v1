import 'package:edu_cluezer/features/Auth/login/data/model/res_login_model.dart';
import 'package:edu_cluezer/features/matrimony/data/model/search_matrimony_response.dart';

class BlockedUsersResponse {
  bool? success;
  BlockedUsersData? data;

  BlockedUsersResponse({this.success, this.data});

  BlockedUsersResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? BlockedUsersData.fromJson(json['data']) : null;
  }
}

class BlockedUsersData {
  List<BlockedUserItem>? blockedUsers;
  int? total;

  BlockedUsersData({this.blockedUsers, this.total});

  BlockedUsersData.fromJson(Map<String, dynamic> json) {
    if (json['blocked_users'] != null) {
      blockedUsers = <BlockedUserItem>[];
      json['blocked_users'].forEach((v) {
        blockedUsers!.add(BlockedUserItem.fromJson(v));
      });
    }
    total = json['total'];
  }
}

class BlockedUserItem {
  int? blockId;
  int? userId;
  bool? isBlock;
  String? blockedAt;
  User? user;
  MatrimonyProfile? profile;

  BlockedUserItem({
    this.blockId,
    this.userId,
    this.isBlock,
    this.blockedAt,
    this.user,
    this.profile,
  });

  BlockedUserItem.fromJson(Map<String, dynamic> json) {
    blockId = json['block_id'];
    userId = json['user_id'];
    isBlock = json['is_block'] == true || json['is_block'] == 1 || json['is_block']?.toString() == 'true';
    blockedAt = json['blocked_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['profile'] != null) {
      profile = MatrimonyProfile.fromJson(json['profile']);
    } else if (json['matrimony_profile'] != null) {
      profile = MatrimonyProfile.fromJson(json['matrimony_profile']);
    } else if (json['user'] != null && json['user'] is Map && json['user']['matrimony_profile'] != null) {
      profile = MatrimonyProfile.fromJson(json['user']['matrimony_profile']);
    }
  }
}
