import 'package:edu_cluezer/core/helper/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/data_source/init_data_source.dart';
import '../../data/model/intro_item_model.dart';

class IntroController extends GetxController {
  final InitDataSource dataSource;

  IntroController({required this.dataSource});

  final pageController = PageController();
  final currentPage = 0.obs;

  var isLoading = false.obs;

  final introItems = <IntroScreenModel>[].obs;

  @override
  void onInit() {
    _initController();
    _loadApi();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _initController() {
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  _loadApi() async {
    try {
      isLoading.value = true;
      var list = await dataSource.getIntroScreens();
      introItems.assignAll(list);
    } catch (e, stk) {
      printMessage("Exception $e, $stk");
    } finally {
      isLoading.value = false;
    }
  }
}
