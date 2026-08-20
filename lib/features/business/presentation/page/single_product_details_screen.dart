import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/business/presentation/controller/single_product_controller.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class SingleProductDetailsScreen extends StatelessWidget {
  final SingleProductController controller = Get.find<SingleProductController>();

  SingleProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.product.value?.name ?? 'product_details'.tr,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        )),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final product = controller.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(product),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Unnamed Product',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${product.cost ?? "0"}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'description'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Divider(height: 32, thickness: 1),
                    if (product.business != null) _buildBusinessInfo(product.business!),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 80, color: Colors.grey),
      );
    }

    return Image.network(
      '${ApiConstants.imageBaseUrl}/${product.imagePath}',
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildBusinessInfo(Business business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'business_details'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: business.photo != null
                ? NetworkImage('${ApiConstants.imageBaseUrl}/${business.photo}')
                : null,
            child: business.photo == null
                ? const Icon(Icons.store, color: Colors.grey)
                : null,
          ),
          title: Text(
            business.businessName ?? 'Unnamed Business',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(business.address ?? ''),
        ),
        if (business.contactPhone != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(business.contactPhone!),
            ],
          ),
        ],
        if (business.contactEmail != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(business.contactEmail!),
            ],
          ),
        ],
      ],
    );
  }
}
