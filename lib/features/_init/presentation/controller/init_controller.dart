import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../core/services/deep_link_service.dart';

class InitController extends GetxController
    implements GetTickerProviderStateMixin {
  var isLoading = true.obs;

  Future<void> startNavigate() async {
    bool isUpdateRequired = await _checkForUpdate();
    if (isUpdateRequired) {
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
    
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }

    // Wait for the transition to fully complete before unblocking DeepLinkService
    await Future.delayed(const Duration(milliseconds: 600));

    // Mark app as ready for deep link handling
    DeepLinkService.isAppReady = true;
  }

  Future<bool> _checkForUpdate() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('app-version');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final platformData = Platform.isIOS ? data['ios'] : data['android'];

        if (platformData != null) {
          final int apiBuildCode = platformData['build_code'] ?? 0;
          final String updateNotes = platformData['update_notes'] ?? '';
          final String storeUrl = platformData['store_url'] ?? '';

          final packageInfo = await PackageInfo.fromPlatform();
          final int currentBuildCode = int.tryParse(packageInfo.buildNumber) ?? 0;

          if (currentBuildCode < apiBuildCode) {
            _showUpdateDialog(updateNotes, storeUrl);
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking for update: $e");
    }
    return false;
  }

  void _showUpdateDialog(String updateNotes, String storeUrl) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "New Update Available",
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  updateNotes.isNotEmpty
                      ? updateNotes
                      : "Hey! We have released a new update. Kindly update the app for a smoother experience.",
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(storeUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Update Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}
}
