import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/model/matrimony_plan_model.dart';

Future<MatrimonyPlan?> showSubscriptionBottomSheet(List<MatrimonyPlan> plans) async {
  return await Get.bottomSheet<MatrimonyPlan>(
    _MatrimonyBottomSheet(plans: plans),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _MatrimonyBottomSheet extends StatefulWidget {
  final List<MatrimonyPlan> plans;

  const _MatrimonyBottomSheet({required this.plans});

  @override
  State<_MatrimonyBottomSheet> createState() => _MatrimonyBottomSheetState();
}

class _MatrimonyBottomSheetState extends State<_MatrimonyBottomSheet> {
  MatrimonyPlan? selectedPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Premium Plans",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Choose your perfect match",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Plans List
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: widget.plans.map((plan) => _buildPlanCard(plan)).toList(),
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (selectedPlan != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Payable Amount:",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Text(
                          "₹${selectedPlan!.price}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedPlan == null
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            Get.back(result: selectedPlan);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continue to Payment",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildPlanCard(MatrimonyPlan plan) {
    final bool isSelected = selectedPlan?.id == plan.id;
    final Color planColor = _getPlanColor(plan.planName);

    return GestureDetector(
      onTap: () {
        setState(() => selectedPlan = plan);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? planColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? planColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? planColor : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getPlanIcon(plan.planName),
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.planName ?? "Plan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? planColor : Colors.black87,
                    ),
                  ),
                  Text(
                    "${plan.durationYears} ${plan.durationYears == 1 ? 'Year' : 'Years'} Validity",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              "₹${plan.price}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? planColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlanColor(String? name) {
    final n = name?.toLowerCase() ?? "";
    if (n.contains("silver")) return Colors.blueGrey;
    if (n.contains("gold")) return const Color(0xFFFFB300);
    if (n.contains("platinum")) return Colors.deepPurple;
    return Get.theme.primaryColor;
  }

  IconData _getPlanIcon(String? name) {
    final n = name?.toLowerCase() ?? "";
    if (n.contains("silver")) return Icons.stars_rounded;
    if (n.contains("gold")) return Icons.workspace_premium_rounded;
    if (n.contains("platinum")) return Icons.diamond_rounded;
    return Icons.card_membership_rounded;
  }
}
