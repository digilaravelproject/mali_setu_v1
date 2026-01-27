class InitAppModel {
  final Settings settings;
  final List<IntroScreenModel> introScreens;
  final List<Interest> interests;
  final List<Interest> relationshipGoals;
  final ProfileBasics profileBasics;
  final StaticOptions staticOptions;

  InitAppModel({
    required this.settings,
    required this.introScreens,
    required this.interests,
    required this.relationshipGoals,
    required this.profileBasics,
    required this.staticOptions,
  });

  factory InitAppModel.fromMap(Map<String, dynamic> json) => InitAppModel(
    settings: json["settings"] != null
        ? Settings.fromMap(json["settings"])
        : Settings.empty(),

    introScreens: json["intro_screens"] != null
        ? List<IntroScreenModel>.from(
            json["intro_screens"].map((x) => IntroScreenModel.fromMap(x)),
          )
        : [],

    interests: json["interests"] != null
        ? List<Interest>.from(json["interests"].map((x) => Interest.fromMap(x)))
        : [],

    relationshipGoals: json["relationship_goals"] != null
        ? List<Interest>.from(
            json["relationship_goals"].map((x) => Interest.fromMap(x)),
          )
        : [],

    profileBasics: json["profile_basics"] != null
        ? ProfileBasics.fromMap(json["profile_basics"])
        : ProfileBasics.empty(),

    staticOptions: json["static_options"] != null
        ? StaticOptions.fromMap(json["static_options"])
        : StaticOptions.empty(),
  );
}

class Interest {
  final int id;
  final String name;
  final String icon;
  final String category;
  final String description;

  Interest({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
  });

  factory Interest.fromMap(Map<String, dynamic> json) => Interest(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    icon: json["icon"] ?? "",
    category: json["category"] ?? "",
    description: json["description"] ?? "",
  );

  String get goals => "$name $icon";
}

class IntroScreenModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final int order;

  IntroScreenModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.order,
  });

  factory IntroScreenModel.fromMap(Map<String, dynamic> json) =>
      IntroScreenModel(
        id: json["id"] ?? 0,
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        image: json["image"] ?? "",
        order: json["order"] ?? 0,
      );
}

class ProfileBasics {
  final CommunicationStyle zodiac;
  final CommunicationStyle education;
  final CommunicationStyle familyPlan;
  final CommunicationStyle communicationStyle;
  final CommunicationStyle loveStyle;
  final CommunicationStyle pets;
  final CommunicationStyle drinking;
  final CommunicationStyle smoking;
  final CommunicationStyle workout;
  final CommunicationStyle dietaryPreference;
  final CommunicationStyle sleepHabit;

  ProfileBasics({
    required this.zodiac,
    required this.education,
    required this.familyPlan,
    required this.communicationStyle,
    required this.loveStyle,
    required this.pets,
    required this.drinking,
    required this.smoking,
    required this.workout,
    required this.dietaryPreference,
    required this.sleepHabit,
  });

  factory ProfileBasics.fromMap(Map<String, dynamic> json) => ProfileBasics(
    zodiac: json["zodiac"] != null
        ? CommunicationStyle.fromMap(json["zodiac"])
        : CommunicationStyle.empty(),
    education: json["education"] != null
        ? CommunicationStyle.fromMap(json["education"])
        : CommunicationStyle.empty(),
    familyPlan: json["family_plan"] != null
        ? CommunicationStyle.fromMap(json["family_plan"])
        : CommunicationStyle.empty(),
    communicationStyle: json["communication_style"] != null
        ? CommunicationStyle.fromMap(json["communication_style"])
        : CommunicationStyle.empty(),
    loveStyle: json["love_style"] != null
        ? CommunicationStyle.fromMap(json["love_style"])
        : CommunicationStyle.empty(),
    pets: json["pets"] != null
        ? CommunicationStyle.fromMap(json["pets"])
        : CommunicationStyle.empty(),
    drinking: json["drinking"] != null
        ? CommunicationStyle.fromMap(json["drinking"])
        : CommunicationStyle.empty(),
    smoking: json["smoking"] != null
        ? CommunicationStyle.fromMap(json["smoking"])
        : CommunicationStyle.empty(),
    workout: json["workout"] != null
        ? CommunicationStyle.fromMap(json["workout"])
        : CommunicationStyle.empty(),
    dietaryPreference: json["dietary_preference"] != null
        ? CommunicationStyle.fromMap(json["dietary_preference"])
        : CommunicationStyle.empty(),
    sleepHabit: json["sleep_habit"] != null
        ? CommunicationStyle.fromMap(json["sleep_habit"])
        : CommunicationStyle.empty(),
  );

  factory ProfileBasics.empty() => ProfileBasics(
    zodiac: CommunicationStyle.empty(),
    education: CommunicationStyle.empty(),
    familyPlan: CommunicationStyle.empty(),
    communicationStyle: CommunicationStyle.empty(),
    loveStyle: CommunicationStyle.empty(),
    pets: CommunicationStyle.empty(),
    drinking: CommunicationStyle.empty(),
    smoking: CommunicationStyle.empty(),
    workout: CommunicationStyle.empty(),
    dietaryPreference: CommunicationStyle.empty(),
    sleepHabit: CommunicationStyle.empty(),
  );
}

class CommunicationStyle {
  final String label;
  final List<Interest> options;

  CommunicationStyle({required this.label, required this.options});

  factory CommunicationStyle.fromMap(Map<String, dynamic> json) =>
      CommunicationStyle(
        label: json["label"] ?? "",
        options: json["options"] != null
            ? List<Interest>.from(
                json["options"].map((x) => Interest.fromMap(x)),
              )
            : [],
      );

  factory CommunicationStyle.empty() =>
      CommunicationStyle(label: "", options: []);
}

class Settings {
  final String appName;
  final String appTagline;
  final String appDescription;
  final String contactEmail;
  final String contactPhone;
  final int maxPhotosPerUser;
  final int minAge;
  final int maxAge;
  final bool enableCommunities;
  final bool enableEvents;
  final bool enablePhotoVerification;
  final bool enableIncomeVerification;
  final String currency;
  final String currencySymbol;

  Settings({
    required this.appName,
    required this.appTagline,
    required this.appDescription,
    required this.contactEmail,
    required this.contactPhone,
    required this.maxPhotosPerUser,
    required this.minAge,
    required this.maxAge,
    required this.enableCommunities,
    required this.enableEvents,
    required this.enablePhotoVerification,
    required this.enableIncomeVerification,
    required this.currency,
    required this.currencySymbol,
  });

  factory Settings.fromMap(Map<String, dynamic> json) => Settings(
    appName: json["app_name"] ?? "",
    appTagline: json["app_tagline"] ?? "",
    appDescription: json["app_description"] ?? "",
    contactEmail: json["contact_email"] ?? "",
    contactPhone: json["contact_phone"] ?? "",
    maxPhotosPerUser: json["max_photos_per_user"] ?? 0,
    minAge: json["min_age"] ?? 0,
    maxAge: json["max_age"] ?? 0,
    enableCommunities: json["enable_communities"] ?? false,
    enableEvents: json["enable_events"] ?? false,
    enablePhotoVerification: json["enable_photo_verification"] ?? false,
    enableIncomeVerification: json["enable_income_verification"] ?? false,
    currency: json["currency"] ?? "",
    currencySymbol: json["currency_symbol"] ?? "",
  );

  factory Settings.empty() => Settings(
    appName: "",
    appTagline: "",
    appDescription: "",
    contactEmail: "",
    contactPhone: "",
    maxPhotosPerUser: 0,
    minAge: 0,
    maxAge: 0,
    enableCommunities: false,
    enableEvents: false,
    enablePhotoVerification: false,
    enableIncomeVerification: false,
    currency: "",
    currencySymbol: "",
  );
}

class StaticOptions {
  final List<BodyType> genders;
  final List<BodyType> sexualOrientations;
  final List<BodyType> interestedIn;
  final List<BodyType> relationshipStatuses;
  final List<BodyType> bodyTypes;
  final List<BodyType> heightUnits;

  StaticOptions({
    required this.genders,
    required this.sexualOrientations,
    required this.interestedIn,
    required this.relationshipStatuses,
    required this.bodyTypes,
    required this.heightUnits,
  });

  factory StaticOptions.fromMap(Map<String, dynamic> json) => StaticOptions(
    genders: _parseList(json["genders"]),
    sexualOrientations: _parseList(json["sexual_orientations"]),
    interestedIn: _parseList(json["interested_in"]),
    relationshipStatuses: _parseList(json["relationship_statuses"]),
    bodyTypes: _parseList(json["body_types"]),
    heightUnits: _parseList(json["height_units"]),
  );

  static List<BodyType> _parseList(dynamic list) {
    if (list == null) return [];
    return List<BodyType>.from(list.map((x) => BodyType.fromMap(x)));
  }

  factory StaticOptions.empty() => StaticOptions(
    genders: [],
    sexualOrientations: [],
    interestedIn: [],
    relationshipStatuses: [],
    bodyTypes: [],
    heightUnits: [],
  );
}

class BodyType {
  final int id;
  final String value;
  final String label;
  final String icon;

  BodyType({
    required this.id,
    required this.value,
    required this.label,
    required this.icon,
  });

  factory BodyType.fromMap(Map<String, dynamic> json) => BodyType(
    id: json["id"] ?? 0,
    value: json["value"] ?? "",
    label: json["label"] ?? "",
    icon: json["icon"] ?? "",
  );

  String get gender => "$icon $label";
}
