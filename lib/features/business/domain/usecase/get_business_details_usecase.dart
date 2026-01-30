import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetBusinessDetailsUseCase {
  final BusinessRepository repository;

  GetBusinessDetailsUseCase({required this.repository});

  Future<Business?> call(int id) async {
    final response = await repository.getBusinessDetails(id);
    if (response.data?.data != null && response.data!.data!.isNotEmpty) {
      return response.data!.data!.first;
    }
    return null;
  }
}
