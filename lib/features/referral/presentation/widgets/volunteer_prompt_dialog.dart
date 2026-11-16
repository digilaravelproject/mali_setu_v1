import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../Auth/service/auth_service.dart';
import '../binding/referral_binding.dart';

class VolunteerPromptDialog extends StatelessWidget {
  final bool isVolunteer;
  final String currentUserType;

  const VolunteerPromptDialog({
    super.key,
    required this.isVolunteer,
    required this.currentUserType,
  });

  /// Tracks if the prompt has already been shown in the current app session
  static bool _hasShownInSession = false;

  /// Reset session flag (e.g. for testing or fresh login)
  static void resetSession() {
    _hasShownInSession = false;
  }

  /// Check user type from SharedPreferences and display the appropriate dialog on app open
  static Future<void> checkAndShow({BuildContext? context, bool force = false}) async {
    if (!force && _hasShownInSession) return;
    if (Get.isDialogOpen ?? false) return;

    // Only show if user is logged in
    final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
    if (!isLoggedIn) return;

    // Delay to ensure the UI transition is complete and overlay context is mounted
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!force && _hasShownInSession) return;
    if (Get.isDialogOpen ?? false) return;

    final userType = getUserTypeFromPrefs();
    final bool isVolunteer = userType.toLowerCase().trim() == 'volunteer';

    _hasShownInSession = true;

    // Close any lingering snackbars so they do not conflict with the dialog
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.dialog(
      VolunteerPromptDialog(
        isVolunteer: isVolunteer,
        currentUserType: userType,
      ),
      barrierDismissible: true,
    );
  }

  /// Robust helper to retrieve user_type directly from SharedPreferences
  static String getUserTypeFromPrefs() {
    // 1. Direct from SharedPreferences AppConstants.userTypePref
    final directPref = SharedPrefs.getString(AppConstants.userTypePref);
    if (directPref != null && directPref.trim().isNotEmpty) {
      return directPref.trim().toLowerCase();
    }

    // 2. Direct key "user_type"
    final rawPref = SharedPrefs.getString("user_type");
    if (rawPref != null && rawPref.trim().isNotEmpty) {
      return rawPref.trim().toLowerCase();
    }

    // 3. From saved user_data JSON in SharedPreferences
    final userJson = SharedPrefs.getString(AppConstants.userDataPref);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        final isVol = userMap['is_volunteer'];
        if (isVol == true || isVol == 1 || isVol == '1' || isVol == 'true') {
          return 'volunteer';
        }
        final type = userMap['user_type']?.toString().trim().toLowerCase();
        if (type != null && type.isNotEmpty) {
          return type;
        }
      } catch (_) {}
    }

    // 4. From AuthService current user
    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      final user = auth.currentUser.value;
      final type = user?.userType?.trim().toLowerCase();
      if (type != null && type.isNotEmpty) {
        return type;
      }
    }

    return 'general';
  }

  @override
  Widget build(BuildContext context) {
    if (isVolunteer) {
      return _buildVolunteerDialog(context);
    } else {
      return _buildNonVolunteerDialog(context);
    }
  }

  // --------------------------------------------------------------------------
  // 1. Dialog for Volunteer User ("user_type": "volunteer")
  // --------------------------------------------------------------------------
  Widget _buildVolunteerDialog(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Decorative Header with Centerpiece Icon
            SizedBox(
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Subtle Gradient Banner
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFECFDF5), Color(0xFFEFF6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Close Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),

                  // Centerpiece Glowing Volunteer Icon
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.military_tech_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge: Active Volunteer Member
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 5),
                        Text(
                          'ACTIVE VOLUNTEER',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    'volunteer_dialog_title'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'volunteer_dialog_desc'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Volunteer Highlights Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_tree_rounded,
                                  size: 16,
                                  color: Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'network_growth_tag'.tr,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monetization_on_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'higher_points_tag'.tr,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary Button: Check Your Analytics
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ReferralBinding.init();
                        Navigator.of(context).pop();
                        Get.toNamed(AppRoutes.referralAnalytics);
                      },
                      child: Ink(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC62D86), Color(0xFF8B185D)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC62D86).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'check_analytics_btn'.tr,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dismiss Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'maybe_later'.tr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 2. Dialog for Non-Volunteer User ("business", "matrimony", "general", etc.)
  // --------------------------------------------------------------------------
  Widget _buildNonVolunteerDialog(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Decorative Header with Centerpiece Icon
            SizedBox(
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Subtle Pastel Gradient Banner
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFF0F7), Color(0xFFFAF5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Close Button (Top Right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),

                  // Centerpiece Glowing Gift / Opportunity Icon
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC62D86).withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFC62D86), Color(0xFF9333EA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.volunteer_activism_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pill Badge: Exclusive Opportunity
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, size: 14, color: Color(0xFFEA580C)),
                        SizedBox(width: 5),
                        Text(
                          'SPECIAL INVITE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC2410C),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    'become_volunteer_title'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Note Card (Golden / Amber Sunset Benefit Card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFFD97706),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'become_volunteer_note'.tr,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF78350F),
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFFD97706)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'higher_points_tag'.tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.hub_rounded, size: 14, color: Color(0xFF9333EA)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'network_growth_tag'.tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Button 1: Register for Volunteer (Gradient & Elevation)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.of(context).pop();
                        VolunteerPromptDialog.resetSession();

                        // Logout current profile and navigate to register with volunteer pre-selected
                        if (Get.isRegistered<AuthService>()) {
                          final auth = Get.find<AuthService>();
                          await auth.logout(
                            redirectToRoute: AppRoutes.register,
                            arguments: {'user_type': 'volunteer'},
                          );
                        } else {
                          Get.offAllNamed(
                            AppRoutes.register,
                            arguments: {'user_type': 'volunteer'},
                          );
                        }
                      },
                      child: Ink(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC62D86), Color(0xFF8B185D)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC62D86).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'register_volunteer_btn'.tr,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Button 2: Check Analytics (Sleek Soft Tint)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ReferralBinding.init();
                        Navigator.of(context).pop();
                        Get.toNamed(AppRoutes.referralAnalytics);
                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insights_rounded, color: AppColors.primary, size: 19),
                            const SizedBox(width: 8),
                            Text(
                              'view_analytics_btn'.tr,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dismiss Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'maybe_later'.tr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
