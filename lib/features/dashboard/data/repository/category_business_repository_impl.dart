import '../../domain/repository/category_business_repository.dart';
import '../data_source/category_business_data_source.dart';
import '../model/res_category_business_model.dart';

class CatBusinessRepositoryImpl implements CatBusinessRepository {
  final CatBusinessDataSource dataSource;

  CatBusinessRepositoryImpl({required this.dataSource});

  @override
  Future<ResBusinessCategoryModel> getBusinessByCategory(int categoryId, {double? lat, double? long}) {
    return dataSource.getBusinessByCategory(categoryId, lat: lat, long: long);
  }
}