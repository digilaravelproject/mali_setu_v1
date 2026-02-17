import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/matrimony/data/model/payment_model.dart';

class PaymentDataSource {
  final ApiClient apiClient;

  PaymentDataSource({required this.apiClient});

  Future<CreateOrderResponse> createOrderMatrimony(int planId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.createOrderMatrimony,
        data: {'plan_id': planId},
      );
      return CreateOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<VerifyPaymentResponse> verifyPayment(
    String razorpayPaymentId,
    String razorpayOrderId,
    String razorpaySignature,
    String transactionId,
  ) async {
    try {
      final request = VerifyPaymentRequest(
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
        transactionId: transactionId,
      );

      final response = await apiClient.post(
        ApiConstants.verifyPayment,
        data: request.toJson(),
      );
      return VerifyPaymentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }
}
