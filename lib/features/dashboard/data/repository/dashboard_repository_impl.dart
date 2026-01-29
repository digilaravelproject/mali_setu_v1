import '../../domain/repository/dashboard_repository.dart';
import '../data_source/dashboard_data_source.dart';
import '../model/banner_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource dataSource;

  DashboardRepositoryImpl({required this.dataSource});

  @override
  Future<BannerResponse> getBanners() {
    return dataSource.getBanners();
  }
}
