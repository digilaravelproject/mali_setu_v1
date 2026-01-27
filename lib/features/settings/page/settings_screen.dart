import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../widgets/custom_buttons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final userData = {
    'name': 'Aarav Sharma',
    'email': 'aarav.sharma@example.com',
    'role': 'Premium User',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              // User Profile Header
              _buildUserHeader(),

              // Settings List
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Information Section
                        _buildSectionHeader('USER INFORMATION'),
                        buildInfoCard(
                          infoItems: [
                            {'title': 'My Profile', 'icon': Icons.person_outline, 'onTap': () {
                             Get.toNamed(AppRoutes.profileScreen);
                            },},
                            {'title': 'App Language', 'icon': Icons.language},
                            {'title': 'User Approval', 'icon': Icons.verified},
                            {'title': 'Active User', 'icon': CupertinoIcons.person_2_fill,},
                          ],
                        ),

                        // Business Section
                        _buildSectionHeader('BUSINESS'),
                        buildInfoCard(
                          infoItems: [
                            {
                              'title': 'Active Business',
                              'icon': Icons.business,
                            },
                            {
                              'title': 'Business Approval',
                              'icon': Icons.verified,
                            },
                            {'title': 'Business Type', 'icon': Icons.list},
                            {'title': 'Saved Business', 'icon': Icons.bookmark},
                          ],
                        ),

                        // Volunteer Section
                        _buildSectionHeader('VOLUNTEER'),
                        //_buildVolunteerSection(),
                        buildInfoCard(
                          infoItems: [
                            {
                              'title': 'Active Volunteer',
                              'icon': Icons.favorite,
                            },
                            {
                              'title': 'Volunteer Approval',
                              'icon': Icons.verified,
                            },
                            {
                              'title': 'Volunteer Excel Download',
                              'icon': Icons.download_for_offline_sharp,
                            },
                          ],
                        ),

                        // Legal Section
                        _buildSectionHeader('LEGAL'),
                        //  _buildLegalSection(),
                        buildInfoCard(
                          infoItems: [
                            {'title': 'Privacy Policy', 'icon': Icons.policy},
                            {
                              'title': 'Terms & Conditions',
                              'icon': Icons.file_open,
                            },
                            {
                              'title': 'Contact Supports',
                              'icon': Icons.contact_support,
                            },
                          ],
                        ),
                        // App Settings Section
                        _buildSectionHeader('APP SETTINGS'),
                        //  _buildAppSettingsSection(),
                        buildInfoCard(
                          infoItems: [
                            {
                              'title': 'Share App',
                              'icon': CupertinoIcons.arrowshape_turn_up_right_fill,
                              'onTap': () async {
                                try {
                                  await Share.share(
                                    'Check out this amazing app!\n\nDownload link: https://yourapp.com',
                                    subject: 'Awesome App Recommendation',
                                  );
                                } catch (e) {
                                  debugPrint('Share failed: $e');
                                }
                              },
                            },
                            {'title': 'Logout', 'icon': Icons.logout,"onTap":(){
                              LogoutDialog.show(
                                context: context,
                                title: 'Confirm Logout',
                                message: 'You will be redirected to login screen',
                              );
                            }
                            },
                          ],
                        ),

                        // Add Business Button
                        const SizedBox(height: 20),
                        _buildSectionHeader('Do you want to register your own business ?'),
                        SizedBox(height: 8,),
                        CustomButton(
                          height: 40,
                          borderRadius: 14,
                          title: "Register Your Own Business",
                          onPressed: () {},
                        ),
                        // _buildAddBusinessButton(),
                        // Card(
                        //   elevation: 0,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(12),
                        //     side: BorderSide(
                        //       color: context.theme.dividerColor,
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(16),
                        //     child: Column(children: [
                        //       Text("Do you want to register your own business ?",style: context.textTheme.titleMedium,),
                        //       SizedBox(height: 8,),
                        //       CustomButton(
                        //         height: 40,
                        //         borderRadius: 14,
                        //         title: "Register Your Own Business",
                        //         onPressed: () {},
                        //       ),
                        //     ]),
                        //   ),
                        // ),


                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Initiative By",
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                " Anushka Foundation",
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: context.theme.primaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              // _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.primaryColorLight,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Get.toNamed(AppRoutes.profileScreen);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.theme.primaryColor,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: context.theme.cardColor,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name']!,
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
                Text(
                  userData['email']!,
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.theme.primaryColor,
        ),
      ),
    );
  }

  Widget buildInfoCard({required List<Map<String, dynamic>> infoItems}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.theme.dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: infoItems
              .map((item) => _buildInfoRow(
            onTap: item['onTap'],
            title: item['title'],
            icon: item['icon'],
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required IconData icon,
    VoidCallback? onTap,} ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.theme.primaryColorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 18, color: context.theme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.bodyMedium,

              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: context.iconColor),
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildBusinessSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Active Business', '12', Colors.blue),
            _buildStatRow('Business Approval', '10/12', Colors.green),
            _buildStatRow('Business Type', '3 Types', Colors.orange),
            _buildStatRow('Saved Business', '5', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Active Volunteer', '25', Colors.red),
            _buildStatRow('Volunteer Approval', '20/25', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsRow('Excel Download', Icons.download_for_offline),
            _buildSettingsRow('Share App', Icons.share),
            _buildSettingsRow(
              'Notification Settings',
              Icons.notifications_none,
            ),
            _buildSettingsRow(
              'Dark Mode',
              Icons.dark_mode_outlined,
              isSwitch: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    String title,
    IconData icon, {
    bool isSwitch = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (isSwitch)
            Switch(
              value: false,
              onChanged: (value) {},
              activeColor: Colors.blue,
            )
          else
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLegalRow('Privacy Policy', Icons.privacy_tip_outlined),
            _buildLegalRow('Terms & Conditions', Icons.description_outlined),
            _buildLegalRow('About Us', Icons.info_outline),
            _buildLegalRow('Contact Support', Icons.support_agent_outlined),
            _buildLegalRow('Rate App', Icons.star_border),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalRow(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildAddBusinessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Add business
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Colors.blue.shade200,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 10),
            Text(
              'ADD YOUR BUSINESS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        children: [
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                // Logout
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                'LOGOUT',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Initiative Text
          Text(
            'Initiative by',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Organization Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 2.1.4 • © 2024 All Rights Reserved',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }*/
}















class LogoutDialog {
  static Future<bool?> show({
    required BuildContext context,
    String title = 'Log Out',
    String message = 'Are you sure you want to log out?',
    String confirmText = 'Log Out',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
    Color cancelColor = Colors.grey,
    bool showIcon = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                if (showIcon)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.logout,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),

                if (showIcon) SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: cancelColor),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: cancelColor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Logout Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: confirmColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


