class AgoraJoinTokenData {
  final bool success;
  final String message;
  final String appId;
  final String channel;
  final String token;
  final String userAccount;
  final int uid;
  final Map<String, dynamic> raw;

  AgoraJoinTokenData({
    required this.success,
    required this.message,
    required this.appId,
    required this.channel,
    required this.token,
    required this.userAccount,
    required this.uid,
    required this.raw,
  });

  factory AgoraJoinTokenData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map = json;
    if (json['data'] is Map<String, dynamic>) {
      map = json['data'] as Map<String, dynamic>;
    }

    final success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 'success' ||
        map['token'] != null ||
        map['rtc_token'] != null;

    final message = (json['message'] ?? map['message'] ?? '').toString();

    final appId = (map['app_id'] ??
            map['appId'] ??
            map['agora_app_id'] ??
            map['agoraAppId'] ??
            json['app_id'] ??
            json['agora_app_id'] ??
            '')
        .toString();

    final channel = (map['channel_name'] ??
            map['channel'] ??
            map['agora_channel'] ??
            map['agoraChannel'] ??
            json['channel_name'] ??
            json['agora_channel'] ??
            '')
        .toString();

    final token = (map['token'] ??
            map['rtc_token'] ??
            map['rtcToken'] ??
            map['agora_token'] ??
            map['join_token'] ??
            json['token'] ??
            json['rtc_token'] ??
            '')
        .toString();

    final rawUid = (map['uid'] ?? map['user_id'] ?? map['userId'] ?? json['uid'] ?? '').toString();
    final uid = int.tryParse(rawUid) ?? 0;

    return AgoraJoinTokenData(
      success: success,
      message: message,
      appId: appId,
      channel: channel,
      token: token,
      userAccount: rawUid,
      uid: uid,
      raw: map,
    );
  }
}
