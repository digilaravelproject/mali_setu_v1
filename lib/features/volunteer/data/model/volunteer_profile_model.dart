class VolunteerProfileResponse {
  bool? success;
  VolunteerProfileData? data;
  String? message;

  VolunteerProfileResponse({this.success, this.data, this.message});

  factory VolunteerProfileResponse.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileResponse(
      success: json['success'],
      data: json['data'] != null ? VolunteerProfileData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class VolunteerProfileData {
  int? id;
  int? userId;
  String? skills;
  String? experience;
  String? availability;
  String? location;
  String? bio;
  List<String>? interests;
  String? status;
  String? createdAt;
  String? updatedAt;

  VolunteerProfileData({
    this.id,
    this.userId,
    this.skills,
    this.experience,
    this.availability,
    this.location,
    this.bio,
    this.interests,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory VolunteerProfileData.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileData(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      skills: json['skills'],
      experience: json['experience'],
      availability: json['availability'],
      location: json['location'],
      bio: json['bio'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : [],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['skills'] = skills;
    data['experience'] = experience;
    data['availability'] = availability;
    data['location'] = location;
    data['bio'] = bio;
    data['interests'] = interests;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
