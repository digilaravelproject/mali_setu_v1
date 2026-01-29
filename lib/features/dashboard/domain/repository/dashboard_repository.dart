import '../../data/model/banner_model.dart';

abstract class DashboardRepository {
  Future<BannerResponse> getBanners();
}
