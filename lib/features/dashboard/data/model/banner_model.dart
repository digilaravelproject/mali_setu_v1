class BannerResponse {
  final List<BannerData> data;
  final Links? links;
  final Meta? meta;

  BannerResponse({
    required this.data,
    this.links,
    this.meta,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      data: (json['data'] as List).map((i) => BannerData.fromJson(i)).toList(),
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
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
