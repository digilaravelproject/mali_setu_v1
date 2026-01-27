
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../core/helper/country_list_picker.dart';
import '../../../../core/helper/logger_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/data_source/login_data_source.dart';
import '../page/otp_verification_bts.dart';

class ResetPasswordController extends GetxController
    implements GetTickerProviderStateMixin {
  LoginDataSource dataSource;

  ResetPasswordController({required this.dataSource});

  var mobileController = TextEditingController();
  var passwordController = TextEditingController();

 // var isRemember = true.obs;
  var isPasswordVisible = true.obs;
  //var selectedPhone = countries.where((p) => p.dialCode == "91").first.obs;

  var countryController = TextEditingController();
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    _initCountry();
    super.onInit();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}



  Future<void> performLogin() async {
    try {

    } catch (e, stk) {
      CustomSnackBar.showError(message: e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }

  void _initCountry() {}
}