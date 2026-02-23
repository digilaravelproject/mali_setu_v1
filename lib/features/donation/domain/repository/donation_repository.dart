import '../../data/data_source/donation_data_source.dart';
import '../../data/model/donation_cause_model.dart';
import 'package:edu_cluezer/core/network/api_response.dart';

abstract class DonationRepository {
  Future<ApiResponse<DonationCauseResponse>> getDonationCauses({int page = 1});
  Future<ApiResponse<Map<String, dynamic>>> createDonationOrder({required int causeId, required double amount});
  Future<ApiResponse<Map<String, dynamic>>> verifyDonationPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int donationId,
  });
}

class DonationRepositoryImpl implements DonationRepository {
  final DonationDataSource dataSource;

  DonationRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResponse<DonationCauseResponse>> getDonationCauses({int page = 1}) async {
    try {
      final response = await dataSource.getDonationCauses(page: page);
      if (response.success == true) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error("Failed to fetch donation causes");
      }
    } catch (e) {
      return ApiResponse.error("Error: $e");
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createDonationOrder({required int causeId, required double amount}) async {
    try {
      final response = await dataSource.createDonationOrder(causeId: causeId, amount: amount);
      if (response['success'] == true) {
        return ApiResponse.success(response['data']);
      } else {
        return ApiResponse.error(response['message'] ?? "Failed to create donation order");
      }
    } catch (e) {
      return ApiResponse.error("Error: $e");
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> verifyDonationPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int donationId,
  }) async {
    try {
      final response = await dataSource.verifyDonationPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        donationId: donationId,
      );
      if (response['success'] == true) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(response['message'] ?? "Payment verification failed");
      }
    } catch (e) {
      return ApiResponse.error("Error: $e");
    }
  }
}
