class EducationResponse {
  final bool success;
  final List<Education> data;

  EducationResponse({
    required this.success,
    required this.data,
  });

  factory EducationResponse.fromJson(Map<String, dynamic> json) {
    return EducationResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Education.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Education {
  final int? id;
  final int? userId;
  final String? highestQualification;
  final String? college;
  final String? university;
  final String? specialization;
  final int? passingYear;
  final String? percentage;
  final String? description;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  Education({
    this.id,
    this.userId,
    this.highestQualification,
    this.college,
    this.university,
    this.specialization,
    this.passingYear,
    this.percentage,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      userId: json['user_id'],
      highestQualification: json['highest_qualification'],
      college: json['college'],
      university: json['university'],
      specialization: json['specialization'],
      passingYear: json['passing_year'],
      percentage: json['percentage'],
      description: json['description'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}