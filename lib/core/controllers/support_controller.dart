import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_snack_bar.dart';
import '../constent/api_constants.dart';
import '../network/api_client.dart';

class SupportNumberModel {
  final String key;
  final String label;
  final String number;

  SupportNumberModel({
    required this.key,
    required this.label,
    required this.number,
  });

  factory SupportNumberModel.fromJson(Map<String, dynamic> json) {
    return SupportNumberModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
    );
  }
}

class SupportController extends GetxController {
  static SupportController get to {
    if (Get.isRegistered<SupportController>()) {
      return Get.find<SupportController>();
    }
    return Get.put(SupportController(), permanent: true);
  }

  final RxBool isLoading = false.obs;
  final RxString primaryNumber = "+918828287535".obs;
  final RxString primaryLabel = "Support".obs;
  final RxString secondaryNumber = "+918975845684".obs;
  final RxString secondaryLabel = "Technical Support".obs;
  final RxList<SupportNumberModel> supportNumbers = <SupportNumberModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupportNumbers();
  }

  /// Fetch support numbers from API (https://malisetu.com/api/support-numbers)
  Future<void> fetchSupportNumbers() async {
    try {
      isLoading.value = true;
      ApiClient? apiClient;
      if (Get.isRegistered<ApiClient>()) {
        apiClient = Get.find<ApiClient>();
      } else {
        apiClient = ApiClient();
        Get.put<ApiClient>(apiClient, permanent: true);
      }

      print("🚀 [SupportController] Fetching support numbers from '${ApiConstants.supportNumbers}'");
      final response = await apiClient.get(ApiConstants.supportNumbers);

      print("📡 [SupportController] Status: ${response.statusCode}, Data: ${response.data}");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final dynamic resData = response.data;
        if (resData is Map && resData['success'] == true) {
          final list = resData['data']?['support_numbers'] as List?;
          if (list != null && list.isNotEmpty) {
            final parsedList = list
                .map((e) => SupportNumberModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            supportNumbers.value = parsedList;

            for (var item in parsedList) {
              final key = item.key.toLowerCase().trim();
              if (key == 'primary') {
                if (item.number.trim().isNotEmpty) {
                  primaryNumber.value = item.number.trim();
                }
                if (item.label.trim().isNotEmpty) {
                  primaryLabel.value = item.label.trim();
                }
              } else if (key == 'secondary') {
                if (item.number.trim().isNotEmpty) {
                  secondaryNumber.value = item.number.trim();
                }
                if (item.label.trim().isNotEmpty) {
                  secondaryLabel.value = item.label.trim();
                }
              }
            }
            print("✅ [SupportController] Loaded Primary: ${primaryNumber.value}, Secondary: ${secondaryNumber.value}");
          }
        }
      }
    } catch (e) {
      print("❌ [SupportController] Error fetching support numbers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Open Support chat (Primary number)
  Future<void> openSupportChat({String? message}) async {
    await launchWhatsApp(
      phoneNumber: primaryNumber.value,
      message: message ?? "Hello Mali Setu Support Team, I need assistance.",
    );
  }

  /// Open Technical Support chat (Secondary number)
  Future<void> openTechnicalSupportChat({String? message}) async {
    await launchWhatsApp(
      phoneNumber: secondaryNumber.value,
      message: message ?? "Hello Mali Setu Technical Support Team, I need technical assistance.",
    );
  }

  /// Standard WhatsApp launcher method
  static Future<void> launchWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneWithCountry = cleanNumber.startsWith('91') ? cleanNumber : '91$cleanNumber';
    final encodedMessage = Uri.encodeComponent(message);

    final appUri = Uri.parse("whatsapp://send?phone=$phoneWithCountry&text=$encodedMessage");
    final webUri = Uri.parse("https://wa.me/$phoneWithCountry?text=$encodedMessage");

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.showError(message: "WhatsApp is not installed on this device");
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        CustomSnackBar.showError(message: "Could not open WhatsApp support");
      }
    }
  }
}

