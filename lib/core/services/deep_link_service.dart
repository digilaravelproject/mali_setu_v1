import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../../features/blogs/presentation/screens/blog_detail_screen.dart';

class DeepLinkService extends GetxService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<DeepLinkService> init() async {
    // Handle link when app is in warm state (foreground or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Failed to handle app link: $err');
    });

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
    
    // Wait until the app navigates away from the splash screen
    while (Get.currentRoute == '/' || Get.currentRoute == '') {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    // Example: https://malisetu.com/blog/123
    if (uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.first == 'blog' && uri.pathSegments.length > 1) {
        final blogIdStr = uri.pathSegments[1];
        final blogId = int.tryParse(blogIdStr);
        if (blogId != null) {
          Get.to(() => BlogDetailScreen(blogId: blogId));
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
