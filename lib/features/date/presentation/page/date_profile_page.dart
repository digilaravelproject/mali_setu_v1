import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:edu_cluezer/features/date/presentation/controller/date_profile_controller.dart';
import 'package:edu_cluezer/widgets/app_image_slider.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_confirm_dialog.dart';

class DateProfilePage extends GetWidget<DateProfileController> {
  const DateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "Sarah, 24",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.theme.colorScheme.primary,
                  context.theme.colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.colorScheme.onPrimary,
                ),
                child: Icon(
                  CupertinoIcons.arrow_down,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ),
          ).marginOnly(right: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slider
            Container(
              decoration: AppDecorations.cardDecoration(context),
              height: Get.height * 0.5,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: ImageSlider(
                itemPadding: EdgeInsets.zero,
                viewPort: 1,
                isIndicatorVisible: true,
                borderRadius: 12,
                autoScroll: false,
                indicatorType: IndicatorType.story,
                images: [
                  "https://img.freepik.com/premium-photo/beautiful-indian-woman-generation-z-relaxing-feeling-nature-autumn-park-fall-season_230311-49384.jpg",
                  "https://img.freepik.com/premium-photo/beautiful-girl-white-pants-black-sweater-posing-against-background-flowers_502065-565.jpg",
                  "https://img.freepik.com/premium-photo/portrait-close-up-young-beautiful-woman-background-autumn-park_1024630-7139.jpg",
                ],
              ),
            ),
            SizedBox(height: 16),

            // Personal Details Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personal Details",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(context, Icons.height, "Height", "5'6\""),
                  _buildDetailRow(
                    context,
                    Icons.monitor_weight,
                    "Weight",
                    "58 kg",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.location_on,
                    "Location",
                    "Mumbai, India",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.school,
                    "Education",
                    "Masters Degree",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.work,
                    "Profession",
                    "Marketing Manager",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.language,
                    "Languages",
                    "English, Hindi, Marathi",
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Interests Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Interests",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInterestChip(
                        context,
                        "Photography",
                        Icons.camera_alt,
                      ),
                      _buildInterestChip(
                        context,
                        "Yoga",
                        Icons.self_improvement,
                      ),
                      _buildInterestChip(context, "Cooking", Icons.restaurant),
                      _buildInterestChip(context, "Dancing", Icons.music_note),
                      _buildInterestChip(context, "Painting", Icons.brush),
                      _buildInterestChip(context, "Hiking", Icons.hiking),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // About Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "About Me",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Adventure seeker with a passion for life! I love exploring new places, trying exotic cuisines, and meeting interesting people. When I'm not working, you'll find me at a yoga class, painting in my studio, or planning my next travel adventure. Looking for someone who shares my zest for life and isn't afraid to try new things!",
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Travel Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flight_takeoff,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Travel",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInfoTile(
                    context,
                    "Favorite Destination",
                    "Santorini, Greece",
                  ),
                  _buildInfoTile(context, "Dream Trip", "Safari in Kenya"),
                  _buildInfoTile(
                    context,
                    "Travel Style",
                    "Backpacking & Adventure",
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Books Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Books",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInfoTile(context, "Currently Reading", "Atomic Habits"),
                  _buildInfoTile(
                    context,
                    "Favorite Genre",
                    "Fiction & Self-help",
                  ),
                  _buildInfoTile(context, "Favorite Author", "Paulo Coelho"),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Music Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Music",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMusicChip(context, "Indie Pop"),
                      _buildMusicChip(context, "Bollywood"),
                      _buildMusicChip(context, "Jazz"),
                      _buildMusicChip(context, "Classical"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            /// Movies Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.movie,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Movies & TV",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildInfoTile(
                    context,
                    "Favorite Genre",
                    "Rom-com & Thriller",
                  ),
                  _buildInfoTile(context, "Latest Watch", "Barbie"),
                  _buildInfoTile(
                    context,
                    "Binge Watching",
                    "Friends (for the 5th time!)",
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Lifestyle Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.spa,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Lifestyle",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.fitness_center,
                    "Workout",
                    "4 times a week",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.local_dining,
                    "Diet",
                    "Vegetarian",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.smoking_rooms,
                    "Smoking",
                    "Never",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.local_bar,
                    "Drinking",
                    "Socially",
                  ),
                  _buildDetailRow(context, Icons.pets, "Pets", "Love dogs!"),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Basics Section
            Container(
              decoration: AppDecorations.cardDecoration(context),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Basics",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.favorite,
                    "Looking For",
                    "Long-term relationship",
                  ),
                  _buildDetailRow(
                    context,
                    Icons.family_restroom,
                    "Family Plans",
                    "Someday",
                  ),
                  _buildDetailRow(context, Icons.star, "Star Sign", "Leo"),
                  _buildDetailRow(
                    context,
                    Icons.psychology,
                    "Personality",
                    "ENFJ",
                  ),
                  _buildDetailRow(context, Icons.verified, "Verified", "Yes"),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Action Buttons (Block & Report)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Block functionality
                        CustomConfirmDialog.show(
                          title: "Block User",
                          message: "Are you sure you want to block this user?",
                          confirmText: "Block",
                          confirmColor: Colors.red,
                          icon: Icons.block_flipped,
                          onConfirm: () {
                            // Logic to block
                          },
                        );
                      },
                      icon: Icon(Icons.block, size: 18),
                      label: Text("Block"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Report functionality
                        CustomConfirmDialog.show(
                          title: "Report User",
                          message: "Are you sure you want to report this user for inappropriate behavior?",
                          confirmText: "Report",
                          confirmColor: Colors.orange,
                          icon: Icons.flag_outlined,
                          onConfirm: () {
                            // Logic to report
                          },
                        );
                      },
                      icon: Icon(Icons.flag, size: 18),
                      label: Text("Report"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButtons(
                    context,
                    icon: Icons.close,
                    size: 45,
                    color: Colors.red,
                    onTap: controller.onCloseTap,
                    isSelected: controller.isCloseSelected.value,
                  ),
                  _buildActionButtons(
                    context,
                    icon: Icons.star_rounded,
                    size: 60,
                    onTap: controller.onStarTap,
                    isSelected: controller.isStarSelected.value,
                  ),
                  _buildActionButtons(
                    context,
                    icon: CupertinoIcons.heart_fill,
                    size: 45,
                    color: Colors.deepPurpleAccent,
                    onTap: controller.onHeartTap,
                    isSelected: controller.isHeartSelected.value,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: context.theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          SizedBox(width: 12),
          Text(
            "$label:",
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.colorScheme.primary.withValues(alpha: 0.2),
            context.theme.colorScheme.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.theme.colorScheme.primary),
          SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicChip(BuildContext context, String label) {
    return Chip(
      label: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: context.theme.colorScheme.secondaryContainer,
      side: BorderSide.none,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    VoidCallback? onTap,
    required IconData icon,
    double size = 40,
    Color color = Colors.yellow,
    bool isSelected = false,
  }) {
    return IconButton(
      onPressed: onTap,
      constraints: BoxConstraints(minHeight: size, minWidth: size),
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.transparent,
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
      icon: Icon(
        icon,
        color: isSelected ? context.theme.colorScheme.onPrimary : color,
        size: size - 16,
      ),
    );
  }
}
