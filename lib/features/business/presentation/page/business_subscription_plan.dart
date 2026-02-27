import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/model/business_plan_model.dart';

Future<BusinessPlan?> showBusinessSubscriptionBottomSheet(List<BusinessPlan> plans) async {
  return await Get.bottomSheet<BusinessPlan>(
    _BusinessBottomSheet(plans: plans),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _BusinessBottomSheet extends StatefulWidget {
  final List<BusinessPlan> plans;

  const _BusinessBottomSheet({required this.plans});

  @override
  State<_BusinessBottomSheet> createState() => _BusinessBottomSheetState();
}

class _BusinessBottomSheetState extends State<_BusinessBottomSheet> {
  BusinessPlan? selectedPlan;

  @override
  void initState() {
    super.initState();
    // Select the highest price plan by default
    if (widget.plans.isNotEmpty) {
      selectedPlan = widget.plans.reduce((current, next) {
        final currentPrice = double.tryParse(current.price ?? '0') ?? 0;
        final nextPrice = double.tryParse(next.price ?? '0') ?? 0;
        return currentPrice > nextPrice ? current : next;
      });
    }
  }

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
          //Premium Header with Gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.theme.primaryColorDark,
                  context.theme.primaryColor,
                  context.theme.primaryColor,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header with Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Business Subscription",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Boost your business reach",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
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
                  height: 45,
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
                      "Select Plan",
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

  Widget _buildPlanCard(BusinessPlan plan) {
    final bool isSelected = selectedPlan?.id == plan.id;

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
          color: isSelected ? context.theme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.theme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? context.theme.primaryColor : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getPlanIcon(plan.durationYears),
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
                    "${plan.durationYears} ${plan.durationYears == 1 ? 'Year' : 'Years'} Plan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? context.theme.primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    plan.companyType ?? "Standard Business",
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
                color: isSelected ? context.theme.primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlanIcon(int? years) {
    if (years == 1) return Icons.star_outline_rounded;
    if (years == 2) return Icons.star_half_rounded;
    if (years != null && years >= 3) return Icons.stars_rounded;
    return Icons.card_membership_rounded;
  }
}
