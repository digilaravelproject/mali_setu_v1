import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/donation_cause_model.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';

Future<void> showDonationPrompt(
    List<DonationCauseItem> causes, Function(DonationCauseItem) onDetails,
    {VoidCallback? onClose}) async {
  if (causes.isEmpty) return;

  await Get.bottomSheet(
    _DonationBottomSheet(
        causes: causes, onDetails: onDetails, onClose: onClose),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _DonationBottomSheet extends StatelessWidget {
  final List<DonationCauseItem> causes;
  final Function(DonationCauseItem) onDetails;
  final VoidCallback? onClose;

  const _DonationBottomSheet(
      {required this.causes, required this.onDetails, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "spread_kindness".tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "donation_prompt_description".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: causes.take(2).map((cause) => _buildCauseCard(context, cause)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Get.back();
              if (onClose != null) onClose!();
            },
            child: Text("not_right_now".tr,
                style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildCauseCard(BuildContext context, DonationCauseItem cause) {
    return GestureDetector(
      onTap: () {
        Get.back();
        onDetails(cause);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageView(
                url: cause.imageUrl != null ? "${ApiConstants.baseUrl}${cause.imageUrl}" : null,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cause.title ?? "cause".tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cause.organization ?? "organization".tr,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${"goal".tr}: ₹${cause.targetAmount}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: context.theme.primaryColor)
            
            // ElevatedButton(
            //   onPressed: () {
            //     Get.back();
            //     onDetails(cause);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: context.theme.primaryColor,
            //     foregroundColor: Colors.white,
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //     elevation: 0,
            //   ),
            //   child: const Text("Donate"),
            // ),
          ],
        ),
      ),
    );
  }
}
