import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/model/business_enquiries_model.dart';
import '../../data/model/res_all_business_model.dart';
import '../../domain/repository/all_business_repository.dart';

class BusinessEnquiriesController extends GetxController {
  final BusinessRepository _repository = Get.find<BusinessRepository>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<Business?> business = Rx<Business?>(null);
  int businessId = 0;

  final RxList<BusinessEnquiryItem> enquiries = <BusinessEnquiryItem>[].obs;
  final RxString filterType = 'all'.obs; // 'all', 'product', 'service'
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  int currentPage = 1;
  int lastPage = 1;
  int totalEnquiries = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Business) {
      business.value = args;
      businessId = args.id ?? 0;
    } else if (args is Map) {
      if (args['business'] is Business) {
        business.value = args['business'];
        businessId = business.value?.id ?? 0;
      }
      if (businessId == 0 && args['business_id'] != null) {
        businessId = int.tryParse(args['business_id'].toString()) ?? 0;
      } else if (businessId == 0 && args['businessId'] != null) {
        businessId = int.tryParse(args['businessId'].toString()) ?? 0;
      }
    } else if (args is int) {
      businessId = args;
    }

    if (businessId > 0) {
      fetchEnquiries(isRefresh: true);
    }
  }

  void setFilterType(String type) {
    filterType.value = type;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<BusinessEnquiryItem> get filteredEnquiries {
    var list = enquiries.toList();

    // Filter by type
    if (filterType.value == 'product') {
      list = list.where((e) => e.isProduct).toList();
    } else if (filterType.value == 'service') {
      list = list.where((e) => e.isService).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value;
      list = list.where((e) {
        final userName = (e.user?.name ?? '').toLowerCase();
        final userPhone = (e.user?.phone ?? '').toLowerCase();
        final userEmail = (e.user?.email ?? '').toLowerCase();
        final itemName = (e.enquirable?.name ?? '').toLowerCase();
        final desc = (e.description ?? '').toLowerCase();
        return userName.contains(q) ||
            userPhone.contains(q) ||
            userEmail.contains(q) ||
            itemName.contains(q) ||
            desc.contains(q);
      }).toList();
    }

    return list;
  }

  int get productEnquiriesCount => enquiries.where((e) => e.isProduct).length;
  int get serviceEnquiriesCount => enquiries.where((e) => e.isService).length;

  Future<void> fetchEnquiries({bool isRefresh = false}) async {
    if (businessId <= 0) {
      errorMessage.value = "Business ID not found";
      return;
    }

    if (isRefresh) {
      currentPage = 1;
      isLoading.value = true;
      errorMessage.value = '';
    } else {
      if (currentPage >= lastPage || isLoadMore.value) return;
      isLoadMore.value = true;
      currentPage++;
    }

    try {
      final response = await _repository.getBusinessEnquiries(
        businessId,
        page: currentPage,
        perPage: 20,
      );

      if (response.success && response.data != null) {
        if (response.data!.business != null) {
          business.value = response.data!.business;
        }

        currentPage = response.data!.currentPage;
        lastPage = response.data!.lastPage;
        totalEnquiries = response.data!.total;

        if (isRefresh) {
          enquiries.assignAll(response.data!.enquiries);
        } else {
          enquiries.addAll(response.data!.enquiries);
        }
      } else {
        if (isRefresh) {
          enquiries.clear();
        }
        errorMessage.value = response.message ?? "No enquiries found";
      }
    } catch (e) {
      debugPrint("ERROR_FETCH_ENQUIRIES: $e");
      if (isRefresh) {
        errorMessage.value = "Failed to load enquiries. Please pull to refresh.";
      }
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  Future<void> makePhoneCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      CustomSnackBar.showError(message: "Phone number not available");
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.showError(message: "Cannot make call to $phone");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to open phone dialer");
    }
  }

  Future<void> openWhatsApp(String? phone, {String? customerName, String? itemName}) async {
    if (phone == null || phone.trim().isEmpty) {
      CustomSnackBar.showError(message: "Phone number not available for WhatsApp");
      return;
    }

    var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = "91$cleanPhone";
    }

    final bizName = business.value?.businessName ?? "our business";
    final itemText = itemName != null && itemName.isNotEmpty ? " regarding '$itemName'" : "";
    final defaultMsg = "Hello ${customerName ?? ''}, thank you for inquiring at $bizName$itemText. How can we assist you today?";

    final uri = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(defaultMsg)}");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.showError(message: "Cannot open WhatsApp for $phone");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to launch WhatsApp");
    }
  }

  Future<void> sendEmail(String? email, {String? itemName}) async {
    if (email == null || email.trim().isEmpty) {
      CustomSnackBar.showError(message: "Email address not available");
      return;
    }
    final bizName = business.value?.businessName ?? "Business";
    final subject = Uri.encodeComponent("Response to your enquiry - $bizName");
    final body = Uri.encodeComponent("Hello,\n\nThank you for reaching out regarding ${itemName ?? 'our business'}.\n\nBest regards,\n$bizName");
    final uri = Uri.parse("mailto:$email?subject=$subject&body=$body");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.showError(message: "Cannot open email client for $email");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to open email client");
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
