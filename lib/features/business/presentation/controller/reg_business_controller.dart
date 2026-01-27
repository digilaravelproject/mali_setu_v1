import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class RegBusinessController extends GetxController {
  /// Text Controllers
  final bNameCtrl = TextEditingController();
  final bTypeCtrl = TextEditingController();
  final bCategoryCtrl = TextEditingController();
  final bDescCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();

  /// Dropdown Data

  final businessTypes = ["Product Business", "Service Business", "Both Product & Business"];
  final businessCategories = ["HealthCare", "Beauty"];


  void onRegister() {
    // Validate & Submit
  }


}


