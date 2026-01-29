import '../../data/model/volunteer_profile_model.dart';

abstract class VolunteerRepository {
  Future<VolunteerProfileResponse> getVolunteerProfile();
  Future<VolunteerProfileResponse> createVolunteerProfile(Map<String, dynamic> data);
  Future<VolunteerProfileResponse> updateVolunteerProfile(Map<String, dynamic> data);
}
