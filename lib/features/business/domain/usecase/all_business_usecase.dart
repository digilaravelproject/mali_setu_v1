import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class BusinessPaginationResult {
  final List<Business> businesses;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final int total;

  BusinessPaginationResult({
    required this.businesses,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
    required this.total,
  });
}

class GetAllBusinessesUseCase {
  final BusinessRepository repository;

  GetAllBusinessesUseCase({required this.repository});

  Future<BusinessPaginationResult> call({int page = 1}) async {
    final response = await repository.getAllBusinesses(page: page);
    
    final businesses = response.data?.data ?? [];
    final currentPage = response.data?.currentPage ?? 1;
    final lastPage = response.data?.lastPage ?? 1;
    final total = response.data?.total ?? 0;
    final hasNextPage = currentPage < lastPage;
    
    return BusinessPaginationResult(
      businesses: businesses,
      currentPage: currentPage,
      lastPage: lastPage,
      hasNextPage: hasNextPage,
      total: total,
    );
  }
}
