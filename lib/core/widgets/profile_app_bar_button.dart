import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';

class ProfileAppBarButton extends StatelessWidget {
  final double size;

  const ProfileAppBarButton({
    super.key,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
      final user = authService?.currentUser.value;
      final profileImg = user?.profileImage;

      return InkWell(
        onTap: () => Get.toNamed(AppRoutes.settings),
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: (profileImg != null && profileImg.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: profileImg.startsWith('http')
                        ? profileImg
                        : "${ApiConstants.imageBaseUrl}$profileImg",
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.grey,
                      size: size * 0.58,
                    ),
                  )
                : Icon(
                    CupertinoIcons.person_fill,
                    color: Colors.grey,
                    size: size * 0.58,
                  ),
          ),
        ),
      );
    });
  }
}

