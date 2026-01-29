import '../repository/dashboard_repository.dart';
import '../../data/model/banner_model.dart';

class GetBannersUseCase {
  final DashboardRepository repository;

  GetBannersUseCase({required this.repository});

  Future<BannerResponse> call() {
    return repository.getBanners();
  }
}
