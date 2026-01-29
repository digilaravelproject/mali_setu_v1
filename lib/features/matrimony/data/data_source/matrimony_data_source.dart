import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import '../model/matrimony_response.dart';
import '../model/matrimony_chat_response.dart';
import '../model/search_matrimony_response.dart';
import '../model/connection_requests_response.dart';

abstract class MatrimonyDataSource {
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data);
  Future<dynamic> getProfiles();
  Future<SearchMatrimonyResponse> searchMatrimony(Map<String, dynamic> filters);
  Future<MatrimonyProfileDetailResponse> getProfileDetails(int id);
  Future<dynamic> sendConnectionRequest(Map<String, dynamic> data);
  Future<ConnectionRequestsResponse> getConnectionRequests();
  Future<dynamic> respondToConnectionRequest(int requestId, Map<String, dynamic> data);
  Future<MatrimonyConversationResponse> getConversations();
  Future<MatrimonyMessagesResponse> getMessages(int conversationId);
  Future<dynamic> sendMessage(Map<String, dynamic> data);
}

class MatrimonyDataSourceImpl implements MatrimonyDataSource {
  final ApiClient apiClient;

  MatrimonyDataSourceImpl({required this.apiClient});

  @override
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.matrimonyProfile, data: data);
    return MatrimonyResponse.fromJson(response.data);
  }

  @override
  Future<dynamic> getProfiles() async {
    final response = await apiClient.get(ApiConstants.matrimonyProfile);
    return response.data;
  }

  @override
  Future<SearchMatrimonyResponse> searchMatrimony(Map<String, dynamic> filters) async {
    final response = await apiClient.post(ApiConstants.searchMatrimony, data: filters);
    return SearchMatrimonyResponse.fromJson(response.data);
  }

  @override
  Future<MatrimonyProfileDetailResponse> getProfileDetails(int id) async {
    final response = await apiClient.get("${ApiConstants.matrimonyProfile}/$id");
    return MatrimonyProfileDetailResponse.fromJson(response.data);
  }

  @override
  Future<dynamic> sendConnectionRequest(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.connectionRequest, data: data);
    return response.data;
  }

  @override
  Future<ConnectionRequestsResponse> getConnectionRequests() async {
    final response = await apiClient.get(ApiConstants.connectionRequests);
    return ConnectionRequestsResponse.fromJson(response.data);
  }

  @override
  Future<dynamic> respondToConnectionRequest(int requestId, Map<String, dynamic> data) async {
    final response = await apiClient.put("${ApiConstants.connectionRequest}/$requestId", data: data);
    return response.data;
  }

  @override
  Future<MatrimonyConversationResponse> getConversations() async {
    final response = await apiClient.get(ApiConstants.matrimonyConversations);
    return MatrimonyConversationResponse.fromJson(response.data);
  }

  @override
  Future<MatrimonyMessagesResponse> getMessages(int conversationId) async {
    final response = await apiClient.get("${ApiConstants.matrimonyMessages}/$conversationId");
    return MatrimonyMessagesResponse.fromJson(response.data);
  }

  @override
  Future<dynamic> sendMessage(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.matrimonySendMessage, data: data);
    return response.data;
  }
}
