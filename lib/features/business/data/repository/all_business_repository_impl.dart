import '../../domain/repository/all_business_repository.dart';
import '../../data/data_source/all_business_data_source.dart';
import '../../data/model/res_all_business_model.dart';


class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessDataSource dataSource;

  BusinessRepositoryImpl({required this.dataSource});

  @override
  Future<BusinessResponse> getAllBusinesses() {
    return dataSource.getAllBusinesses();
  }
}