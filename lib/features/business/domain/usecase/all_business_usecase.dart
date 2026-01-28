import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';


class GetAllBusinessesUseCase {
  final BusinessRepository repository;

  GetAllBusinessesUseCase({required this.repository});

  Future<List<Business>> call() async {
    final response = await repository.getAllBusinesses();
    return response.data?.data ?? [];
  }
}
