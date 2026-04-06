import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/network/multipart.dart';
import '../model/matrimony_response.dart';
import '../model/matrimony_chat_response.dart';
import '../model/search_matrimony_response.dart';
import '../model/connection_requests_response.dart';
import '../model/matrimony_cast_model.dart';
import '../model/matrimony_plan_model.dart';

abstract class MatrimonyDataSource {
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data);
  Future<MatrimonyResponse> updateProfile(Map<String, dynamic> data);
  Future<dynamic> getProfiles();
  Future<SearchMatrimonyResponse> searchMatrimony(Map<String, dynamic> filters);
  Future<MatrimonyProfileDetailResponse> getProfileDetails(int id);
  Future<dynamic> sendConnectionRequest(Map<String, dynamic> data);
  Future<ConnectionRequestsResponse> getConnectionRequests();
  Future<dynamic> respondToConnectionRequest(int requestId, Map<String, dynamic> data);
  Future<MatrimonyConversationResponse> getConversations();
  Future<MatrimonyMessagesResponse> getMessages(int conversationId);
  Future<dynamic> sendMessage(Map<String, dynamic> data);
  Future<dynamic> sendMessageWithFile(Map<String, String> body, List<MultipartBody> multipartBody);
  Future<dynamic> removeConnectionRequest(Map<String, dynamic> data);
  Future<ConnectionRequestsResponse> getConnectedUsers();
  Future<CastResponse> getCasts();
  Future<SubCastResponse> getSubCasts(int castId);
  Future<MatrimonyPlanResponse> getMatrimonyPlans();
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
  Future<MatrimonyResponse> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put(ApiConstants.matrimonyProfile, data: data);
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

  @override
  Future<dynamic> sendMessageWithFile(Map<String, String> body, List<MultipartBody> multipartBody) async {
    final response = await apiClient.postMultipartData(
      ApiConstants.matrimonySendMessage,
      body,
      multipartBody,
      [],
    );
    return response.data;
  }

  @override
  Future<dynamic> removeConnectionRequest(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.matrimonyRemoveRequest, data: data);
    return response.data;
  }

  @override
  Future<ConnectionRequestsResponse> getConnectedUsers() async {
    final response = await apiClient.get(ApiConstants.matrimonyConnectedUsers);
    return ConnectionRequestsResponse.fromJson(response.data);
  }

  @override
  Future<CastResponse> getCasts() async {
    final response = await apiClient.get(ApiConstants.matrimonyCasts);
    return CastResponse.fromJson(response.data);
  }

  @override
  Future<SubCastResponse> getSubCasts(int castId) async {
    final response = await apiClient.get("${ApiConstants.matrimonySubCasts}/$castId/subcasts");
    return SubCastResponse.fromJson(response.data);
  }

  @override
  Future<MatrimonyPlanResponse> getMatrimonyPlans() async {
    final response = await apiClient.get(ApiConstants.matrimonyPlans);
    return MatrimonyPlanResponse.fromJson(response.data);
  }
}
