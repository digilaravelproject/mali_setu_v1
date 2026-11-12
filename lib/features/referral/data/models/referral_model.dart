// -------------------------------------------------------------
// 1. Referred User Item (API 1 & API 2)
// -------------------------------------------------------------
class ReferredUserItem {
  final int id;
  final String? referralCodeUsed;
  final num commissionPoints;
  final String status;
  final String? referredAt;
  final ReferralUserInfo? user;

  ReferredUserItem({
    required this.id,
    this.referralCodeUsed,
    this.commissionPoints = 0,
    this.status = 'active',
    this.referredAt,
    this.user,
  });

  factory ReferredUserItem.fromJson(Map<String, dynamic> json) {
    return ReferredUserItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      referralCodeUsed: json['referral_code_used']?.toString(),
      commissionPoints: json['commission_points'] is num
          ? json['commission_points']
          : num.tryParse(json['commission_points']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString().toLowerCase() ?? 'active',
      referredAt: json['referred_at']?.toString(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? ReferralUserInfo.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'referral_code_used': referralCodeUsed,
    'commission_points': commissionPoints,
    'status': status,
    'referred_at': referredAt,
    'user': user?.toJson(),
  };
}

class ReferralUserInfo {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? userType;
  final String status;
  final String? photoUrl;
  final String? location;
  final String? registeredAt;

  ReferralUserInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.userType,
    this.status = 'active',
    this.photoUrl,
    this.location,
    this.registeredAt,
  });

  factory ReferralUserInfo.fromJson(Map<String, dynamic> json) {
    String? locString;
    if (json['location'] is String) {
      locString = json['location'];
    } else if (json['location'] is Map<String, dynamic>) {
      final locMap = json['location'] as Map<String, dynamic>;
      locString = [
        locMap['city_village'],
        locMap['taluka'],
        locMap['district'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }

    return ReferralUserInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Member',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      userType: json['user_type']?.toString(),
      status: json['status']?.toString().toLowerCase() ?? 'active',
      photoUrl: json['photo_url']?.toString() ?? json['profile_image']?.toString(),
      location: locString,
      registeredAt: json['registered_at']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'user_type': userType,
    'status': status,
    'photo_url': photoUrl,
    'location': location,
    'registered_at': registeredAt,
  };
}

// -------------------------------------------------------------
// 2. Referral Network Tree Node (API 3)
// -------------------------------------------------------------
class ReferralNetworkNode {
  final int userId;
  final String name;
  final String referralCode;
  final int level;
  final String? userType;
  final num commissionPoints;
  final String? location;
  final List<ReferralNetworkNode> children;

  ReferralNetworkNode({
    required this.userId,
    required this.name,
    required this.referralCode,
    this.level = 0,
    this.userType,
    this.commissionPoints = 0,
    this.location,
    this.children = const [],
  });

  factory ReferralNetworkNode.fromJson(Map<String, dynamic> json) {
    List<ReferralNetworkNode> childList = [];
    if (json['children'] != null && json['children'] is List) {
      childList = (json['children'] as List)
          .map((c) => ReferralNetworkNode.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    String? locString;
    if (json['location'] is String) {
      locString = json['location'];
    } else if (json['location'] is Map<String, dynamic>) {
      final locMap = json['location'] as Map<String, dynamic>;
      locString = [
        locMap['city_village'],
        locMap['taluka'],
        locMap['district'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }

    return ReferralNetworkNode(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'User',
      referralCode: json['referral_code']?.toString() ?? json['reffral_code']?.toString() ?? '',
      level: json['level'] is int ? json['level'] : int.tryParse(json['level']?.toString() ?? '0') ?? 0,
      userType: json['user_type']?.toString(),
      commissionPoints: json['commission_points'] is num
          ? json['commission_points']
          : num.tryParse(json['commission_points']?.toString() ?? '0') ?? 0,
      location: locString,
      children: childList,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'referral_code': referralCode,
    'level': level,
    'user_type': userType,
    'commission_points': commissionPoints,
    'location': location,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

// -------------------------------------------------------------
// 3. Volunteer Earning / Overview (API 4)
// -------------------------------------------------------------
class VolunteerEarningsData {
  final VolunteerInfo? volunteer;
  final num commissionPointsPerReferral;
  final int totalReferrals;
  final int activeReferrals;
  final num totalEarnedPoints;
  final num pendingPoints;

  VolunteerEarningsData({
    this.volunteer,
    this.commissionPointsPerReferral = 0,
    this.totalReferrals = 0,
    this.activeReferrals = 0,
    this.totalEarnedPoints = 0,
    this.pendingPoints = 0,
  });

  factory VolunteerEarningsData.fromJson(Map<String, dynamic> json) {
    return VolunteerEarningsData(
      volunteer: json['volunteer'] != null && json['volunteer'] is Map<String, dynamic>
          ? VolunteerInfo.fromJson(json['volunteer'])
          : null,
      commissionPointsPerReferral: json['commission_points_per_referral'] is num
          ? json['commission_points_per_referral']
          : num.tryParse(json['commission_points_per_referral']?.toString() ?? '0') ?? 0,
      totalReferrals: json['total_referrals'] is int
          ? json['total_referrals']
          : int.tryParse(json['total_referrals']?.toString() ?? '0') ?? 0,
      activeReferrals: json['active_referrals'] is int
          ? json['active_referrals']
          : int.tryParse(json['active_referrals']?.toString() ?? '0') ?? 0,
      totalEarnedPoints: json['total_earned_points'] is num
          ? json['total_earned_points']
          : (num.tryParse(json['total_earned_points']?.toString() ?? '') ??
              (json['volunteer'] is Map && json['volunteer']['total_earned_points'] != null
                  ? (json['volunteer']['total_earned_points'] is num
                      ? json['volunteer']['total_earned_points']
                      : num.tryParse(json['volunteer']['total_earned_points'].toString()) ?? 0)
                  : 0)),
      pendingPoints: json['pending_points'] is num
          ? json['pending_points']
          : num.tryParse(json['pending_points']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'volunteer': volunteer?.toJson(),
    'commission_points_per_referral': commissionPointsPerReferral,
    'total_referrals': totalReferrals,
    'active_referrals': activeReferrals,
    'total_earned_points': totalEarnedPoints,
    'pending_points': pendingPoints,
  };
}

class VolunteerInfo {
  final int? id;
  final String? name;
  final String? referralCode;
  final String? referralLink;
  final String? photoUrl;
  final String? userType;
  final bool isVolunteer;
  final String? volunteerStatus;
  final num commissionPoints;
  final int totalReferrals;
  final num totalEarnedPoints;
  final String? location;

  VolunteerInfo({
    this.id,
    this.name,
    this.referralCode,
    this.referralLink,
    this.photoUrl,
    this.userType,
    this.isVolunteer = false,
    this.volunteerStatus,
    this.commissionPoints = 0,
    this.totalReferrals = 0,
    this.totalEarnedPoints = 0,
    this.location,
  });

  factory VolunteerInfo.fromJson(Map<String, dynamic> json) {
    String? locString;
    if (json['location'] is String) {
      locString = json['location'];
    } else if (json['location'] is Map<String, dynamic>) {
      final locMap = json['location'] as Map<String, dynamic>;
      locString = [
        locMap['city_village'],
        locMap['taluka'],
        locMap['district'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }

    return VolunteerInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      referralCode: json['referral_code']?.toString() ?? json['reffral_code']?.toString(),
      referralLink: json['referral_link']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      userType: json['user_type']?.toString(),
      isVolunteer: json['is_volunteer'] == true,
      volunteerStatus: json['volunteer_status']?.toString(),
      commissionPoints: json['commission_points'] is num
          ? json['commission_points']
          : num.tryParse(json['commission_points']?.toString() ?? '0') ?? 0,
      totalReferrals: json['total_referrals'] is int
          ? json['total_referrals']
          : int.tryParse(json['total_referrals']?.toString() ?? '0') ?? 0,
      totalEarnedPoints: json['total_earned_points'] is num
          ? json['total_earned_points']
          : (num.tryParse(json['total_earned_points']?.toString() ?? '') ??
              (json['volunteer'] is Map && json['volunteer']['total_earned_points'] != null
                  ? (json['volunteer']['total_earned_points'] is num
                      ? json['volunteer']['total_earned_points']
                      : num.tryParse(json['volunteer']['total_earned_points'].toString()) ?? 0)
                  : 0)),
      location: locString,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'referral_code': referralCode,
    'referral_link': referralLink,
    'photo_url': photoUrl,
    'user_type': userType,
    'is_volunteer': isVolunteer,
    'volunteer_status': volunteerStatus,
    'commission_points': commissionPoints,
    'total_referrals': totalReferrals,
    'total_earned_points': totalEarnedPoints,
    'location': location,
  };
}

// -------------------------------------------------------------
// 4. Shareable Link Data (API 5)
// -------------------------------------------------------------
class ShareableLinkData {
  final String referralCode;
  final String referralLink;
  final String? shareMessage;

  ShareableLinkData({
    required this.referralCode,
    required this.referralLink,
    this.shareMessage,
  });

  factory ShareableLinkData.fromJson(Map<String, dynamic> json) {
    return ShareableLinkData(
      referralCode: json['referral_code']?.toString() ?? json['reffral_code']?.toString() ?? '',
      referralLink: json['referral_link']?.toString() ?? '',
      shareMessage: json['share_message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'referral_code': referralCode,
    'referral_link': referralLink,
    'share_message': shareMessage,
  };
}

// -------------------------------------------------------------
// 5. Send Referral Link Result (API 6)
// -------------------------------------------------------------
class SendReferralResult {
  final String email;
  final String referralCode;
  final String referralLink;

  SendReferralResult({
    required this.email,
    required this.referralCode,
    required this.referralLink,
  });

  factory SendReferralResult.fromJson(Map<String, dynamic> json) {
    return SendReferralResult(
      email: json['email']?.toString() ?? '',
      referralCode: json['referral_code']?.toString() ?? '',
      referralLink: json['referral_link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'referral_code': referralCode,
    'referral_link': referralLink,
  };
}
