import 'package:get/get.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../razorpay/payment_repository.dart';
import '../../razorpay/transaction_model.dart';

class TransactionHistoryController extends GetxController {
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var transactions = <TransactionItem>[].obs;
  
  int currentPage = 1;
  int lastPage = 1;
  bool hasNextPage = false;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      transactions.clear();
      isLoading.value = true;
    } else {
      if (currentPage == 1) {
        isLoading.value = true;
      } else {
        isMoreLoading.value = true;
      }
    }

    try {
      final response = await _paymentRepository.getTransactions(page: currentPage);
      
      if (response.success && response.data != null) {
        final data = response.data!.data;
        if (data != null) {
          if (refresh) {
            transactions.assignAll(data.data ?? []);
          } else {
            transactions.addAll(data.data ?? []);
          }
          
          currentPage = (data.currentPage ?? 0) + 1;
          lastPage = data.lastPage ?? 1;
          hasNextPage = data.nextPageUrl != null;
        }
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to fetch transactions");
      }
    } catch (e) {
      print("Error in TransactionHistoryController: $e");
      CustomSnackBar.showError(message: "An error occurred while fetching transactions");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void loadMore() {
    if (!isMoreLoading.value && hasNextPage) {
      fetchTransactions();
    }
  }
}
