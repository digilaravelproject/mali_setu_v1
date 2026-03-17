import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/domain/usecase/all_business_usecase.dart';

class SearchBusinessUseCase {
  final BusinessRepository repository;

  SearchBusinessUseCase({required this.repository});

  Future<BusinessPaginationResult> call(String query) async {
    final response = await repository.searchBusiness(query);
    
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
