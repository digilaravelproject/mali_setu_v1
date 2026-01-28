import '../../data/model/matrimony_response.dart';

abstract class MatrimonyRepository {
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data);
  Future<dynamic> getProfiles();
}
