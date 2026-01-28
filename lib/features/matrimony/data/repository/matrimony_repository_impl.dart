import '../../data/data_source/matrimony_data_source.dart';
import '../../data/model/matrimony_response.dart';
import '../../domain/repository/matrimony_repository.dart';

class MatrimonyRepositoryImpl implements MatrimonyRepository {
  final MatrimonyDataSource dataSource;

  MatrimonyRepositoryImpl({required this.dataSource});

  @override
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data) async {
    return await dataSource.createProfile(data);
  }

  @override
  Future<dynamic> getProfiles() async {
    return await dataSource.getProfiles();
  }
}
