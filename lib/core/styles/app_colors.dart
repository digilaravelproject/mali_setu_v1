import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// ========================
  /// BRAND COLORS
  /// ========================

  static const Color primary = Color(0xFFC62D86);
  static const Color primaryDark = Color(0xFF720C48);
  static const Color primaryLight = Color(0xFFFFE2F2);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// ========================
  /// SECONDARY (HARMONIZED)
  /// ========================

  /// Derived from primary keeping warm & premium tone
  static const Color secondary = Color(0xFF3D5897);
  static const Color secondaryDark = Color(0xFF213052);
  static const Color secondaryLight = Color(0xFFEBF0FF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// ========================
  /// STATE COLORS
  /// ========================

  static const Color success = Color(0xFF2EC971);
  static const Color warning = Color(0xFFFFAB40);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  static const Color onSuccess = Colors.white;
  static const Color onWarning = Colors.white;
  static const Color onError = Colors.white;

  /// ========================
  /// COMMON COLORS
  /// ========================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  /// =================================================
  /// LIGHT MODE – Harmonized From Primary Color
  /// =================================================

  static const Color lightBackground = Color(0xFFFFFFFF);

  /// Slight pink tint
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightAppBar = Color(0xFFFFFFFF);

  static const Color lightTextPrimary = Color(0xFF1E1E1E);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color lightTextDisabled = Color(0xFF9E9E9E);

  static const Color lightDivider = Color(0xFFE2E2E2);
  static const Color lightBorder = Color(0xFFD9D9D9);

  static const Color lightIcon = Color(0xFF5F5F5F);
  static const Color lightIconBg = Color(0xFFF2F3F4);

  static const Color lightChipBg = Color(0xFFFFEDF4);
  static const Color lightShadow = Color(0x1A000000);

  static const Color lightPrimaryContainer = Color(0xFFFFC1D8);
  static const Color lightSecondaryContainer = Color(0xFFEBD3F5);

  static const Color lightShimmerBase = Color(0xFFE7E9EB);
  static const Color lightShimmerHighlight = Color(0xFFF7F8F9);

  static List<Color> lightGradientPrimary = [
    Color(0xFFE63D73),
    Color(0xFFC6285D),
  ];

  static List<Color> borderGradient = [
    primary,
    secondary,
  ];

  static List<Color> lightBackgroundGradient = [
    Color(0xFFFFF1F7),
    Color(0xFFFFF7FA),
    Color(0xFFFFFAFD),
  ];

  /// =================================================
  /// DARK MODE – Harmonized From Primary Color
  /// =================================================
  static const Color darkBackground = Color(0xFF330133);

  /// main base
  static const Color darkSurface = Color(0xFF3E0B3E);

  /// slightly brighter
  static const Color darkCard = Color(0xFF4A154A);

  /// elevated surface
  static const Color darkAppBar = Color(0xFF5A0F5A);

  /// ------------ TEXT ------------
  static const Color darkTextPrimary = Color(0xFFF2E6F2);
  static const Color darkTextSecondary = Color(0xFFBFA3BF);
  static const Color darkTextDisabled = Color(0xFF7A5A7A);

  /// ------------ UI ELEMENTS ------------
  static const Color darkDivider = Color(0xFF5A3A5A);
  static const Color darkBorder = Color(0xFF4D2F4D);

  static const Color darkIcon = Color(0xFFE8D3E8);

  /// ------------ SMALL ELEMENTS ------------
  static const Color darkChipBg = Color(0xFF3A143A);
  static const Color darkShadow = Color(0xC3989898);

  /// ------------ CONTAINERS (Primary / Secondary) ------------
  static const Color darkPrimaryContainer = Color(0xFF721A72);
  static const Color darkSecondaryContainer = Color(0xFF492049);

  /// ------------ SHIMMER EFFECT ------------
  static const Color darkShimmerBase = Color(0xFF2B0F2B);
  static const Color darkShimmerHighlight = Color(0xFF3D143D);

  /// ------------ GRADIENTS ------------
  static List<Color> darkGradientPrimary = [
    Color(0xFF721A72),
    Color(0xFF4A0F4A),
  ];

  static List<Color> darkBackgroundGradient = [
    Color(0xFF2B022B),
    Color(0xFF240124),
    Color(0xFF1A001A),
  ];

  /// ========================
  /// SPECIAL UI COLORS
  /// ========================

  static const Color saleTag = Color(0xFFE73956);
  static const Color discountBadge = Color(0xFF35A853);
  static const Color flashSale = Color(0xFFFF8C00);

  static const Color ratingActive = Color(0xFFFFC107);
  static const Color ratingInactive = Color(0xFFBDBDBD);

  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonPressed = Color(0xFFD82F66);
}

class AppGradients {
  static LinearGradient primaryLight = LinearGradient(
    colors: AppColors.lightGradientPrimary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient primaryDark = LinearGradient(
    colors: AppColors.darkGradientPrimary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundLight = LinearGradient(
    colors: AppColors.lightBackgroundGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient backgroundDark = LinearGradient(
    colors: AppColors.darkBackgroundGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return isDarkMode ? primaryDark : primaryLight;
  }

  static LinearGradient getBackgroundGradient(bool isDarkMode) {
    return isDarkMode ? backgroundDark : backgroundLight;
  }
}
