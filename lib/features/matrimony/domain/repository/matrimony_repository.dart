import '../../data/model/matrimony_cast_model.dart';
import '../../data/model/matrimony_chat_response.dart';
import 'package:edu_cluezer/core/network/multipart.dart';
import '../../data/model/matrimony_response.dart';
import '../../data/model/matrimony_plan_model.dart';

import '../../data/model/search_matrimony_response.dart';
import '../../data/model/connection_requests_response.dart';

abstract class MatrimonyRepository {
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
