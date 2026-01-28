
import 'dart:io';

import '../repository/all_business_repository.dart';
import '../../../../../../features/business/data/model/res_all_business_model.dart';

class AddBusinessProductUseCase {
  final BusinessRepository repository;

  AddBusinessProductUseCase({required this.repository});

  Future<BusinessResponse> call(Map<String, dynamic> data, List<File> images) {
    return repository.addProduct(data, images);
  }
}
