import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class CategoryDetailsScreen extends StatelessWidget {
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
                  
                  const SizedBox(height: 24),
                  // Placeholder for future content (e.g. list of businesses)
                  if (category.isActive == false)
                     Container(
                       padding: EdgeInsets.all(8),
                       color: Colors.red.withOpacity(0.1),
                       child: Text("This category is currently inactive.", style: TextStyle(color: Colors.red)),
                     )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
