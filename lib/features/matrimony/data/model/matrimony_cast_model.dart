class CastResponse {
  bool? success;
  String? message;
  CastData? data;

  CastResponse({this.success, this.message, this.data});

  factory CastResponse.fromJson(Map<String, dynamic> json) {
    return CastResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? CastData.fromJson(json['data']) : null,
    );
  }
}

class CastData {
  List<Cast>? casts;
  int? count;

  CastData({this.casts, this.count});

  factory CastData.fromJson(Map<String, dynamic> json) {
    return CastData(
      casts: json['casts'] != null
          ? List<Cast>.from(json['casts'].map((x) => Cast.fromJson(x)))
          : null,
      count: json['count'],
    );
  }
}

class Cast {
  int? id;
  String? name;
  String? description;
  bool? isActive;

  Cast({this.id, this.name, this.description, this.isActive});

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }
}

class SubCastResponse {
  bool? success;
  String? message;
  SubCastData? data;

  SubCastResponse({this.success, this.message, this.data});

  factory SubCastResponse.fromJson(Map<String, dynamic> json) {
    return SubCastResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? SubCastData.fromJson(json['data']) : null,
    );
  }
}

class SubCastData {
  Cast? cast;
  List<SubCast>? subCasts;
  int? count;

  SubCastData({this.cast, this.subCasts, this.count});

  factory SubCastData.fromJson(Map<String, dynamic> json) {
    return SubCastData(
      cast: json['cast'] != null ? Cast.fromJson(json['cast']) : null,
      subCasts: json['sub_casts'] != null
          ? List<SubCast>.from(json['sub_casts'].map((x) => SubCast.fromJson(x)))
          : null,
      count: json['count'],
    );
  }
}

class SubCast {
  int? id;
  int? castId;
  String? name;
  String? description;
  bool? isActive;

  SubCast({this.id, this.castId, this.name, this.description, this.isActive});

  factory SubCast.fromJson(Map<String, dynamic> json) {
    return SubCast(
      id: json['id'],
      castId: json['cast_id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }
}
