import 'package:intl/intl.dart';
import '../../../../core/constent/api_constants.dart';
import 'res_all_business_model.dart';

class BusinessEnquiriesResponse {
  final bool success;
  final String? message;
  final BusinessEnquiriesData? data;

  BusinessEnquiriesResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BusinessEnquiriesResponse.fromJson(Map<String, dynamic> json) {
    return BusinessEnquiriesResponse(
      success: json['success'] == true ||
          json['success'] == 1 ||
          json['status'] == true ||
          json['status'] == 'success',
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? BusinessEnquiriesData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BusinessEnquiryDetailResponse {
  final bool success;
  final String? message;
  final BusinessEnquiryItem? enquiry;

  BusinessEnquiryDetailResponse({
    required this.success,
    this.message,
    this.enquiry,
  });

  factory BusinessEnquiryDetailResponse.fromJson(Map<String, dynamic> json) {
    BusinessEnquiryItem? item;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['enquiry'] != null && dataMap['enquiry'] is Map<String, dynamic>) {
        item = BusinessEnquiryItem.fromJson(dataMap['enquiry'] as Map<String, dynamic>);
      } else {
        item = BusinessEnquiryItem.fromJson(dataMap);
      }
    }
    return BusinessEnquiryDetailResponse(
      success: json['success'] == true ||
          json['success'] == 1 ||
          json['status'] == true ||
          json['status'] == 'success',
      message: json['message']?.toString(),
      enquiry: item,
    );
  }
}

class BusinessEnquiriesData {
  final Business? business;
  final List<BusinessEnquiryItem> enquiries;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? scope;

  BusinessEnquiriesData({
    this.business,
    required this.enquiries,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.scope,
  });

  factory BusinessEnquiriesData.fromJson(Map<String, dynamic> json) {
    Business? b;
    if (json['business'] != null && json['business'] is Map<String, dynamic>) {
      b = Business.fromJson(json['business'] as Map<String, dynamic>);
    }

    final enquiriesList = <BusinessEnquiryItem>[];
    int current = 1;
    int last = 1;
    int count = 0;

    final enquiriesObj = json['enquiries'];
    if (enquiriesObj is Map<String, dynamic>) {
      current = int.tryParse(enquiriesObj['current_page']?.toString() ?? '1') ?? 1;
      last = int.tryParse(enquiriesObj['last_page']?.toString() ?? '1') ?? 1;
      count = int.tryParse(enquiriesObj['total']?.toString() ?? '0') ?? 0;

      final dataList = enquiriesObj['data'];
      if (dataList is List) {
        for (final item in dataList) {
          if (item is Map<String, dynamic>) {
            enquiriesList.add(BusinessEnquiryItem.fromJson(item));
          }
        }
      }
    } else if (enquiriesObj is List) {
      for (final item in enquiriesObj) {
        if (item is Map<String, dynamic>) {
          enquiriesList.add(BusinessEnquiryItem.fromJson(item));
        }
      }
      count = enquiriesList.length;
    }

    return BusinessEnquiriesData(
      business: b,
      enquiries: enquiriesList,
      currentPage: current,
      lastPage: last,
      total: count,
      scope: json['scope']?.toString(),
    );
  }
}

class BusinessEnquiryItem {
  final int id;
  final int? userId;
  final int? businessId;
  final String? enquirableType;
  final int? enquirableId;
  final String? price;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final EnquiryUser? user;
  final EnquirableItem? enquirable;
  final Business? business;

  BusinessEnquiryItem({
    required this.id,
    this.userId,
    this.businessId,
    this.enquirableType,
    this.enquirableId,
    this.price,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.enquirable,
    this.business,
  });

  bool get isService => enquirableType?.toLowerCase().contains('service') == true;
  bool get isProduct => !isService;
  String get typeLabel => isService ? "Service" : "Product";

  String get formattedPrice {
    final p = price ?? enquirable?.displayPrice ?? '';
    if (p.isEmpty) return '';
    final numVal = num.tryParse(p.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (numVal != null) {
      return "₹${NumberFormat('#,##,###.##').format(numVal)}";
    }
    return "₹$p";
  }

  String get formattedDateTime {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }

  String get timeAgo {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 7) {
        return DateFormat('dd MMM yyyy').format(dt);
      } else if (diff.inDays > 0) {
        return "${diff.inDays}d ago";
      } else if (diff.inHours > 0) {
        return "${diff.inHours}h ago";
      } else if (diff.inMinutes > 0) {
        return "${diff.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (_) {
      return '';
    }
  }

  factory BusinessEnquiryItem.fromJson(Map<String, dynamic> json) {
    return BusinessEnquiryItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0'),
      businessId: int.tryParse(json['business_id']?.toString() ?? '0'),
      enquirableType: json['enquirable_type']?.toString(),
      enquirableId: int.tryParse(json['enquirable_id']?.toString() ?? '0'),
      price: json['price']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'new',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? EnquiryUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      enquirable: json['enquirable'] != null && json['enquirable'] is Map<String, dynamic>
          ? EnquirableItem.fromJson(json['enquirable'] as Map<String, dynamic>)
          : null,
      business: json['business'] != null && json['business'] is Map<String, dynamic>
          ? Business.fromJson(json['business'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EnquiryUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? photo;

  EnquiryUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.photo,
  });

  String get displayPhotoUrl {
    if (photo == null || photo!.isEmpty) return '';
    if (photo!.startsWith('http')) return photo!;
    return "${ApiConstants.imageBaseUrl}$photo";
  }

  String get initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  factory EnquiryUser.fromJson(Map<String, dynamic> json) {
    return EnquiryUser(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString() ?? 'Unknown User',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      photo: json['photo']?.toString(),
    );
  }
}

class EnquirableItem {
  final int? id;
  final int? businessId;
  final String? name;
  final String? description;
  final String? cost;
  final String? price;
  final String? imagePath;
  final List<String> imagePaths;
  final String? status;
  final List<EnquiryImage> images;

  EnquirableItem({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.cost,
    this.price,
    this.imagePath,
    this.imagePaths = const [],
    this.status,
    this.images = const [],
  });

  String get displayPrice => (cost != null && cost!.isNotEmpty) ? cost! : (price ?? '');

  String get displayImageUrl {
    if (images.isNotEmpty && images.first.url != null && images.first.url!.isNotEmpty) {
      return images.first.url!;
    }
    if (imagePaths.isNotEmpty) {
      final first = imagePaths.first;
      if (first.startsWith('http')) return first;
      return "${ApiConstants.imageBaseUrl}$first";
    }
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http')) return imagePath!;
      return "${ApiConstants.imageBaseUrl}$imagePath";
    }
    return '';
  }

  List<String> get allImageUrls {
    final list = <String>[];
    for (final img in images) {
      if (img.url != null && img.url!.isNotEmpty) {
        list.add(img.url!);
      }
    }
    if (list.isEmpty && imagePaths.isNotEmpty) {
      for (final p in imagePaths) {
        if (p.startsWith('http')) {
          list.add(p);
        } else {
          list.add("${ApiConstants.imageBaseUrl}$p");
        }
      }
    }
    if (list.isEmpty && imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http')) {
        list.add(imagePath!);
      } else {
        list.add("${ApiConstants.imageBaseUrl}$imagePath");
      }
    }
    return list;
  }

  factory EnquirableItem.fromJson(Map<String, dynamic> json) {
    final imgs = <EnquiryImage>[];
    if (json['images'] is List) {
      for (final item in json['images']) {
        if (item is Map<String, dynamic>) {
          imgs.add(EnquiryImage.fromJson(item));
        }
      }
    }

    final paths = <String>[];
    if (json['image_paths'] is List) {
      for (final item in json['image_paths']) {
        if (item != null && item.toString().isNotEmpty) {
          paths.add(item.toString());
        }
      }
    }

    return EnquirableItem(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      businessId: int.tryParse(json['business_id']?.toString() ?? '0'),
      name: json['name']?.toString() ?? 'Untitled Item',
      description: json['description']?.toString(),
      cost: json['cost']?.toString(),
      price: json['price']?.toString(),
      imagePath: json['image_path']?.toString(),
      imagePaths: paths,
      status: json['status']?.toString(),
      images: imgs,
    );
  }
}

class EnquiryImage {
  final String? path;
  final String? url;

  EnquiryImage({this.path, this.url});

  factory EnquiryImage.fromJson(Map<String, dynamic> json) {
    return EnquiryImage(
      path: json['path']?.toString(),
      url: json['url']?.toString(),
    );
  }
}
