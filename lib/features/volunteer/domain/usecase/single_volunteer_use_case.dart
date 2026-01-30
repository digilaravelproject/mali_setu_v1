import '../../data/model/res_all_volunteer_model.dart';
import '../repository/volunteer_repository.dart';

class SingleVolunteerUseCase {
  final VolunteerRepository repository;

  SingleVolunteerUseCase({required this.repository});

  Future<Volunteer?> call(int id) async {
    return await repository.getVolunteerOpportunity(id);
  }
}
