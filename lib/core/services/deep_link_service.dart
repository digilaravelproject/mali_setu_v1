import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import "../../core/routes/app_routes.dart";
import '../../features/blogs/presentation/screens/blog_detail_screen.dart';
import '../../features/business/data/model/res_all_business_model.dart';

class DeepLinkService extends GetxService {
  static bool isAppReady = false;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<DeepLinkService> init() async {
    // Handle link when app is in warm state (foreground or background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Failed to handle app link: $err');
      },
    );

    // Check initial link if app was in cold state (terminated)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Failed to get initial app link: $e');
    }

    return this;
  }

  Future<void> _handleDeepLink(Uri uri) async {
    print('DeepLinkService: Received URI: $uri');

    // Check if we need to wait for app initialization
    bool wasWaiting = false;
    while (!isAppReady) {
      wasWaiting = true;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // If we had to wait (cold start), the splash screen is transitioning to dashboard.
    // The transition takes 500ms, so we must wait longer than that to prevent the 
    // dashboard route from replacing our deep link route due to a race condition.
    if (wasWaiting) {
      await Future.delayed(const Duration(milliseconds: 1000));
    } else {
      // Warm start: just a tiny delay to ensure any active UI interactions settle
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Example: https://malisetu.com/blog/123
    if (uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.first == 'blog' && uri.pathSegments.length > 1) {
        final blogIdStr = uri.pathSegments[1];
        final blogId = int.tryParse(blogIdStr);
        if (blogId != null) {
          Get.to(() => BlogDetailScreen(blogId: blogId));
        }
      } else if (uri.pathSegments.first == 'business' &&
          uri.pathSegments.length > 1) {
        final businessIdStr = uri.pathSegments[1];
        final businessId = int.tryParse(businessIdStr);
        if (businessId != null) {
          Get.toNamed(
            AppRoutes.businessDetails,
            arguments: Business(id: businessId),
          );
        }
      }
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
