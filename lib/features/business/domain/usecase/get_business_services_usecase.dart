import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class GetBusinessServicesUseCase {
  final BusinessRepository repository;

  GetBusinessServicesUseCase({required this.repository});

  Future<List<Service>> call(int businessId) async {
    final response = await repository.getBusinessServices(businessId);
    return response.data?.services ?? [];
  }
}
