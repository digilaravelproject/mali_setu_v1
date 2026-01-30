class ResVolunteerModel {
  bool? success;
  VolunteerData? data;

  ResVolunteerModel({this.success, this.data});

  factory ResVolunteerModel.fromJson(Map<String, dynamic> json) => ResVolunteerModel(
    success: json['success'],
    data: json['data'] != null ? VolunteerData.fromJson(json['data']) : null,
  );
}

class ResSingleVolunteerModel {
  bool? success;
  Volunteer? data;

  ResSingleVolunteerModel({this.success, this.data});

  factory ResSingleVolunteerModel.fromJson(Map<String, dynamic> json) => ResSingleVolunteerModel(
    success: json['success'],
    data: json['data'] != null ? Volunteer.fromJson(json['data']) : null,
  );
}

class VolunteerData {
  int? currentPage;
  List<Volunteer>? volunteers;

  VolunteerData({this.currentPage, this.volunteers});

  factory VolunteerData.fromJson(Map<String, dynamic> json) => VolunteerData(
    currentPage: json['current_page'],
    volunteers: json['data'] != null
        ? List<Volunteer>.from(json['data'].map((x) => Volunteer.fromJson(x)))
        : [],
  );
}

class Volunteer {
  int? id;
  String? title;
  String? description;
  String? organization;
  String? location;
  int? volunteersNeeded;
  int? volunteersRegistered;
  String? status;
  String? contactPerson;
  String? contactEmail;
  String? contactPhone;
  String? startDate;
  String? endDate;
  String? requirements;
  String? timeCommitment;
  String? adminNotes;
  int? reviewedBy;
  String? reviewedAt;
  String? createdAt;
  String? updatedAt;

  Volunteer({
    this.id,
    this.title,
    this.description,
    this.organization,
    this.location,
    this.volunteersNeeded,
    this.volunteersRegistered,
    this.status,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.startDate,
    this.endDate,
    this.requirements,
    this.timeCommitment,
    this.adminNotes,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) => Volunteer(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    organization: json['organization'],
    location: json['location'],
    volunteersNeeded: json['volunteers_needed'],
    volunteersRegistered: json['volunteers_registered'],
    status: json['status'],
    contactPerson: json['contact_person'],
    contactEmail: json['contact_email'],
    contactPhone: json['contact_phone'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    requirements: json['requirements'],
    timeCommitment: json['time_commitment'],
    adminNotes: json['admin_notes'],
    reviewedBy: json['reviewed_by'],
    reviewedAt: json['reviewed_at'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}
