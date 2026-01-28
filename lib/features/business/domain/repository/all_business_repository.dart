import '../../data/model/res_all_business_model.dart';


abstract class BusinessRepository {
  Future<BusinessResponse> getAllBusinesses();
}
