import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import '../../core/constent/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/shared_prefs.dart';
import '../../features/Auth/service/auth_service.dart';
import '../../features/blogs/presentation/screens/blog_detail_screen.dart';
import '../../features/business/data/model/res_all_business_model.dart';

class DeepLinkService extends GetxService {
  static bool isAppReady = false;
  static Uri? pendingDeepLinkUri;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  static bool get isUserLoggedIn {
    if (Get.isRegistered<AuthService>()) {
      return Get.find<AuthService>().isLoggedIn.value;
    }
    return SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
  }

  static bool get hasPendingDeepLink => pendingDeepLinkUri != null;

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

    // If we had to wait (cold start), wait for screen transitions to complete
    if (wasWaiting) {
      await Future.delayed(const Duration(milliseconds: 1000));
    } else {
      // Warm start: small delay to let active UI interactions settle
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // If user is NOT logged in: Save pending deep link and do NOT open blog/business.
    // Let the app stay on its normal first screen (Language Selection).
    // User will choose language, go to login, and after login the pending deep link will open.
    if (!isUserLoggedIn) {
      print('DeepLinkService: User NOT logged in. Storing pending deep link: $uri');
      pendingDeepLinkUri = uri;
      return;
    }

    // If user IS logged in: Navigate directly to deep link destination
    navigateToUri(uri);
  }

  static void navigateToUri(Uri uri) {
    print('DeepLinkService: Navigating to URI: $uri');
    if (uri.pathSegments.isNotEmpty) {
      final firstSegment = uri.pathSegments.first.toLowerCase();
      if (firstSegment == 'blog' && uri.pathSegments.length > 1) {
        final blogIdStr = uri.pathSegments[1];
        final blogId = int.tryParse(blogIdStr);
        if (blogId != null) {
          Get.to(() => BlogDetailScreen(blogId: blogId));
        }
      } else if (firstSegment == 'business' && uri.pathSegments.length > 1) {
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

  static void executePendingDeepLink() {
    final uri = pendingDeepLinkUri;
    pendingDeepLinkUri = null;
    if (uri != null) {
      print('DeepLinkService: Executing pending deep link after login: $uri');
      Future.delayed(const Duration(milliseconds: 400), () {
        navigateToUri(uri);
      });
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
