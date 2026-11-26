import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../../Auth/login/data/model/res_login_model.dart';
import '../../../Auth/service/auth_service.dart';
import 'volunteer_prompt_dialog.dart';

class VolunteerConvertDialog extends StatefulWidget {
  final String currentUserType;

  const VolunteerConvertDialog({
    super.key,
    required this.currentUserType,
  });

  /// Static helper to show the dialog
  static Future<bool?> show(BuildContext context, {String? currentUserType}) async {
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentType = currentUserType ??
        authService?.currentUser.value?.userType ??
        VolunteerPromptDialog.getUserTypeFromPrefs();

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => VolunteerConvertDialog(
        currentUserType: currentType,
      ),
    );
  }

  @override
  State<VolunteerConvertDialog> createState() => _VolunteerConvertDialogState();
}

class _VolunteerConvertDialogState extends State<VolunteerConvertDialog> {
  bool _isConverting = false;

  String get _displayCurrentType {
    final type = widget.currentUserType.trim();
    if (type.isEmpty) return 'Member';
    return type.capitalizeFirst ?? type;
  }

  Future<void> _handleConvert() async {
    if (_isConverting) return;
    setState(() {
      _isConverting = true;
    });
    HapticFeedback.mediumImpact();

    try {
      final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final response = await apiClient.post(ApiConstants.volunteerConvert);

      debugPrint("📡 [VolunteerConvert] Response status: ${response.statusCode}");
      debugPrint("📡 [VolunteerConvert] Response data: ${response.data}");

      final dynamic resData = response.data;
      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (resData is Map &&
              (resData['success'] == true ||
                  resData['status'] == true ||
                  resData['status'] == 'success'));

      if (isSuccess) {
        // 1. Update SharedPreferences immediately
        await SharedPrefs.setString(AppConstants.userTypePref, 'volunteer');
        await SharedPrefs.setString('user_type', 'volunteer');

        // 2. Parse updated user data
        final Map<String, dynamic> dataMap = resData is Map<String, dynamic> ? resData : {};
        final dynamic innerData = dataMap['data'];
        final dynamic rawUser = innerData is Map ? (innerData['user'] ?? innerData) : dataMap['user'];

        if (rawUser != null && rawUser is Map<String, dynamic>) {
          try {
            final updatedUser = User.fromJson(rawUser);
            updatedUser.userType = 'volunteer';
            await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(updatedUser.toJson()),
            );

            if (Get.isRegistered<AuthService>()) {
              final auth = Get.find<AuthService>();
              auth.currentUser.value = updatedUser;
              auth.currentUser.refresh();
            }
          } catch (e) {
            debugPrint("⚠️ [VolunteerConvert] Error parsing user: $e");
          }
        } else {
          if (Get.isRegistered<AuthService>()) {
            final auth = Get.find<AuthService>();
            if (auth.currentUser.value != null) {
              auth.currentUser.value!.userType = 'volunteer';
              auth.currentUser.refresh();
              await SharedPrefs.setString(
                AppConstants.userDataPref,
                jsonEncode(auth.currentUser.value!.toJson()),
              );
            }
          }
        }

        // 3. Reset prompt session so UI reflects fresh state
        VolunteerPromptDialog.resetSession();

        // 4. Close dialog
        if (mounted) {
          Navigator.of(context).pop(true);
        }

        // 5. Success toast
        final String msg = dataMap['message']?.toString() ?? 'convert_success_msg'.tr;
        CustomSnackBar.showSuccess(message: msg);
      } else {
        final String errorMsg = (resData is Map ? resData['message']?.toString() : null) ??
            'Failed to convert account. Please try again.';
        CustomSnackBar.showError(message: errorMsg);
      }
    } catch (e) {
      debugPrint("❌ [VolunteerConvert] Error: $e");
      CustomSnackBar.showError(message: 'Something went wrong. Please check your connection.');
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Decorative Header with Icon
            SizedBox(
              height: 110,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient Banner
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
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
                      onTap: () {
                        if (!_isConverting) {
                          Navigator.of(context).pop(false);
                        }
                      },
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

                  // Centerpiece Volunteer Icon
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
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
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
                              colors: [Color(0xFF8B5CF6), Color(0xFFC026D3)],
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
                  // Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.autorenew_rounded, size: 14, color: Color(0xFF9333EA)),
                        SizedBox(width: 5),
                        Text(
                          'ACCOUNT UPGRADE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7E22CE),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    'convert_volunteer_title'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Transition Visual Card: [Current Type] ➔ [Volunteer]
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        // Left: Current Account Type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'current_account_type'.tr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _displayCurrentType.toUpperCase(),
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

                        // Center: Transition Arrow
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Color(0xFF7C3AED),
                          ),
                        ),

                        // Right: New Volunteer Type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'new_account_type'.tr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF047857),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.stars_rounded, size: 13, color: Color(0xFF059669)),
                                    SizedBox(width: 4),
                                    Text(
                                      'VOLUNTEER',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF047857),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Explanatory Note Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'convert_volunteer_desc'.trParams({'current': _displayCurrentType}),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF78350F),
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Button 1: Confirm & Convert (Gradient with Loading State)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isConverting ? null : _handleConvert,
                      child: Ink(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isConverting
                                ? [const Color(0xFF9CA3AF), const Color(0xFF6B7280)]
                                : [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isConverting
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isConverting) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Converting Account...',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ] else ...[
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'convert_volunteer_confirm_btn'.tr,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Button 2: Maybe Later / Cancel
                  GestureDetector(
                    onTap: () {
                      if (!_isConverting) {
                        Navigator.of(context).pop(false);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'maybe_later'.tr,
                        style: const TextStyle(
                          fontSize: 13,
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
