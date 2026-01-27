import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxDouble progress = 0.7.obs;

  /// update progress with animation support
  void setProgress(double value) {
    progress.value = value.clamp(0.0, 1.0);
  }
}
