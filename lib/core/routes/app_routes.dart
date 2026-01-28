import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:edu_cluezer/features/business/binding/business_binding.dart';
import 'package:edu_cluezer/features/business/presentation/page/add_product_screen.dart';
import 'package:edu_cluezer/features/business/presentation/page/add_service_page.dart';
import 'package:edu_cluezer/features/business/presentation/page/create_job_post_page.dart';
import 'package:edu_cluezer/features/business/presentation/page/job_analytics_screen.dart';
import 'package:edu_cluezer/features/business/presentation/page/job_details_screen.dart';
import 'package:edu_cluezer/features/business/presentation/page/my_business_screen.dart';
import 'package:edu_cluezer/features/matrimony/binding/match_binding.dart';
import 'package:edu_cluezer/features/matrimony/presentation/page/reg_matrimony_page.dart';
import 'package:edu_cluezer/features/settings/page/change_password_page.dart';
import 'package:edu_cluezer/features/settings/page/my_profile.dart';
import 'package:edu_cluezer/features/volunteer/binding/volunteerBinding.dart';
import 'package:edu_cluezer/features/volunteer/pages/volunteer_page.dart';
import 'package:edu_cluezer/features/volunteer/pages/volunteer_update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/Auth/login/binding/login_binding.dart';
import '../../features/Auth/login/presentation/page/login_page.dart';
import '../../features/Auth/login/presentation/page/reset_password_screen.dart';
import '../../features/Auth/register/binding/register_binding.dart';
import '../../features/Auth/register/presentation/page/register_page.dart';
import '../../features/_init/binding/init_binding.dart';
import '../../features/_init/presentation/page/splash_page.dart';
import '../../features/business/presentation/page/applied_job_list_screen.dart';
import '../../features/business/presentation/page/register_your_business_screen.dart';
import '../../features/business/presentation/page/single_business_details.dart';
import '../../features/dashboard/binding/dashboard_binding.dart';
import '../../features/dashboard/presentation/page/dashboard_page.dart';
import '../../features/date/binding/date_binding.dart';
import '../../features/date/presentation/page/date_profile_page.dart';
import '../../features/matrimony/presentation/page/matrimony_profile_screen.dart';
import '../../features/notification/binding/notification_binding.dart';
import '../../features/notification/presentation/page/notification_page.dart';
import '../../features/profile/binding/profile_binding.dart';
import '../../features/profile/presentation/page/edit_profile_page.dart';
import '../../features/dashboard/presentation/page/category_details_screen.dart';
import '../../features/search/binding/search_binding.dart';
import '../../features/search/presentation/page/search_page.dart';
import '../../features/settings/binding/profile_binding.dart';
import '../../features/settings/page/update_profile_page.dart';
import '../helper/logger_helper.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String intro = '/intro';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String dateProfile = '/dateProfile';
  static const String editProfile = '/editProfile';
  static const String notification = '/notification';
  static const String search = '/search';
  static const String regMatrimony = '/regMatrimony';
  static const String addProduct = '/addProduct';
  static const String addService = "/addService";
  static const String createJob = "/createJob";
  static const String jobAnalytics = "/jobAnalytics";
  static const String myBusiness = "/myBusiness";
  static const String regBusiness = "/regBusiness";
  static const String businessDetails = "/businessDetails";
  static const String jobDetails = "/jobDetails";
  static const String profileScreen = "/profileScreen";
  static const String updateProfile = "/update_Profile";
  static const String changePassword = "/changePassword";
  static const String volunteerProfile = "/volunteerProfile";
  static const String volunteerCreateProfile = "/volunteerCreateProfile";
  static const String appliedJobList = "/appliedJobList";
  static const String emailPasswordReset = "/emailPasswordReset";
  static const String resetPasswordScreen = "/resetPasswordScreen";
  static const String matrimonyProfileScreen = "/matrimonyProfileScreen";
  static const String categoryDetails = "/categoryDetails";
}

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
      binding: InitBinding(),
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    // GetPage(
    //   binding: InitBinding(),
    //   name: AppRoutes.intro,
    //   page: () => const IntroPage(),
    //   transition: Transition.cupertino,
    //   transitionDuration: const Duration(milliseconds: 500),
    // ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: AppRoutes.emailPasswordReset,
      page: () => const EmailResetPasswordScreen(),
      binding: LoginBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: AppRoutes.resetPasswordScreen,
      page: () => const ResetPasswordScreen(),
       binding: LoginBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      bindings: [DashboardBinding(), ProfileBinding(), MatrimonyBinding(), SettingsBinding(), BusinessBinding()],
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.dateProfile,
      page: () => const DateProfilePage(),
      binding: DateBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () =>  NotificationPage(),
      binding: NotificationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchPage(),
      binding: SearchBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.regMatrimony,
      page: () => const RegMatrimonyPage(),
      binding: MatrimonyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddProductScreen(),
      binding: MatrimonyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addService,
      page: () => const AddServiceScreen(),
      binding: MatrimonyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.createJob,
      page: () => const CreateJobPage(),
      binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.jobAnalytics,
      page: () => JobAnalysisPage(),
       binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.myBusiness,
      page: () => MyBusinessScreen(),
       binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.regBusiness,
      page: () => RegYourBusinessScreen(),
       binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.businessDetails,
      page: () => BusinessDetailScreen(),
       binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.jobDetails,
      page: () => JobDetailsScreen(),
       binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.profileScreen,
      page: () => ProfileScreen(),
       binding: BusinessBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.updateProfile,
      page: () => UpdateProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.volunteerProfile,
      page: () => VolunteerProfilePage(),
      binding: VolunteerBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.volunteerCreateProfile,
      page: () => CreateVolunteerScreen(),
      binding: VolunteerBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.appliedJobList,
      page: () => AppliedJobsScreen(),
     // binding: VolunteerBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.matrimonyProfileScreen,
      page: () => MatrimonyProfileScreen(profileId: '123',),
      // binding: VolunteerBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.categoryDetails,
      page: () => const CategoryDetailsScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  RouteSettings? redirect(String? route) {
    _linkSubscription = AppLinks().uriLinkStream.listen((url) {
      printMessage('onAppLink: $url');
    });

    return null;
  }

  @override
  void onPageDispose() {
    _linkSubscription?.cancel();
  }
}
