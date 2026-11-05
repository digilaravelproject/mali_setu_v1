import 'package:intl/intl.dart';
import '../../../../core/constent/api_constants.dart';

class Webinar {
  final int id;
  final String title;
  final String description;
  final String category; // 'Business', 'Matrimony', 'Other'
  final DateTime dateTime;
  final String dateString; // e.g. "22 Oct 2026"
  final String timeString; // e.g. "04:00 PM - 05:00 PM"
  final String duration; // e.g. "60 Mins"
  final String bannerUrl;
  final String videoThumbnailUrl;
  final WebinarSpeaker speaker;
  int registeredCount;
  bool isRegistered;
  final bool isLive;
  final String status; // 'upcoming', 'live', 'completed'
  final String meetingLink;
  final String agoraChannel;
  final String accessType;
  final String fee;
  final bool requireRegistration;
  final List<String> keyPoints;
  final List<WebinarAgendaItem> agenda;

  Webinar({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.dateString,
    required this.timeString,
    this.duration = '60 Mins',
    required this.bannerUrl,
    required this.videoThumbnailUrl,
    required this.speaker,
    this.registeredCount = 0,
    this.isRegistered = false,
    this.isLive = false,
    this.status = 'upcoming',
    this.meetingLink = 'https://meet.google.com/malisetu-live',
    this.agoraChannel = '',
    this.accessType = 'free',
    this.fee = 'Free',
    this.requireRegistration = true,
    required this.keyPoints,
    required this.agenda,
  });

  bool get isPaid => accessType.toLowerCase() == 'paid' || (fee.isNotEmpty && fee.toLowerCase() != 'free' && fee != '0');
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isLiveSession => status.toLowerCase() == 'live' || isLive;
  bool get isUpcoming => status.toLowerCase() == 'upcoming' || (!isCompleted && !isLiveSession);
  bool get hasAccess => !requireRegistration || isRegistered;

  factory Webinar.fromApiJson(Map<String, dynamic> json) {
    final int id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final String title = json['title'] ?? 'Community Webinar';
    final String description = json['description'] ?? 'Learn and connect with community experts.';

    // Category normalization
    final String rawCategory = (json['category'] ?? 'other').toString().toLowerCase();
    String category = 'Other';
    if (rawCategory.contains('bus')) {
      category = 'Business';
    } else if (rawCategory.contains('matri')) {
      category = 'Matrimony';
    }

    // Date & Time parsing
    DateTime startDt = DateTime.now().add(const Duration(days: 2));
    if (json['starts_at'] != null) {
      final parsed = DateTime.tryParse(json['starts_at'].toString());
      if (parsed != null) {
        startDt = parsed.toLocal();
      }
    }

    DateTime endDt = startDt.add(Duration(minutes: (json['duration_minutes'] as int?) ?? 60));
    if (json['ends_at'] != null) {
      final parsed = DateTime.tryParse(json['ends_at'].toString());
      if (parsed != null) {
        endDt = parsed.toLocal();
      }
    }

    final String dateString = DateFormat('dd MMM yyyy').format(startDt);
    final String timeString = "${DateFormat('hh:mm a').format(startDt)} - ${DateFormat('hh:mm a').format(endDt)}";
    final String duration = "${json['duration_minutes'] ?? 60} Mins";

    // Speaker (only from API, no fake static data)
    String speakerName = (json['speaker_name'] ?? '').toString().trim();
    if (speakerName == 'null') {
      speakerName = '';
    }
    final speaker = WebinarSpeaker(
      name: speakerName,
      role: (json['speaker_role'] ?? '').toString(),
      photo: (json['speaker_photo'] ?? '').toString(),
      bio: (json['speaker_bio'] ?? '').toString(),
      organization: (json['speaker_organization'] ?? '').toString(),
    );

    // Banner URL
    String banner = '';
    if (json['banner_url'] != null && json['banner_url'].toString().isNotEmpty && json['banner_url'] != 'null') {
      banner = json['banner_url'].toString();
    } else if (json['banner_path'] != null && json['banner_path'].toString().isNotEmpty && json['banner_path'] != 'null') {
      banner = "${ApiConstants.imageBaseUrl}${json['banner_path']}";
    }

    // Video Thumbnail
    final String videoThumbnailUrl = banner;

    // Registrations count
    final int regCount = json['registrations_count'] is int
        ? json['registrations_count']
        : int.tryParse(json['registrations_count']?.toString() ?? '0') ?? 0;

    // Status: 'upcoming', 'live', 'completed'
    final String statusStr = (json['webinar_status'] ?? 'upcoming').toString().toLowerCase();
    final bool isLive = statusStr == 'live';

    // Agenda parsing (only from API, no mock fallback)
    List<WebinarAgendaItem> agendaList = [];
    if (json['agenda'] != null && json['agenda'].toString().isNotEmpty && json['agenda'] != 'null') {
      final lines = json['agenda'].toString().split('\n');
      for (var line in lines) {
        final t = line.trim();
        if (t.isNotEmpty) {
          agendaList.add(WebinarAgendaItem(
            time: "Session",
            title: t,
            description: "",
          ));
        }
      }
    }

    List<String> keyPointsList = [];
    if (json['key_points'] is List) {
      keyPointsList = (json['key_points'] as List).map((e) => e.toString()).toList();
    }

    final bool isReg = json['is_registered'] == true || json['is_registered'] == 1;
    final String accessType = (json['access_type'] ?? 'free').toString();
    final String fee = (json['fee'] ?? json['price'] ?? (accessType.toLowerCase() == 'paid' ? 'Paid' : 'Free')).toString();

    bool requireReg = true;
    if (json.containsKey('require_registration')) {
      final v = json['require_registration'];
      requireReg = v == true || v == 1 || v?.toString() == '1' || v?.toString().toLowerCase() == 'true';
    }

    return Webinar(
      id: id,
      title: title,
      description: description,
      category: category,
      dateTime: startDt,
      dateString: dateString,
      timeString: timeString,
      duration: duration,
      bannerUrl: banner,
      videoThumbnailUrl: videoThumbnailUrl,
      speaker: speaker,
      registeredCount: regCount,
      isRegistered: isReg,
      isLive: isLive,
      status: statusStr,
      meetingLink: (json['agora_link'] != null && json['agora_link'] != 'pending')
          ? json['agora_link'].toString()
          : '',
      agoraChannel: (json['agora_channel'] ?? '').toString(),
      accessType: accessType,
      fee: fee,
      requireRegistration: requireReg,
      keyPoints: keyPointsList,
      agenda: agendaList,
    );
  }

  Webinar copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    DateTime? dateTime,
    String? dateString,
    String? timeString,
    String? duration,
    String? bannerUrl,
    String? videoThumbnailUrl,
    WebinarSpeaker? speaker,
    int? registeredCount,
    bool? isRegistered,
    bool? isLive,
    String? status,
    String? meetingLink,
    String? agoraChannel,
    String? accessType,
    String? fee,
    bool? requireRegistration,
    List<String>? keyPoints,
    List<WebinarAgendaItem>? agenda,
  }) {
    return Webinar(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      dateString: dateString ?? this.dateString,
      timeString: timeString ?? this.timeString,
      duration: duration ?? this.duration,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      speaker: speaker ?? this.speaker,
      registeredCount: registeredCount ?? this.registeredCount,
      isRegistered: isRegistered ?? this.isRegistered,
      isLive: isLive ?? this.isLive,
      status: status ?? this.status,
      meetingLink: meetingLink ?? this.meetingLink,
      agoraChannel: agoraChannel ?? this.agoraChannel,
      accessType: accessType ?? this.accessType,
      fee: fee ?? this.fee,
      requireRegistration: requireRegistration ?? this.requireRegistration,
      keyPoints: keyPoints ?? this.keyPoints,
      agenda: agenda ?? this.agenda,
    );
  }
}

class WebinarSpeaker {
  final String name;
  final String role;
  final String photo;
  final String bio;
  final String organization;

  WebinarSpeaker({
    required this.name,
    required this.role,
    required this.photo,
    required this.bio,
    this.organization = 'Mali Setu Community',
  });
}

class WebinarAgendaItem {
  final String time;
  final String title;
  final String description;

  WebinarAgendaItem({
    required this.time,
    required this.title,
    required this.description,
  });
}

class WebinarChatMessage {
  final String id;
  final String userName;
  final String userAvatar;
  final String time;
  final String message;
  final bool isHost;
  final bool isQuestion;

  WebinarChatMessage({
    required this.id,
    required this.userName,
    this.userAvatar = '',
    required this.time,
    required this.message,
    this.isHost = false,
    this.isQuestion = false,
  });

  factory WebinarChatMessage.fromApiJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null;
    final userName = user?['name']?.toString() ?? 'Community Member';

    String avatar = '';
    final photo = user?['photo']?.toString() ?? '';
    if (photo.startsWith('http')) {
      avatar = photo;
    } else if (photo.contains('/') && !photo.contains(' ')) {
      avatar = "${ApiConstants.imageBaseUrl}$photo";
    }

    String formattedTime = "Just now";
    if (json['created_at'] != null) {
      final parsed = DateTime.tryParse(json['created_at'].toString());
      if (parsed != null) {
        formattedTime = DateFormat('hh:mm a').format(parsed.toLocal());
      }
    }

    final String text = json['comment']?.toString() ?? '';
    final bool isQ = text.contains('?');

    return WebinarChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName,
      userAvatar: avatar,
      time: formattedTime,
      message: text,
      isQuestion: isQ,
    );
  }
}

class WebinarCommentsResponse {
  final bool success;
  final int currentPage;
  final int lastPage;
  final int total;
  final List<WebinarChatMessage> data;

  WebinarCommentsResponse({
    required this.success,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.data,
  });

  factory WebinarCommentsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataObj = json['data'];
    List rawList = [];
    int curPage = 1;
    int lstPage = 1;
    int tot = 0;

    if (dataObj is Map<String, dynamic>) {
      if (dataObj['data'] is List) {
        rawList = dataObj['data'] as List;
      }
      curPage = dataObj['current_page'] is int
          ? dataObj['current_page']
          : int.tryParse(dataObj['current_page']?.toString() ?? '1') ?? 1;
      lstPage = dataObj['last_page'] is int
          ? dataObj['last_page']
          : int.tryParse(dataObj['last_page']?.toString() ?? '1') ?? 1;
      tot = dataObj['total'] is int
          ? dataObj['total']
          : int.tryParse(dataObj['total']?.toString() ?? '0') ?? 0;
    } else if (dataObj is List) {
      rawList = dataObj;
      tot = rawList.length;
    }

    final list = rawList
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return WebinarChatMessage.fromApiJson(item);
            }
            return null;
          } catch (e) {
            return null;
          }
        })
        .whereType<WebinarChatMessage>()
        .toList();

    return WebinarCommentsResponse(
      success: json['success'] == true || json['success'] == 1,
      currentPage: curPage,
      lastPage: lstPage,
      total: tot,
      data: list,
    );
  }
}

class WebinarListResponse {
  final bool success;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<Webinar> data;

  WebinarListResponse({
    required this.success,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory WebinarListResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataObj = json['data'];
    List rawList = [];
    int curPage = 1;
    int lstPage = 1;
    int perPg = 12;
    int tot = 0;

    if (dataObj is Map<String, dynamic>) {
      if (dataObj['data'] is List) {
        rawList = dataObj['data'] as List;
      }
      curPage = dataObj['current_page'] is int
          ? dataObj['current_page']
          : int.tryParse(dataObj['current_page']?.toString() ?? '1') ?? 1;
      lstPage = dataObj['last_page'] is int
          ? dataObj['last_page']
          : int.tryParse(dataObj['last_page']?.toString() ?? '1') ?? 1;
      perPg = dataObj['per_page'] is int
          ? dataObj['per_page']
          : int.tryParse(dataObj['per_page']?.toString() ?? '12') ?? 12;
      tot = dataObj['total'] is int
          ? dataObj['total']
          : int.tryParse(dataObj['total']?.toString() ?? '0') ?? 0;
    } else if (dataObj is List) {
      rawList = dataObj;
      tot = rawList.length;
    }

    final list = rawList
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

    return WebinarListResponse(
      success: json['success'] == true || json['success'] == 1,
      currentPage: curPage,
      lastPage: lstPage,
      perPage: perPg,
      total: tot,
      data: list,
    );
  }
}
