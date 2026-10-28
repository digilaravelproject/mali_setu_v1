import 'dart:io';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class UpdateBusinessProductUseCase {
  final BusinessRepository repository;

  UpdateBusinessProductUseCase({required this.repository});

  Future<BusinessResponse> call(int id, Map<String, dynamic> data, List<File> images) {
    return repository.updateProduct(id, data, images);
  }
}
