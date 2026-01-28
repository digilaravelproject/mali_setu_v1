
import 'dart:io';

import '../repository/all_business_repository.dart';
import '../../../../../../features/business/data/model/res_all_business_model.dart';

class AddBusinessServiceUseCase {
  final BusinessRepository repository;

  AddBusinessServiceUseCase({required this.repository});

  Future<BusinessResponse> call(Map<String, dynamic> data, List<File> images) {
    return repository.addService(data, images);
  }
}
