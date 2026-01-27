class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String profession;
  final String location;
  final String religion;
  final String caste;
  final String education;
  final String bio;
  final List<String> images;
  final String height;
  final String? annualIncome;
  final List<String> interests;
  final bool isPremium;
  final bool isVerified;
  final String? partnerExpectations;
  final String? familyDetails;
  final String? contactInfo;

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.profession,
    required this.location,
    required this.religion,
    required this.caste,
    required this.education,
    required this.bio,
    required this.images,
    required this.height,
    this.annualIncome,
    required this.interests,
    this.isPremium = false,
    this.isVerified = false,
    this.partnerExpectations,
    this.familyDetails,
    this.contactInfo,
  });

  // Factory method to create from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      profession: json['profession'] ?? '',
      location: json['location'] ?? '',
      religion: json['religion'] ?? '',
      caste: json['caste'] ?? '',
      education: json['education'] ?? '',
      bio: json['bio'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      height: json['height'] ?? '',
      annualIncome: json['annualIncome'],
      interests: List<String>.from(json['interests'] ?? []),
      isPremium: json['isPremium'] ?? false,
      isVerified: json['isVerified'] ?? false,
      partnerExpectations: json['partnerExpectations'],
      familyDetails: json['familyDetails'],
      contactInfo: json['contactInfo'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'profession': profession,
      'location': location,
      'religion': religion,
      'caste': caste,
      'education': education,
      'bio': bio,
      'images': images,
      'height': height,
      'annualIncome': annualIncome,
      'interests': interests,
      'isPremium': isPremium,
      'isVerified': isVerified,
      'partnerExpectations': partnerExpectations,
      'familyDetails': familyDetails,
      'contactInfo': contactInfo,
    };
  }
}




