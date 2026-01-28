import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';


class GetMyBusinessesUseCase {
  final BusinessRepository repository;

  GetMyBusinessesUseCase({required this.repository});

  Future<List<Business>> call() async {
    final response = await repository.getMyBusinesses();
    return response.data?.data ?? [];
  }
}
