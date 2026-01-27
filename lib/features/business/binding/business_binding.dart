import 'package:edu_cluezer/features/business/presentation/controller/create_job_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/page/create_job_post_page.dart';
import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:get/get.dart';



class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => MatrimonyController());
    // Get.lazyPut(() => FilterController(), fenix: true);
    Get.lazyPut(() => CreateJobController());
    Get.lazyPut(() => RegBusinessController());
  }
}
