import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportPage extends StatelessWidget {
  final String phoneNumber = "8828287535";
  final String email = "malisetu18@gmail.com";

  // Contact methods
  Future<void> _launchWhatsApp() async {
    final url = Uri.parse("https://wa.me/+91$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch WhatsApp";
    }
  }

  Future<void> _launchEmail() async {
    final url = Uri.parse("mailto:$email?subject=Support Request");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch email";
    }
  }

  Future<void> _launchCall() async {
    final url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch phone dialer";
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50.withOpacity(0.5),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Immersive AppBar
            SliverAppBar(
              expandedHeight: 0,
              toolbarHeight: 56 + topPadding,
              collapsedHeight: 56 + topPadding,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                style: IconButton.styleFrom(side: BorderSide.none),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(
                "support_center".tr,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito-Bold',
                ),
              ),
              floating: true,
              pinned: false,
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero header simplified and compact
                    _buildHeroHeader(context),
                    const SizedBox(height: 20),

                    // Contact options heading
                     Text(
                      "choose_preferred_way".tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Nunito-Bold',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contact cards with compact design
                    _buildContactCard(
                      context,
                      icon: Icons.chat_bubble_rounded,
                      title: "whatsapp".tr,
                      description: "chat_whatsapp".tr,
                      color: const Color(0xFF25D366),
                      onTap: () async {
                        try {
                          await _launchWhatsApp();
                        } catch (e) {
                          _showErrorSnackBar(context, "WhatsApp not available");
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      context,
                      icon: Icons.email_rounded,
                      title: "email".tr,
                      description: "email_support".tr,
                      color: const Color(0xFF4285F4),
                      onTap: () async {
                        try {
                          await _launchEmail();
                        } catch (e) {
                          _showErrorSnackBar(context, "Email app not found");
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      context,
                      icon: Icons.phone_rounded,
                      title: "call_now".tr,
                      description: "call_support".tr,
                      color: const Color(0xFF8E24AA),
                      onTap: () async {
                        try {
                          await _launchCall();
                        } catch (e) {
                          _showErrorSnackBar(context, "Phone dialer not available");
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildContactDetailsBox(context),
                    const SizedBox(height: 24),
                    _buildSupportInfo(),
                    const SizedBox(height: 30),
                    
                    Center(
                      child: Column(
                        children: [
                           Text(
                            "we_here_help".tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E24AA),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito-Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "community_initiative".tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8E24AA).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              size: 40,
              color: Color(0xFF8E24AA),
            ),
          ),
        ),
        const SizedBox(height: 16),
         Text(
          "how_can_we_help".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Nunito-Bold',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "ready_assist".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Contact card widget - More premium card design
  Widget _buildContactCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Contact details box with copy functionality - Cleaned up
  Widget _buildContactDetailsBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "quick_reference".tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, Icons.phone_rounded, phoneNumber, "Number copied"),
          const SizedBox(height: 16),
          _buildInfoRow(context, Icons.email_rounded, email, "Email copied"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String value, String snackText) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(snackText),
                duration: const Duration(seconds: 1),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                width: 200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          child: Icon(Icons.copy_rounded, size: 18, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  // Support hours & tips - Enhanced aesthetic
  Widget _buildSupportInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                "support_availability".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBullet("whatsapp_email".tr, "active_24_7".tr),
          _buildInfoBullet("phone_lines", "phone_hours".tr),
          _buildInfoBullet("prioritized_support".tr, "Community-led initiative"),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: Colors.orange.shade700, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "include_details_tip".tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
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

  Widget _buildInfoBullet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}