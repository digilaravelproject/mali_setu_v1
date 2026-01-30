import 'package:edu_cluezer/features/volunteer/data/model/res_all_volunteer_model.dart';

import '../../data/model/volunteer_profile_model.dart';

abstract class VolunteerRepository {
  Future<VolunteerProfileResponse> getVolunteerProfile();
  Future<VolunteerProfileResponse> createVolunteerProfile(Map<String, dynamic> data);
  Future<VolunteerProfileResponse> updateVolunteerProfile(Map<String, dynamic> data);
  Future<List<Volunteer>> getAllVolunteers();
  Future<Volunteer?> getVolunteerOpportunity(int id);
}
