import 'package:edu_cluezer/features/dashboard/data/model/res_category_business_model.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

import '../../../../common/widgets/bg_gradient_border.dart';
import '../../../../core/helper/string_extensions.dart';
import '../../../business/presentation/page/business_page.dart';
import '../../../business/presentation/page/single_business_details.dart';
import '../controller/cat_business_controller.dart';

class CategoryDetailsScreen extends GetWidget<CatBusinessController> {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Category category = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name ?? "Category Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              url: category.photo != null && category.photo!.isNotEmpty
                  ? category.photo
                  : "https://cdn-icons-png.freepik.com/512/10416/10416308.png",
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? "Unknown Category",
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (category.description != null && category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      style: context.textTheme.bodyMedium,
                    ),
                 // const SizedBox(height: 24),
                  if (category.isActive == false)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.withOpacity(0.1),
                      child: const Text(
                        "This category is currently inactive.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
              child: Text("Related Business",style: context.textTheme.headlineMedium,),
            ),

            // Reactive ListView
            Obx(() {
              if (controller.allBusinesses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("No businesses found.")),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.allBusinesses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BusinessListCard(business: controller.allBusinesses[index]),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}


class BusinessListCard extends StatelessWidget {
  final CatBusiness business;

  const BusinessListCard({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String address = [
      business.user?.address,
      business.user?.city,
    ].where((e) => e != null && e.isNotEmpty).join(", ");

    return GestureDetector(
      onTap: () {
       // Get.to(() => const BusinessDetailScreen(), arguments: business.id);
      },
      child: BgGradientBorder(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: context.theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.businessName ?? '',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: business.status == 'active'
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (business.status ?? 'unknown').toTitleCase(),
                            style: TextStyle(
                              color: business.status == 'active'
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9E9E9E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.category?.name ?? 'General',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${business.products?.length ?? 0} Products',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.settings_outlined,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${business.services?.length ?? 0} Services',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
