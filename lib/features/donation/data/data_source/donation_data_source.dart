import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../model/donation_cause_model.dart';

abstract class DonationDataSource {
  Future<DonationCauseResponse> getDonationCauses({int page = 1});
  Future<Map<String, dynamic>> createDonationOrder({required int causeId, required double amount});
  Future<Map<String, dynamic>> verifyDonationPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int donationId,
  });
}

class DonationDataSourceImpl implements DonationDataSource {
  final ApiClient apiClient;

  DonationDataSourceImpl({required this.apiClient});

  @override
  Future<DonationCauseResponse> getDonationCauses({int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.donationCauses,
      queryParameters: {'page': page},
    );
    return DonationCauseResponse.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> createDonationOrder({required int causeId, required double amount}) async {
    final response = await apiClient.post(
      ApiConstants.donationCreateOrder,
      data: {
        'cause_id': causeId,
        'amount': amount,
        'message': "Supporting this cause", // Optional: can be passed from UI
        'anonymous': true, // Optional: can be passed from UI
      },
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> verifyDonationPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int donationId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.donationVerifyPayment,
      data: {
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
        "donation_id": donationId,
      },
    );
    return response.data;
  }
}
