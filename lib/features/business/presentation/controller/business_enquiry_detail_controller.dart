import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/model/business_enquiries_model.dart';
import '../../domain/repository/all_business_repository.dart';

class BusinessEnquiryDetailController extends GetxController {
  final BusinessRepository _repository = Get.find<BusinessRepository>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<BusinessEnquiryItem?> enquiry = Rx<BusinessEnquiryItem?>(null);
  final RxInt activeImageIndex = 0.obs;

  int enquiryId = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is BusinessEnquiryItem) {
      enquiry.value = args;
      enquiryId = args.id;
    } else if (args is Map) {
      if (args['enquiry'] is BusinessEnquiryItem) {
        enquiry.value = args['enquiry'];
        enquiryId = enquiry.value?.id ?? 0;
      }
      if (enquiryId == 0 && args['enquiry_id'] != null) {
        enquiryId = int.tryParse(args['enquiry_id'].toString()) ?? 0;
      } else if (enquiryId == 0 && args['id'] != null) {
        enquiryId = int.tryParse(args['id'].toString()) ?? 0;
      }
    } else if (args is int) {
      enquiryId = args;
    }

    if (enquiryId > 0) {
      fetchEnquiryDetail();
    } else {
      errorMessage.value = "Invalid enquiry ID";
    }
  }

  Future<void> fetchEnquiryDetail() async {
    if (enquiryId <= 0) return;
    if (enquiry.value == null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final res = await _repository.getBusinessEnquiryDetail(enquiryId);
      if (res.success && res.enquiry != null) {
        enquiry.value = res.enquiry;
      } else {
        if (enquiry.value == null) {
          errorMessage.value = res.message ?? "Failed to load enquiry details";
        }
      }
    } catch (e) {
      if (enquiry.value == null) {
        errorMessage.value = "Failed to load enquiry details: $e";
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      CustomSnackBar.show(
        message: "Customer phone number is not available",
        type: SnackBarType.warning,
      );
      return;
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri callUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        CustomSnackBar.show(
          message: "Unable to make phone call to $phoneNumber",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        message: "Failed to initiate call: $e",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> openWhatsApp(String? phoneNumber, {String? customerName, String? itemName}) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      CustomSnackBar.show(
        message: "Customer phone number is not available for WhatsApp",
        type: SnackBarType.warning,
      );
      return;
    }

    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = "91$cleanPhone";
    }

    final greeting = customerName != null && customerName.isNotEmpty ? "Hello $customerName," : "Hello,";
    final itemContext = itemName != null && itemName.isNotEmpty ? " regarding your inquiry about '$itemName'" : "";
    final message = "$greeting thank you for reaching out on Mali Setu$itemContext. How can we help you?";

    final Uri waUri = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.show(
          message: "Could not open WhatsApp. Please check if app is installed.",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        message: "Failed to open WhatsApp: $e",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> sendEmail(String? email, {String? itemName}) async {
    if (email == null || email.trim().isEmpty) {
      CustomSnackBar.show(
        message: "Customer email is not available",
        type: SnackBarType.warning,
      );
      return;
    }

    final subject = itemName != null && itemName.isNotEmpty
        ? "Regarding your enquiry about '$itemName' on Mali Setu"
        : "Regarding your enquiry on Mali Setu";

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      queryParameters: {'subject': subject},
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.show(
          message: "Could not open email client",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        message: "Failed to open email: $e",
        type: SnackBarType.error,
      );
    }
  }
}
