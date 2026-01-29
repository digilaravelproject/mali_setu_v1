import '../../data/data_source/matrimony_data_source.dart';
import '../../data/model/matrimony_chat_response.dart';
import '../../data/model/matrimony_response.dart';
import '../../domain/repository/matrimony_repository.dart';

import '../../data/model/search_matrimony_response.dart';
import '../../data/model/connection_requests_response.dart';

class MatrimonyRepositoryImpl implements MatrimonyRepository {
  final MatrimonyDataSource dataSource;

  MatrimonyRepositoryImpl({required this.dataSource});

  @override
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data) async {
    return await dataSource.createProfile(data);
  }

  @override
  Future<dynamic> getProfiles() async {
    return await dataSource.getProfiles();
  }

  @override
  Future<SearchMatrimonyResponse> searchMatrimony(Map<String, dynamic> filters) async {
    return await dataSource.searchMatrimony(filters);
  }

  @override
  Future<MatrimonyProfileDetailResponse> getProfileDetails(int id) async {
    return await dataSource.getProfileDetails(id);
  }

  @override
  Future<dynamic> sendConnectionRequest(Map<String, dynamic> data) async {
    return await dataSource.sendConnectionRequest(data);
  }

  @override
  Future<ConnectionRequestsResponse> getConnectionRequests() async {
    return await dataSource.getConnectionRequests();
  }

  @override
  Future<dynamic> respondToConnectionRequest(int requestId, Map<String, dynamic> data) async {
    return await dataSource.respondToConnectionRequest(requestId, data);
  }

  @override
  Future<MatrimonyConversationResponse> getConversations() async {
    return await dataSource.getConversations();
  }

  @override
  Future<MatrimonyMessagesResponse> getMessages(int conversationId) async {
    return await dataSource.getMessages(conversationId);
  }

  @override
  Future<dynamic> sendMessage(Map<String, dynamic> data) async {
    return await dataSource.sendMessage(data);
  }
}
