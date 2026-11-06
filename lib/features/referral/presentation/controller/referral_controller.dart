import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../core/styles/app_colors.dart';
import '../../data/data_source/referral_data_source.dart';
import '../../data/models/referral_model.dart';
import '../../data/repository/referral_repository_impl.dart';
import '../../domain/repository/referral_repository.dart';
import '../../../Auth/service/auth_service.dart';

class ReferralController extends GetxController {
  final ReferralRepository repository;

  ReferralController({
    ReferralRepository? repository,
    ReferralDataSource? dataSource,
  }) : repository = repository ??
            (dataSource != null
                ? ReferralRepositoryImpl(dataSource: dataSource)
                : (Get.isRegistered<ReferralRepository>()
                    ? Get.find<ReferralRepository>()
                    : ReferralRepositoryImpl(
                        dataSource: Get.find<ReferralDataSource>())));

  // State observables
  final Rxn<VolunteerEarningsData> earnings = Rxn<VolunteerEarningsData>();
  final RxList<ReferredUserItem> referredUsers = <ReferredUserItem>[].obs;
  final RxList<ReferredUserItem> history = <ReferredUserItem>[].obs;
  final Rxn<ReferralNetworkNode> networkTree = Rxn<ReferralNetworkNode>();
  final Rxn<ShareableLinkData> shareableLink = Rxn<ShareableLinkData>();

  final RxBool isLoading = false.obs;
  final RxBool isSharing = false.obs;
  final RxBool isSendingEmail = false.obs;
  final RxBool isTreeView = false.obs;
  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxString selectedHistoryFilter = 'all'.obs;
  final RxString selectedHistoryUserType = 'all'.obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  @override
  void onClose() {
    emailController.dispose();
    recipientNameController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      final initialCode = getReferralCode();

      // 1. First fetch volunteer earnings (GET /api/referrals/{code}/earnings)
      try {
        final earningsData = await repository.getVolunteerEarnings(referralCode: initialCode);
        earnings.value = earningsData;

        final backendCode = earningsData.volunteer?.referralCode;
        if (backendCode != null && backendCode.trim().isNotEmpty) {
          await SharedPrefs.setString(AppConstants.referralCodePref, backendCode.trim());
          if (Get.isRegistered<AuthService>()) {
            Get.find<AuthService>().currentUser.value?.reffralCode = backendCode.trim();
          }
          debugPrint("DEBUG_REFERRAL: Authorized referral code from backend: $backendCode");
        }
      } catch (e) {
        debugPrint("Error loading volunteer earnings: $e");
      }

      // 2. Verified authorized referral code of current authenticated user
      final ownCode = getReferralCode();

      // 3. Call remaining APIs using the user's OWN authorized referral code
      final results = await Future.wait([
        repository.getReferredUsers(referralCode: ownCode),
        repository.getReferralHistory(referralCode: ownCode),
        repository.getReferralNetwork(referralCode: ownCode, depth: 3),
        repository.getShareableLink(referralCode: ownCode),
      ]);

      final usersFromApi = results[0] as List<ReferredUserItem>;
      final historyFromApi = results[1] as List<ReferredUserItem>;
      final treeData = results[2] as ReferralNetworkNode;

      // If referredUsers from direct API is empty, extract all children from network tree
      if (usersFromApi.isEmpty && treeData.children.isNotEmpty) {
        final List<ReferredUserItem> treeUsers = [];
        void extract(List<ReferralNetworkNode> children) {
          for (final c in children) {
            treeUsers.add(
              ReferredUserItem(
                id: c.userId,
                referralCodeUsed: c.referralCode,
                commissionPoints: c.commissionPoints,
                status: 'active',
                user: ReferralUserInfo(
                  id: c.userId,
                  name: c.name,
                  userType: c.userType ?? 'matrimony',
                  status: 'active',
                  location: c.location,
                ),
              ),
            );
            if (c.children.isNotEmpty) extract(c.children);
          }
        }
        extract(treeData.children);
        referredUsers.assignAll(treeUsers);
      } else {
        referredUsers.assignAll(usersFromApi);
      }

      history.assignAll(historyFromApi);
      networkTree.value = treeData;
      shareableLink.value = results[3] as ShareableLinkData;
    } catch (e) {
      debugPrint("Error loading referral data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEarnings({String? referralCode}) async {
    try {
      final code = (referralCode != null && referralCode.isNotEmpty) ? referralCode : getReferralCode();
      final data = await repository.getVolunteerEarnings(referralCode: code);
      earnings.value = data;
    } catch (e) {
      debugPrint("Error fetching earnings: $e");
    }
  }

  Future<void> fetchNetwork({
    int depth = 3,
    String? district,
    String? taluka,
    String? cityVillage,
  }) async {
    try {
      final code = getReferralCode();
      final node = await repository.getReferralNetwork(
        referralCode: code,
        depth: depth,
        district: district,
        taluka: taluka,
        cityVillage: cityVillage,
      );
      networkTree.value = node;
    } catch (e) {
      debugPrint("Error loading referral network: $e");
    }
  }

  Future<void> fetchHistory({String? userType, String? status}) async {
    try {
      isLoadingHistory.value = true;
      final code = getReferralCode();
      final items = await repository.getReferralHistory(
        referralCode: code,
        userType: (userType != null && userType != 'all') ? userType : null,
        status: (status != null && status != 'all') ? status : null,
      );
      history.assignAll(items);
    } catch (e) {
      debugPrint("Error fetching referral history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  List<ReferredUserItem> get filteredUsers {
    List<ReferredUserItem> sourceList = referredUsers;
    if (sourceList.isEmpty && networkTree.value != null && networkTree.value!.children.isNotEmpty) {
      final List<ReferredUserItem> treeUsers = [];
      void extract(List<ReferralNetworkNode> children) {
        for (final c in children) {
          treeUsers.add(
            ReferredUserItem(
              id: c.userId,
              referralCodeUsed: c.referralCode,
              commissionPoints: c.commissionPoints,
              status: 'active',
              user: ReferralUserInfo(
                id: c.userId,
                name: c.name,
                userType: c.userType ?? 'matrimony',
                status: 'active',
                location: c.location,
              ),
            ),
          );
          if (c.children.isNotEmpty) extract(c.children);
        }
      }
      extract(networkTree.value!.children);
      sourceList = treeUsers;
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return sourceList;
    return sourceList.where((item) {
      final userName = item.user?.name.toLowerCase() ?? '';
      final phone = item.user?.phone ?? '';
      final email = item.user?.email?.toLowerCase() ?? '';
      return userName.contains(q) || phone.contains(q) || email.contains(q);
    }).toList();
  }

  void toggleViewMode() {
    isTreeView.value = !isTreeView.value;
  }

  String getReferralCode() {
    // 1. Highest Priority: From AuthService current logged-in user
    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      final userCode = auth.currentUser.value?.reffralCode;
      if (userCode != null && userCode.trim().isNotEmpty) {
        return userCode.trim();
      }
    }

    // 2. Second Priority: From earnings volunteer response (from backend Bearer token)
    if (earnings.value?.volunteer?.referralCode?.isNotEmpty == true) {
      return earnings.value!.volunteer!.referralCode!.trim();
    }

    // 3. Third Priority: From saved user_data JSON in SharedPreferences
    final userJson = SharedPrefs.getString(AppConstants.userDataPref);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        final userCode = userMap['referral_code'] ?? userMap['reffral_code'];
        if (userCode != null && userCode.toString().trim().isNotEmpty) {
          final code = userCode.toString().trim();
          SharedPrefs.setString(AppConstants.referralCodePref, code);
          return code;
        }
      } catch (_) {}
    }

    // 4. Fourth Priority: From SharedPreferences AppConstants.referralCodePref ("referral_code")
    final prefCode = SharedPrefs.getString(AppConstants.referralCodePref);
    if (prefCode != null && prefCode.trim().isNotEmpty) {
      return prefCode.trim();
    }

    // 5. Fifth Priority: Direct key "referral_code"
    final directPref = SharedPrefs.getString("referral_code");
    if (directPref != null && directPref.trim().isNotEmpty) {
      return directPref.trim();
    }

    // 6. Sixth Priority: From shareableLink response
    if (shareableLink.value?.referralCode.isNotEmpty == true) {
      return shareableLink.value!.referralCode.trim();
    }

    return 'MSUQMI6BV4';
  }

  String getReferralLink() {
    if (shareableLink.value?.referralLink.isNotEmpty == true) {
      return shareableLink.value!.referralLink;
    }
    if (earnings.value?.volunteer?.referralLink?.isNotEmpty == true) {
      return earnings.value!.volunteer!.referralLink!;
    }
    return "https://malisetu.com/register?referral_code=${getReferralCode()}";
  }

  void copyReferralCode(BuildContext context) {
    final code = getReferralCode();
    if (code.isEmpty) return;

    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'copied_title'.tr,
      '${'code_copied_msg'.tr}: $code',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  Future<void> copyReferralLink(BuildContext context) async {
    try {
      if (shareableLink.value == null || shareableLink.value!.referralLink.isEmpty) {
        final data = await repository.getShareableLink(referralCode: getReferralCode());
        shareableLink.value = data;
      }
    } catch (_) {}

    final link = getReferralLink();
    if (link.isEmpty) return;

    Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'link_copied_title'.tr,
      'link_copied_msg'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.link_rounded, color: Colors.white),
    );
  }

  // ------------------------------------------------------------------------
  // Share Referral Link using exact API response data (/api/referrals/{code}/share-link)
  // ------------------------------------------------------------------------
  Future<void> shareReferral(BuildContext context) async {
    try {
      isSharing.value = true;
      final currentCode = getReferralCode();

      // 1. Fetch fresh share-link data from API
      try {
        final linkData = await repository.getShareableLink(referralCode: currentCode);
        shareableLink.value = linkData;
      } catch (e) {
        debugPrint("Error fetching shareable link from API: $e");
      }

      final data = shareableLink.value;
      final String messageToShare;

      if (data?.shareMessage != null && data!.shareMessage!.trim().isNotEmpty) {
        // Use exact API share_message
        messageToShare = data.shareMessage!;
      } else {
        // Fallback localized share message
        final link = data?.referralLink.isNotEmpty == true
            ? data!.referralLink
            : getReferralLink();
        final langCode = Get.locale?.languageCode ?? 'mr';

        if (langCode == 'hi') {
          messageToShare = '''
🌟 *माली सेतु (Mali Setu) परिवार में आपका स्वागत है!* 🌟

मेरे रेफरल कोड के माध्यम से माली सेतु ऐप पर पंजीकरण करें और समाज की सभी सेवाओं, वधु-वर, बिजनेस और वेबिनार का लाभ उठाएं!

👉 *मेरा रेफरल कोड:* *$currentCode*
🔗 *पंजीकरण लिंक:* $link

ऐप आज ही डाउनलोड करें और अपने माली समाज से जुड़ें! ✨
''';
        } else if (langCode == 'en') {
          messageToShare = '''
🌟 *Welcome to Mali Setu Community!* 🌟

Register on Mali Setu App using my referral code and enjoy community services, matrimony, business directory, and webinars!

👉 *My Referral Code:* *$currentCode*
🔗 *Registration Link:* $link

Download the app today and connect with our Mali community! ✨
''';
        } else {
          messageToShare = '''
🌟 *माळी सेतू (Mali Setu) परिवारात आपले स्वागत आहे!* 🌟

माझ्या रेफरल कोडद्वारे माळी सेतू ॲपवर नोंदणी करा आणि समाजातील सर्व सेवा, वधु-वर, बिझनेस आणि वेबिनार्सचा लाभ घ्या!

👉 *माझा रेफरल कोड:* *$currentCode*
🔗 *नोंदणी लिंक:* $link

ॲप आजच डाउनलोड करा आणि आपल्या माळी समाजाशी जोडले जा! ✨
''';
        }
      }

      final box = context.findRenderObject() as RenderBox?;
      final Rect? sharePositionOrigin = box != null
          ? (box.localToGlobal(Offset.zero) & box.size)
          : null;

      await Share.share(
        messageToShare,
        subject: "Mali Setu Referral - ${data?.referralCode ?? currentCode}",
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint("Error sharing referral: $e");
    } finally {
      isSharing.value = false;
    }
  }

  // ------------------------------------------------------------------------
  // API: Send referral link directly to email (POST /api/referrals/{code}/send-email)
  // ------------------------------------------------------------------------
  Future<bool> sendReferralEmail({
    String? email,
    String? recipientName,
    String? message,
  }) async {
    final targetEmail = (email ?? emailController.text).trim();
    final targetName = (recipientName ?? recipientNameController.text).trim();
    final targetMessage = (message ?? messageController.text).trim();

    if (targetEmail.isEmpty || !GetUtils.isEmail(targetEmail)) {
      Get.snackbar(
        'invalid_email'.tr,
        'enter_email_hint'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    try {
      isSendingEmail.value = true;
      final currentCode = getReferralCode();
      final result = await repository.sendReferralLink(
        email: targetEmail,
        referralCode: currentCode,
        recipientName: targetName.isNotEmpty ? targetName : null,
        message: targetMessage.isNotEmpty ? targetMessage : null,
      );

      emailController.clear();
      recipientNameController.clear();
      messageController.clear();

      Get.snackbar(
        'sent_success'.tr,
        result.email.isNotEmpty ? result.email : 'sent_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSendingEmail.value = false;
    }
  }
}
