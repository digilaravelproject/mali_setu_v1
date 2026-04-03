import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_login_model.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';

import 'package:edu_cluezer/core/helper/string_extensions.dart';
import '../../../core/utils/app_assets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = Get.find<AuthService>();

  User? get user => authService.currentUser.value;

  Map<String, String> get userData => {
    'profileImage': '',
    'fullName': user?.name.toTitleCase() ?? 'Name Not Available',
    'email': user?.email ?? 'Email Not Available',
    'mobile': user?.phone ?? 'N/A',
    'age': user?.age != null ? '${user!.age} Years' : '',
    'phoneNumber': user?.phone ?? 'N/A',
    'occupation': user?.occupation.toTitleCase() ?? 'N/A',
    'referralCode': user?.reffralCode ?? 'N/A',
    'streetAddress': user?.address ?? 'N/A',
    'nearbyLocation': user?.nearbyLocation ?? 'N/A',
    'roadNumber': user?.roadNumber ?? 'N/A',
    'city': user?.city ?? 'N/A',
    'state': user?.state ?? 'N/A',
    'district': user?.district ?? 'N/A',
    'pincode': user?.pincode ?? 'N/A',
    'sector': user?.sector ?? 'N/A',
    'destination': user?.destination ?? 'N/A',
    'accountStatus': user?.status ?? 'Active',
    'joinedDate': user?.createdAt ?? 'N/A',
    'membershipType': 'Premium',
  };

  @override
  void initState() {
    super.initState();
    // Refresh profile data when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authService.refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
             margin: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               border: Border.all(color: Colors.grey[200]!)
             ),
             child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
        ),
        title: Text(
          "my_profile".tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // Basic Information
            _buildSectionCard(
              title: 'basic_information'.tr,
              icon: Icons.person_outline_rounded,
              child: _buildBasicInfo(),
            ),

            // Contact Information
            _buildSectionCard(
              title: 'contact_information'.tr,
              icon: Icons.contact_phone_outlined,
              child: _buildContactInfo(),
            ),

            // Address Information
            _buildSectionCard(
              title: 'address_information'.tr,
              icon: Icons.location_on_outlined,
              child: _buildAddressInfo(),
            ),

            const SizedBox(height: 20),
            CustomButton(
              height: 48,
              borderRadius: 14,
              title: "change_password".tr,
              onPressed: () {
                Get.toNamed(AppRoutes.changePassword);
              },
              backgroundColor: context.theme.primaryColor,
              textColor: context.theme.cardColor,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ));
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.theme.primaryColor.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: context.theme.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
               child: CustomImageView(
                  url: user?.profileImage,
                  imagePath: AppAssets.getAppLogo(),
                  fit: BoxFit.cover,
                ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userData['fullName']!,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userData['email']!,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
             Get.toNamed(AppRoutes.updateProfile);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            side: BorderSide(color: context.theme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: Icon(Icons.edit_outlined, size: 16, color: context.theme.primaryColor),
          label: Text(
            'edit_profile'.tr,
            style: TextStyle(
              color: context.theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: context.theme.primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _buildInfoRow(
          label: 'full_name'.tr,
          value: userData['fullName']!,
          icon: Icons.person_outline,
        ),
        // const SizedBox(height: 16),
        // _buildInfoRow(label: 'age'.tr, value: userData['age']!, icon: Icons.cake_outlined),
        if (userData['age'] != null && userData['age'].toString().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'age'.tr,
            value: userData['age'].toString(),
            icon: Icons.cake_outlined,
          ),
        ],
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'occupation'.tr,
          value: userData['occupation']!,
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'referral_code'.tr,
          value: userData['referralCode']!,
          icon: Icons.confirmation_number_outlined,
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(
          label: 'email_address'.tr,
          value: userData['email']!,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'mobile_number'.tr,
          value: userData['mobile']!,
          icon: Icons.phone_android_outlined,
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      children: [
        _buildInfoRow(
          label: 'street_address'.tr,
          value: userData['streetAddress']!,
          icon: Icons.home_outlined,
          isFullWidth: true,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoRow(
                label: 'city'.tr,
                value: userData['city']!,
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                label: 'state'.tr,
                value: userData['state']!,
                icon: Icons.map_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Expanded(
              child: _buildInfoRow(
                label: 'district'.tr,
                value: userData['district']!,
                icon: Icons.terrain_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                label: 'pincode'.tr,
                value: userData['pincode']!,
                icon: Icons.pin_drop_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon(icon, size: 18, color: Colors.grey[400]),
        // const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: isFullWidth ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
