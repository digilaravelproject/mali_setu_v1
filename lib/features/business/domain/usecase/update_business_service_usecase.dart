import 'dart:io';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class UpdateBusinessServiceUseCase {
  final BusinessRepository repository;

  UpdateBusinessServiceUseCase({required this.repository});

  Future<BusinessResponse> call(int id, Map<String, dynamic> data, List<File> images) {
    return repository.updateService(id, data, images);
  }
}
