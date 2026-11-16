import '../../../webinars/data/models/webinar_model.dart';

class BannerResponse {
  final List<BannerData> data;
  final List<LeaderboardItem> leaderboard;
  final List<Webinar> upcomingWebinars;
  final Links? links;
  final Meta? meta;

  BannerResponse({
    required this.data,
    this.leaderboard = const [],
    this.upcomingWebinars = const [],
    this.links,
    this.meta,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    List<Webinar> webinars = [];
    if (json['upcoming_webinars'] != null && json['upcoming_webinars'] is List) {
      webinars = (json['upcoming_webinars'] as List)
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Webinar.fromApiJson(item);
              }
              return null;
            } catch (e) {
              return null;
            }
          })
          .whereType<Webinar>()
          .toList();
    }

    List<LeaderboardItem> leaderboardList = [];
    if (json['leaderboard'] != null && json['leaderboard'] is List) {
      leaderboardList = (json['leaderboard'] as List)
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return LeaderboardItem.fromJson(item);
              }
              return null;
            } catch (e) {
              return null;
            }
          })
          .whereType<LeaderboardItem>()
          .toList();
    }

    return BannerResponse(
      data: json['data'] != null ? (json['data'] as List).map((i) => BannerData.fromJson(i)).toList() : [],
      leaderboard: leaderboardList,
      upcomingWebinars: webinars,
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class LeaderboardItem {
  final int rank;
  final int id;
  final String name;
  final String referralCode;
  final String? photoUrl;
  final int totalReferrals;
  final int totalEarnedPoints;

  LeaderboardItem({
    required this.rank,
    required this.id,
    required this.name,
    required this.referralCode,
    this.photoUrl,
    required this.totalReferrals,
    required this.totalEarnedPoints,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      referralCode: json['referral_code']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
      totalReferrals: json['total_referrals'] is int
          ? json['total_referrals']
          : int.tryParse(json['total_referrals']?.toString() ?? '0') ?? 0,
      totalEarnedPoints: json['total_earned_points'] is int
          ? json['total_earned_points']
          : int.tryParse(json['total_earned_points']?.toString() ?? '0') ?? 0,
    );
  }
}

class BannerData {
  final int id;
  final String title;
  final String url; // URL to navigate (e.g., "/api/business/41")
  final String imageUrl;
  final String createdAt;
  final String updatedAt;

  BannerData({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['id'],
      title: json['title'],
      url: json['url'] ?? '',
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  
  /// Extract business ID from URL like "/api/business/41"
  int? get businessId {
    try {
      final parts = url.split('/');
      if (parts.length >= 3 && parts[parts.length - 2] == 'business') {
        return int.tryParse(parts.last);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class Meta {
  final dynamic currentPage;
  final int? from;
  final dynamic lastPage;
  final List<MetaLink>? links;
  final String? path;
  final dynamic perPage;
  final int? to;
  final dynamic total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: json['links'] != null
          ? (json['links'] as List).map((i) => MetaLink.fromJson(i)).toList()
          : null,
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class MetaLink {
  final String? url;
  final String? label;
  final dynamic page;
  final bool active;

  MetaLink({this.url, this.label, this.page, required this.active});

  factory MetaLink.fromJson(Map<String, dynamic> json) {
    return MetaLink(
      url: json['url'],
      label: json['label'],
      page: json['page'],
      active: json['active'] ?? false,
    );
  }
}
