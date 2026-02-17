import 'package:get/get.dart';
import '../controller/transaction_history_controller.dart';
import '../../razorpay/payment_repository.dart';

class TransactionHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentRepository());
    Get.lazyPut(() => TransactionHistoryController());
  }
}
