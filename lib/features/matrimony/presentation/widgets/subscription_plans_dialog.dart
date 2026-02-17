/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/matrimony/data/model/subscription_plan_model.dart';
import 'package:edu_cluezer/features/matrimony/data/data_source/payment_data_source.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';

class SubscriptionPlansDialog extends StatefulWidget {
  final List<SubscriptionPlan> plans;
  final VoidCallback? onClose;

  const SubscriptionPlansDialog({
    Key? key,
    required this.plans,
    this.onClose,
  }) : super(key: key);

  @override
  State<SubscriptionPlansDialog> createState() => _SubscriptionPlansDialogState();

  static void show(List<SubscriptionPlan> plans, {VoidCallback? onClose}) {
    Get.dialog(
      SubscriptionPlansDialog(
        plans: plans,
        onClose: onClose,
      ),
      barrierDismissible: false,
    );
  }
}

class _SubscriptionPlansDialogState extends State<SubscriptionPlansDialog> {
  late PaymentDataSource paymentDataSource;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    paymentDataSource = PaymentDataSource(apiClient: Get.find<ApiClient>());
  }

  Future<void> _handleSubscribe(SubscriptionPlan plan) async {
    if (plan.id == null) return;

    setState(() => isLoading = true);

    try {
      // Step 1: Create Order
      final orderResponse = await paymentDataSource.createOrderMatrimony(plan.id!);

      if (!orderResponse.success || orderResponse.data == null) {
        CustomSnackBar.showError(
          message: orderResponse.message ?? 'Failed to create order',
        );
        setState(() => isLoading = false);
        return;
      }

      final orderData = orderResponse.data!;

      // Step 2: Open Razorpay Payment Gateway
      // TODO: Integrate Razorpay SDK
      // For now, show a demo message
      CustomSnackBar.showInfo(
        message: 'Order Created: ${orderData.orderId}\nAmount: ₹${orderData.amount}',
      );

      // Step 3: After payment, verify it
      // This would be called after Razorpay returns payment details
      // await _verifyPayment(
      //   razorpayPaymentId: paymentId,
      //   razorpayOrderId: orderData.orderId!,
      //   razorpaySignature: signature,
      //   transactionId: orderData.transactionId.toString(),
      // );

      setState(() => isLoading = false);
    } catch (e) {
      CustomSnackBar.showError(message: 'Error: ${e.toString()}');
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required String transactionId,
  }) async {
    try {
      final verifyResponse = await paymentDataSource.verifyPayment(
        razorpayPaymentId,
        razorpayOrderId,
        razorpaySignature,
        transactionId,
      );

      if (verifyResponse.success) {
        CustomSnackBar.showSuccess(
          message: 'Payment verified successfully!',
        );
        Get.back();
        widget.onClose?.call();
      } else {
        CustomSnackBar.showError(
          message: verifyResponse.message ?? 'Payment verification failed',
        );
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Verification error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.theme.primaryColor,
                    context.theme.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.card_membership,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'subscription_plans'.tr,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'choose_plan_subtitle'.tr,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Plans List
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: List.generate(
                    widget.plans.length,
                    (index) => _buildPlanCard(context, widget.plans[index], index),
                  ),
                ),
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          widget.onClose?.call();
                          Get.back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'close'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, int index) {
    final isPopular = index == 1; // Gold plan is popular

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular ? context.theme.primaryColor : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isPopular ? context.theme.primaryColor.withOpacity(0.05) : Colors.white,
      ),
      child: Stack(
        children: [
          // Popular Badge
          if (isPopular)
            Positioned(
              top: -12,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'most_popular'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name
                Text(
                  plan.planName ?? '',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                // Duration
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: context.theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${plan.durationYears} ${'year'.tr}${plan.durationYears! > 1 ? 's' : ''}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'price'.tr,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${plan.price}',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: context.theme.primaryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _handleSubscribe(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? context.theme.primaryColor
                          : context.theme.primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                isPopular ? Colors.white : context.theme.primaryColor,
                              ),
                            ),
                          )
                        : Text(
                            'subscribe_now'.tr,
                            style: TextStyle(
                              color: isPopular ? Colors.white : context.theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
