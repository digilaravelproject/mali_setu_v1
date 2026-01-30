
import '../../data/model/res_all_volunteer_model.dart';
import '../repository/volunteer_repository.dart';

class VolunteerUseCase {
  final VolunteerRepository repository;

  VolunteerUseCase({required this.repository});

  Future<List<Volunteer>> call() async {
    return await repository.getAllVolunteers();
  }
}
