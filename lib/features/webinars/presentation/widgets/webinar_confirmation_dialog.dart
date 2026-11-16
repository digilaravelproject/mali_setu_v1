import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/models/webinar_model.dart';
import '../pages/webinar_live_screen.dart';

class WebinarConfirmationDialog extends StatelessWidget {
  final Webinar webinar;

  const WebinarConfirmationDialog({
    super.key,
    required this.webinar,
  });

  static Future<void> show(BuildContext context, Webinar webinar) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => WebinarConfirmationDialog(webinar: webinar),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close top right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
                ),
              ),
            ),

            // Animated Success Icon with circular ripples
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const Text(
              "Registration Successful!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            const Text(
              "You have successfully registered for the webinar.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),

            // Mini Webinar Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: webinar.bannerUrl,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 55,
                        height: 55,
                        color: AppColors.primaryLight,
                        child: Icon(Icons.video_library_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          webinar.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar,
                              size: 11,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${webinar.dateString} • ${webinar.timeString.split('-').first.trim()}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Add to Calendar Button (Outline)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  CustomSnackBar.showSuccess(
                    message: "Event added to your device calendar!",
                  );
                },
                icon: const Icon(CupertinoIcons.calendar_badge_plus, size: 18),
                label: const Text(
                  "Add to Calendar",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Join Webinar Button (Primary filled)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.to(
                    () => WebinarLiveScreen(webinar: webinar),
                    transition: Transition.fadeIn,
                  );
                },
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20, color: Colors.white),
                label: const Text(
                  "Join Webinar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Footer info
            const Text(
              "You will also receive the meeting link on your email and in-app notifications.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

