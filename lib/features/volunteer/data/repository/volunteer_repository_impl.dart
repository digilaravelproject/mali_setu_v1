import '../../domain/repository/volunteer_repository.dart';
import '../data_source/volunteer_data_source.dart';
import '../model/volunteer_profile_model.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {
  final VolunteerDataSource dataSource;

  VolunteerRepositoryImpl({required this.dataSource});

  @override
  Future<VolunteerProfileResponse> getVolunteerProfile() {
    return dataSource.getVolunteerProfile();
  }

  @override
  Future<VolunteerProfileResponse> createVolunteerProfile(Map<String, dynamic> data) {
    return dataSource.createVolunteerProfile(data);
  }

  @override
  Future<VolunteerProfileResponse> updateVolunteerProfile(Map<String, dynamic> data) {
    return dataSource.updateVolunteerProfile(data);
  }
}
