int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  if (value is List && value.isNotEmpty) return _asInt(value.first);
  return null;
}

List<String>? _parseTags(dynamic tags) {
  if (tags == null) return null;
  if (tags is List) {
    return tags.map((e) => e.toString()).toList();
  }
  if (tags is String && tags.isNotEmpty) {
    return tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return null;
}

class BlogResponse {
  final bool? success;
  final BlogData? data;

  BlogResponse({this.success, this.data});

  factory BlogResponse.fromJson(Map<String, dynamic> json) => BlogResponse(
        success: json['success'] == true || json['success'] == 1,
        data: json['data'] != null && json['data'] is Map<String, dynamic>
            ? BlogData.fromJson(json['data'])
            : null,
      );
}

class BlogData {
  final int? currentPage;
  final List<Blog>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  BlogData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory BlogData.fromJson(Map<String, dynamic> json) => BlogData(
        currentPage: _asInt(json['current_page']),
        data: json['data'] != null && json['data'] is List
            ? (json['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((x) => Blog.fromJson(x))
                .toList()
            : null,
        firstPageUrl: json['first_page_url']?.toString(),
        from: _asInt(json['from']),
        lastPage: _asInt(json['last_page']),
        lastPageUrl: json['last_page_url']?.toString(),
        nextPageUrl: json['next_page_url']?.toString(),
        path: json['path']?.toString(),
        perPage: _asInt(json['per_page']),
        prevPageUrl: json['prev_page_url']?.toString(),
        to: _asInt(json['to']),
        total: _asInt(json['total']),
      );
}

class Blog {
  final int? id;
  final int? userId;
  final String? title;
  final String? description;
  final List<String>? tags;
  final String? mediaPath;
  final String? mediaType;
  final String? blogType;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final int? likesCount;
  final bool? isLiked;
  final BlogUser? user;
  final List<String>? mediaPaths; // 🆕 Added for multiple media carousels
  final BlogCategory? category; // 🆕 Added for category
  final List<BlogComment>? comments; // 🆕 Added for comments

  Blog({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.tags,
    this.mediaPath,
    this.mediaType,
    this.blogType,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.likesCount,
    this.isLiked,
    this.user,
    this.mediaPaths, // 🆕 Added
    this.category,
    this.comments, // 🆕 Added
  });

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
        id: _asInt(json['id']),
        userId: _asInt(json['user_id']),
        title: json['title']?.toString(),
        description: json['description']?.toString(),
        tags: _parseTags(json['tags']),
        mediaPath: json['media_path'] is List
            ? (json['media_path'] as List).isNotEmpty
                ? (json['media_path'] as List).first.toString()
                : null
            : json['media_path']?.toString(),
        mediaPaths: json['media_path'] is List
            ? (json['media_path'] as List).map((e) => e.toString()).toList()
            : (json['media_path'] != null ? [json['media_path'].toString()] : null), // 🆕 Added
        mediaType: json['media_type']?.toString(),
        blogType: json['blog_type']?.toString() ?? json['blogs_type']?.toString(),
        isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        likesCount: _asInt(json['likes_count']),
        isLiked: json['is_liked'] == 1 || json['is_liked'] == true || json['is_liked'] == '1',
        user: json['user'] != null && json['user'] is Map<String, dynamic>
            ? BlogUser.fromJson(json['user'])
            : null,
        category: json['category'] != null && json['category'] is Map<String, dynamic>
            ? BlogCategory.fromJson(json['category'])
            : null,
        comments: json['comments'] != null && json['comments'] is List
            ? List<BlogComment>.from((json['comments'] as List)
                .whereType<Map<String, dynamic>>()
                .map((x) => BlogComment.fromJson(x)))
            : null,
      );

  Blog copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    List<String>? tags,
    String? mediaPath,
    String? mediaType,
    String? blogType,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    int? likesCount,
    bool? isLiked,
    BlogUser? user,
    List<String>? mediaPaths, // 🆕 Added
    List<BlogComment>? comments, // 🆕 Added
  }) =>
      Blog(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        mediaPath: mediaPath ?? this.mediaPath,
        mediaType: mediaType ?? this.mediaType,
        blogType: blogType ?? this.blogType,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        likesCount: likesCount ?? this.likesCount,
        isLiked: isLiked ?? this.isLiked,
        user: user ?? this.user,
        mediaPaths: mediaPaths ?? this.mediaPaths, // 🆕 Added
        category: category ?? this.category,
        comments: comments ?? this.comments, // 🆕 Added
      );
}

class BlogComment {
  final int? id;
  final int? blogId;
  final int? userId;
  final int? parentId;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;
  final BlogUser? user;
  final List<BlogComment>? replies;

  BlogComment({
    this.id,
    this.blogId,
    this.userId,
    this.parentId,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.replies,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) => BlogComment(
        id: _asInt(json['id']),
        blogId: _asInt(json['blog_id']),
        userId: _asInt(json['user_id']),
        parentId: _asInt(json['parent_id']),
        comment: json['comment']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        user: json['user'] != null && json['user'] is Map<String, dynamic>
            ? BlogUser.fromJson(json['user'])
            : null,
        replies: json['replies'] != null && json['replies'] is List
            ? List<BlogComment>.from((json['replies'] as List)
                .whereType<Map<String, dynamic>>()
                .map((x) => BlogComment.fromJson(x)))
            : null,
      );
}

class BlogCategory {
  final int? id;
  final String? name;
  final String? description;
  final bool? isActive;

  BlogCategory({this.id, this.name, this.description, this.isActive});

  factory BlogCategory.fromJson(Map<String, dynamic> json) => BlogCategory(
        id: _asInt(json['id']),
        name: json['name']?.toString(),
        description: json['description']?.toString(),
        isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
      );
}

class BlogCategoryResponse {
  final bool? success;
  final List<BlogCategory>? data;

  BlogCategoryResponse({this.success, this.data});

  factory BlogCategoryResponse.fromJson(Map<String, dynamic> json) => BlogCategoryResponse(
        success: json['success'] == true || json['success'] == 1,
        data: json['data'] != null && json['data'] is List
            ? List<BlogCategory>.from((json['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((x) => BlogCategory.fromJson(x)))
            : null,
      );
}

class BlogUser {
  final int? id;
  final String? googleId;
  final String? name;
  final String? email;
  final String? photo;
  final String? phone;
  final int? age;
  final String? occupation;
  final String? address;
  final String? nearbyLocation;
  final String? pincode;
  final String? state;
  final String? city;
  final String? district;
  final String? userType;
  final String? status;

  BlogUser({
    this.id,
    this.googleId,
    this.name,
    this.email,
    this.photo,
    this.phone,
    this.age,
    this.occupation,
    this.address,
    this.nearbyLocation,
    this.pincode,
    this.state,
    this.city,
    this.district,
    this.userType,
    this.status,
  });

  factory BlogUser.fromJson(Map<String, dynamic> json) => BlogUser(
        id: _asInt(json['id']),
        googleId: json['google_id']?.toString(),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        photo: json['photo']?.toString(),
        phone: json['phone']?.toString(),
        age: _asInt(json['age']),
        occupation: json['occupation']?.toString(),
        address: json['address']?.toString(),
        nearbyLocation: json['nearby_location']?.toString(),
        pincode: json['pincode']?.toString(),
        state: json['state']?.toString(),
        city: json['city']?.toString(),
        district: json['district']?.toString(),
        userType: json['user_type']?.toString(),
        status: json['status']?.toString(),
      );
}
class BlogDetailResponse {
  final bool? success;
  final BlogDetailData? data;

  BlogDetailResponse({this.success, this.data});

  factory BlogDetailResponse.fromJson(Map<String, dynamic> json) => BlogDetailResponse(
        success: json['success'],
        data: json['data'] != null ? BlogDetailData.fromJson(json['data']) : null,
      );
}

class BlogDetailData {
  final Blog? blog;
  final List<Blog>? related;

  BlogDetailData({this.blog, this.related});

  factory BlogDetailData.fromJson(Map<String, dynamic> json) => BlogDetailData(
        blog: json['blog'] != null ? Blog.fromJson(json['blog']) : null,
        related: json['related'] != null
            ? List<Blog>.from(json['related'].map((x) => Blog.fromJson(x)))
            : null,
      );
}
