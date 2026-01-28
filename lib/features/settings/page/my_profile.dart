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
    'age': user?.age != null ? '${user!.age} Years' : 'N/A',
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
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        title: Text("My Profile", style: context.textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            // Basic Information
            _buildSectionCard(
              title: 'BASIC INFORMATION',
              icon: Icons.person_outline,
              child: _buildBasicInfo(),
            ),

            // Contact Information
            _buildSectionCard(
              title: 'CONTACT INFORMATION',
              icon: Icons.contact_phone,
              child: _buildContactInfo(),
            ),

            // Address Information
            _buildSectionCard(
              title: 'ADDRESS INFORMATION',
              icon: Icons.location_on,
              child: _buildAddressInfo(),
            ),

            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                  height: 40,
                  borderRadius: 12,
                  title: "Change Password",
                  onPressed: (){
                    Get.toNamed(AppRoutes.changePassword);
                  }),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    ));
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        // color:  context.theme.primaryColorLight,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     context.theme.primaryColorLight,
        //     context.theme.cardColor,
        //   ],
        // ),
        border: Border(
          bottom: BorderSide(color: context.theme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.theme.primaryColor,
                    width: 3,
                  ),
                ),
                child: CustomImageView(
                  url: user?.profileImage,
                  imagePath: AppAssets.imgAppLogo,
                  fit: BoxFit.cover,
                ),
              ),
             /* Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.theme.cardColor, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: context.theme.cardColor,
                ),
              ),*/
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userData['fullName']!,
            style: context.textTheme.headlineMedium
            // const TextStyle(
            //   fontSize: 22,
            //   fontWeight: FontWeight.w700,
            //   color: Colors.black87,
            // ),
          ),
        //  const SizedBox(height: 6),
          Text(
            userData['email']!,
            style: context.textTheme.bodyLarge
           // TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 16, color: context.iconColor),
              const SizedBox(width: 6),
              Text(
                userData['mobile']!,
                style:context.textTheme.bodyMedium
               // TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: (){
              Get.toNamed(AppRoutes.updateProfile);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: context.theme.primaryColorLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color:  context.theme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mode_edit_outline_sharp, size: 16, color:  context.theme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'Edit Profile',
                    style: context.textTheme.bodyMedium?.copyWith(color: context.theme.primaryColor)
                    // TextStyle(
                    //   fontSize: 13,
                    //   fontWeight: FontWeight.w500,
                    //   color: Colors.blue.shade700,
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.theme.dividerColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                 // Icon(icon, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor)
                    // TextStyle(
                    //   fontSize: 14,
                    //   fontWeight: FontWeight.w600,
                    //   color: Colors.grey.shade700,
                    //   letterSpacing: 0.5,
                    // ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _buildInfoRow(
          label: 'Full Name',
          value: userData['fullName']!,
          icon: Icons.person,
        ),
        const Divider(height: 20),
        _buildInfoRow(label: 'Age', value: userData['age']!, icon: Icons.cake),
        const Divider(height: 20),
        _buildInfoRow(
          label: 'Occupation',
          value: userData['occupation']!,
          icon: Icons.work,
        ),
        const Divider(height: 20),
        _buildInfoRow(
          label: 'Referral Code',
          value: userData['referralCode']!,
          icon: Icons.confirmation_number,
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(
          label: 'Email Address',
          value: userData['email']!,
          icon: Icons.email,
        ),
        const Divider(height: 20),
        _buildInfoRow(
          label: 'Mobile Number',
          value: userData['mobile']!,
          icon: Icons.phone_android,
        ),
        const Divider(height: 20),
        _buildInfoRow(
          label: 'Phone Number',
          value: userData['phoneNumber']!,
          icon: Icons.phone,
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      children: [
        _buildInfoRow(
          label: 'Street Address',
          value: userData['streetAddress']!,
          icon: Icons.home,
        ),
        const Divider(height: 20),
        _buildInfoRow(
          label: 'Nearby Location',
          value: userData['nearbyLocation']!,
          icon: Icons.location_searching,
        ),
        const Divider(height: 20),
        _buildInfoRow(
          label: 'Road Number',
          value: userData['roadNumber']!,
          icon: Icons.add_road,
        ),
        const Divider(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                label: 'City',
                value: userData['city']!,
                icon: Icons.location_city,

              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInfoRow(
                label: 'State',
                value: userData['state']!,
                icon: Icons.map,
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                label: 'District',
                value: userData['district']!,
                icon: Icons.terrain,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInfoRow(
                label: 'Pincode',
                value: userData['pincode']!,
                icon: Icons.numbers,
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                label: 'Sector',
                value: userData['sector']!,
                icon: Icons.domain,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInfoRow(
                label: 'Destination',
                value: userData['destination']!,
                icon: Icons.place,
              ),
            ),
          ],
        ),
      ],
    );
  }

 /* Widget _buildAccountInfo() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatusBadge(
              'Account Status',
              userData['accountStatus']!,
              Colors.green,
            ),
            const SizedBox(width: 15),
            _buildStatusBadge(
              'Membership',
              userData['membershipType']!,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          label: 'Joined Date',
          value: userData['joinedDate']!,
          icon: Icons.calendar_today,
        ),
      ],
    );
  }*/

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodyMedium
                // TextStyle(
                //   fontSize: 13,
                //   color: Colors.grey.shade600,
                //   fontWeight: FontWeight.w500,
                // ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:context.textTheme.titleMedium
                // TextStyle(
                //   fontSize: 15,
                //   fontWeight: FontWeight.w600,
                //   color: Colors.black87,
                // ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
