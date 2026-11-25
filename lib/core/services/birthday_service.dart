import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../features/Auth/service/auth_service.dart';
import '../storage/shared_prefs.dart';
import '../widgets/birthday_celebration_dialog.dart';

class BirthdayService {
  BirthdayService._();

  static bool _hasCheckedThisSession = false;

  /// Checks if current logged-in user has their birthday today,
  /// and if this is the first time the app is opened on this day,
  /// triggers a celebration animation dialog.
  static Future<void> checkAndShowBirthdayWish({bool forceCheck = false}) async {
    try {
      if (_hasCheckedThisSession && !forceCheck) return;

      if (!Get.isRegistered<AuthService>()) return;
      final authService = Get.find<AuthService>();
      final user = authService.currentUser.value;
      if (user == null) return;

      final dobStr = user.dob?.trim();
      if (dobStr == null || dobStr.isEmpty) {
        debugPrint("[BirthdayService] User has no DOB registered.");
        return;
      }

      final dobDate = parseDob(dobStr);
      if (dobDate == null) {
        debugPrint("[BirthdayService] Could not parse DOB: '$dobStr'");
        return;
      }

      final now = DateTime.now();
      final isBirthdayToday = dobDate.month == now.month && dobDate.day == now.day;

      debugPrint("[BirthdayService] User: ${user.name}, DOB: $dobDate, Today: $now, IsBirthday: $isBirthdayToday");

      if (!isBirthdayToday) return;

      // Key specific to this user and today's date
      final userId = user.id ?? user.phone ?? user.email ?? '0';
      final todayKey = "birthday_wished_${userId}_${now.year}_${now.month}_${now.day}";

      final alreadyWished = SharedPrefs.getBool(todayKey) ?? false;
      if (alreadyWished && !forceCheck) {
        debugPrint("[BirthdayService] Birthday wish already shown today for user $userId.");
        return;
      }

      _hasCheckedThisSession = true;
      await SharedPrefs.setBool(todayKey, true);

      // Delay slightly so that the home screen / dashboard transition is complete
      Future.delayed(const Duration(milliseconds: 800), () {
        if (Get.context != null && !(Get.isDialogOpen ?? false)) {
          BirthdayCelebrationDialog.show(user);
        }
      });
    } catch (e) {
      debugPrint("[BirthdayService] Error checking birthday: $e");
    }
  }

  /// Robust date of birth parser handling various date formats:
  /// - YYYY-MM-DD
  /// - YYYY-MM-DD HH:mm:ss
  /// - ISO8601 (YYYY-MM-DDTHH:mm:ssZ)
  /// - DD/MM/YYYY or DD-MM-YYYY
  /// - YYYY/MM/DD
  static DateTime? parseDob(String? dobStr) {
    if (dobStr == null || dobStr.trim().isEmpty) return null;
    final trimmed = dobStr.trim();

    // 1. Standard ISO / YYYY-MM-DD parse
    final parsedIso = DateTime.tryParse(trimmed);
    if (parsedIso != null) return parsedIso;

    // 2. Custom delimiter parse (/ or -)
    final delimiter = trimmed.contains('/') ? '/' : (trimmed.contains('-') ? '-' : null);
    if (delimiter != null) {
      final parts = trimmed.split(delimiter);
      if (parts.length >= 3) {
        // Case: YYYY-MM-DD or YYYY/MM/DD
        if (parts[0].length == 4) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2].split(' ')[0]);
          if (year != null && month != null && day != null) {
            return DateTime(year, month, day);
          }
        } else {
          // Case: DD/MM/YYYY or DD-MM-YYYY
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2].split(' ')[0]);
          if (year != null && month != null && day != null) {
            return DateTime(year, month, day);
          }
        }
      }
    }

    return null;
  }
}
