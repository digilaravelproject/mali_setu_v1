import 'package:edu_cluezer/features/dashboard/data/model/btm_nav_model.dart';
import 'package:edu_cluezer/features/dashboard/presentation/page/more_page.dart';
import 'package:edu_cluezer/features/matrimony/presentation/page/matrimony_page.dart';
import 'package:edu_cluezer/features/volunteer/pages/volunteer_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../business/presentation/page/business_page.dart';
import '../../../settings/page/settings_screen.dart';
import '../page/home_page.dart';

class DashboardController extends GetxController {
  var currentPage = 0.obs;

  var pageController = PageController();

  var screenList = <Widget>[
    HomePage(),
    //BusinessPage(),
    BusinessScreen(),
    MatrimonyPage(),
    VolunteerPage(),
    SettingsScreen()
 //   MorePage(),
  ];

  changePage(int index) {
    pageController.jumpToPage(index);
  }

  List<BtmNavModel> navList(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return [
      BtmNavModel(
        title: "Home",
        icon: CupertinoIcons.home,
        selectedIcon: CupertinoIcons.house_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "Business",
        icon: Icons.shop_outlined,
        selectedIcon: Icons.shop,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "Matrimony",
        icon: CupertinoIcons.heart,
        selectedIcon: CupertinoIcons.heart_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "Volunteer",
        icon: CupertinoIcons.person_2,
        selectedIcon: CupertinoIcons.person_2_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "More",
        icon: Icons.more_vert,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
    ];
  }
}
