import 'package:edu_cluezer/features/volunteer/data/model/res_all_volunteer_model.dart';

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


  @override
  Future<List<Volunteer>> getAllVolunteers() async {
    final res = await dataSource.fetchAllVolunteers();
    return res.data?.volunteers ?? [];
  }

  @override
  Future<Volunteer?> getVolunteerOpportunity(int id) async {
    final res = await dataSource.getVolunteerOpportunity(id);
    return res.data;
  }

  @override
  Future<List<VolunteerSearchProfile>> searchVolunteers(String query, {int size = 20}) async {
    final res = await dataSource.searchVolunteers(query, size: size);
    return res.data?.data ?? [];
  }
}
