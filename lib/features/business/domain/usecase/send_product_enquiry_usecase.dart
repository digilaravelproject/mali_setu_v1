import 'package:edu_cluezer/features/business/data/model/product_enquiry_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class SendProductEnquiryUseCase {
  final BusinessRepository repository;

  SendProductEnquiryUseCase({required this.repository});

  Future<ProductEnquiryResponse> call(ProductEnquiryRequest request) {
    return repository.sendProductEnquiry(request);
  }
}
