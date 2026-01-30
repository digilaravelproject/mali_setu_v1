
import 'dart:io';

import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class AddBusinessProductUseCase {
  final BusinessRepository repository;

  AddBusinessProductUseCase({required this.repository});

  Future<BusinessResponse> call(Map<String, dynamic> data, List<File> images) {
    return repository.addProduct(data, images);
  }
}
