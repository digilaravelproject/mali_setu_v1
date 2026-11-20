import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../core/constent/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/shared_prefs.dart';
import '../../core/storage/token_manger.dart';
import '../../features/Auth/service/auth_service.dart';
import '../../features/blogs/presentation/screens/blog_detail_screen.dart';
import '../../features/blogs/presentation/screens/blogs_screen.dart';
import '../../features/business/data/model/res_all_business_model.dart';
import '../../features/webinars/data/models/webinar_model.dart';
import '../../features/matrimony/presentation/page/matrimony_profile_screen.dart';
import '../../features/matrimony/binding/matrimony_details_binding.dart';
import '../../features/Auth/register/presentation/controller/register_controller.dart';

class DeepLinkService extends GetxService {
  static bool isAppReady = false;
  static Uri? pendingDeepLinkUri;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  static bool get isUserLoggedIn {
    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      if (auth.isLoggedIn.value || auth.currentUser.value != null) {
        return true;
      }
    }
    if (SharedPrefs.getBool(AppConstants.isLoggedInPref) == true) {
      return true;
    }
    final token = SharedPrefs.getString(AppConstants.tokenPref);
    if (token != null && token.trim().isNotEmpty) {
      return true;
    }
    final userData = SharedPrefs.getString(AppConstants.userDataPref);
    if (userData != null && userData.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<bool> checkUserLoggedInAsync() async {
    if (isUserLoggedIn) return true;
    try {
      final token = await TokenManager.getToken();
      if (token.trim().isNotEmpty) return true;
    } catch (_) {}
    return false;
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

  static bool isRegisterUri(Uri uri) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.toLowerCase() == 'register') {
      return true;
    }
    if (uri.host.toLowerCase() == 'register') {
      return true;
    }
    return false;
  }

  static String? extractReferralCode(Uri uri) {
    final code = uri.queryParameters['referral_code'] ??
        uri.queryParameters['code'] ??
        uri.queryParameters['ref'] ??
        uri.queryParameters['referralCode'] ??
        uri.queryParameters['reffral_code'];
    return code?.trim();
  }

  static void navigateToRegister({String? referralCode}) {
    final code = referralCode?.trim();
    if (!isUserLoggedIn && code != null && code.isNotEmpty) {
      SharedPrefs.setString(AppConstants.pendingReferralCodePref, code);
    }

    void execute() async {
      if (Get.context == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => execute());
        return;
      }

      // If user is already logged in, do not open register page; open normally from splash
      final bool isLogged = await checkUserLoggedInAsync();
      if (isLogged) {
        print('DeepLinkService: User is already logged in, opening normally from splash.');
        Get.offAllNamed(AppRoutes.splash);
        return;
      }

      // If RegisterController is already in memory, update field and verify code immediately
      if (Get.isRegistered<RegisterController>()) {
        final regCtrl = Get.find<RegisterController>();
        if (code != null && code.isNotEmpty) {
          regCtrl.referralCtrl.text = code;
          regCtrl.fetchReferralUser(code);
        }
      }

      // If not currently on register page, navigate there with LoginPage as the base route
      if (Get.currentRoute != AppRoutes.register) {
        Get.offAllNamed(AppRoutes.login);
        Get.toNamed(
          AppRoutes.register,
          arguments: {
            if (code != null && code.isNotEmpty) 'referral_code': code,
          },
          preventDuplicates: false,
        );
      }
    }

    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      execute();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        execute();
      });
    }
  }

  static bool canHandleUri(Uri uri) {
    if (isRegisterUri(uri)) return true;
    if (uri.pathSegments.isEmpty) return false;
    final first = uri.pathSegments.first.toLowerCase();
    return first == 'blog' ||
        first == 'blogs' ||
        first == 'business' ||
        first == 'businesses' ||
        first == 'job' ||
        first == 'jobs' ||
        first == 'matrimony' ||
        first == 'webinar' ||
        first == 'webinars' ||
        first == 'register';
  }

  static String? _lastHandledUriString;
  static DateTime? _lastHandledTime;

  Future<void> _handleDeepLink(Uri uri) async {
    final String uriStr = uri.toString();
    final now = DateTime.now();
    if (_lastHandledUriString == uriStr &&
        _lastHandledTime != null &&
        now.difference(_lastHandledTime!).inMilliseconds < 1500) {
      print('DeepLinkService: Debouncing duplicate URI event within 1.5s: $uri');
      return;
    }
    _lastHandledUriString = uriStr;
    _lastHandledTime = now;

    print('DeepLinkService: Received URI: $uri');

    // If it's a register / referral link, store pending code immediately if user is not logged in
    if (isRegisterUri(uri)) {
      final refCode = extractReferralCode(uri);
      if (!isUserLoggedIn && refCode != null && refCode.isNotEmpty) {
        await SharedPrefs.setString(AppConstants.pendingReferralCodePref, refCode);
      }
    }

    // Check if we need to wait for app initialization (bounded timeout to prevent infinite wait)
    bool wasWaiting = false;
    int waitIterations = 0;
    while (!isAppReady && waitIterations < 50) {
      wasWaiting = true;
      waitIterations++;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!isAppReady) return;

    // If we had to wait (cold start), wait for screen transitions to complete
    if (wasWaiting) {
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      // Warm start: small delay to let active UI interactions settle
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Direct registration link with referral code:
    if (isRegisterUri(uri)) {
      final bool loggedIn = await checkUserLoggedInAsync();
      if (loggedIn) {
        print('DeepLinkService: User already logged in, opening normally through splash.');
        if (!wasWaiting) {
          // Warm start: reset to splash so app opens properly through splash
          Get.offAllNamed(AppRoutes.splash);
        } else {
          // Cold start: Splash is already playing naturally into dashboard
          if (Get.currentRoute == AppRoutes.login ||
              Get.currentRoute == AppRoutes.register) {
            Get.offAllNamed(AppRoutes.dashboard);
          }
        }
        return;
      }
      final refCode = extractReferralCode(uri);
      navigateToRegister(referralCode: refCode);
      return;
    }

    final firstSeg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first.toLowerCase() : '';

    // Public routes (blogs, business) can be viewed directly even if auth is still settling
    final bool isPublicRoute = firstSeg == 'blog' ||
        firstSeg == 'blogs' ||
        firstSeg == 'business' ||
        firstSeg == 'businesses';

    // If user is NOT logged in for a private route: Save pending deep link for after login
    if (!isUserLoggedIn && !isPublicRoute) {
      print('DeepLinkService: User NOT logged in for private route. Storing pending deep link: $uri');
      pendingDeepLinkUri = uri;
      return;
    }

    // Navigate directly to deep link destination
    navigateToUri(uri);
  }

  static void navigateToUri(Uri uri) {
    print('DeepLinkService: Navigating to URI: $uri');
    if (uri.pathSegments.isEmpty) return;

    void execute() async {
      if (Get.context == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => execute());
        return;
      }

      final firstSegment = uri.pathSegments.first.toLowerCase();
      if (firstSegment == 'blog' || firstSegment == 'blogs') {
        final int? blogId = uri.pathSegments.length > 1 ? int.tryParse(uri.pathSegments[1]) : null;
        if (blogId != null && blogId > 0) {
          Get.to(() => BlogDetailScreen(blogId: blogId), preventDuplicates: false);
        } else {
          Get.to(() => const BlogsScreen());
        }
      } else if (firstSegment == 'business' || firstSegment == 'businesses') {
        final int? businessId = uri.pathSegments.length > 1 ? int.tryParse(uri.pathSegments[1]) : null;
        if (businessId != null && businessId > 0) {
          Get.toNamed(
            AppRoutes.businessDetails,
            arguments: Business(id: businessId),
            preventDuplicates: false,
          );
        } else {
          Get.toNamed(AppRoutes.myBusiness);
        }
      } else if (firstSegment == 'job' || firstSegment == 'jobs') {
        final int? jobId = uri.pathSegments.length > 1 ? int.tryParse(uri.pathSegments[1]) : null;
        if (jobId != null && jobId > 0) {
          Get.toNamed(AppRoutes.jobDetails, arguments: Job(id: jobId), preventDuplicates: false);
        } else {
          Get.toNamed(AppRoutes.jobs);
        }
      } else if (firstSegment == 'matrimony') {
        int? profileId;
        for (final segment in uri.pathSegments) {
          final parsed = int.tryParse(segment);
          if (parsed != null && parsed > 0) {
            profileId = parsed;
            break;
          }
        }
        if (profileId != null && profileId > 0) {
          Get.to(
            () => MatrimonyProfileScreen(profileId: profileId),
            binding: MatrimonyDetailsBinding(),
            arguments: {'id': profileId},
            preventDuplicates: false,
          );
        } else {
          Get.toNamed(AppRoutes.matrimonyMembers);
        }
      } else if (firstSegment == 'webinar' || firstSegment == 'webinars') {
        final int? webinarId = uri.pathSegments.length > 1 ? int.tryParse(uri.pathSegments[1]) : null;
        if (webinarId != null && webinarId > 0) {
          Get.toNamed(AppRoutes.webinarDetails, arguments: Webinar.fromApiJson({'id': webinarId}), preventDuplicates: false);
        } else {
          Get.toNamed(AppRoutes.webinars);
        }
      } else if (firstSegment == 'register' || isRegisterUri(uri)) {
        final bool loggedIn = await checkUserLoggedInAsync();
        if (loggedIn) {
          print('DeepLinkService: User already logged in, opening normally through splash.');
          Get.offAllNamed(AppRoutes.splash);
          return;
        }
        final String? referralCode = extractReferralCode(uri);
        navigateToRegister(referralCode: referralCode);
      }
    }

    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      execute();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        execute();
      });
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
