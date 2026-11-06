import '../../data/models/referral_model.dart';

abstract class ReferralRepository {
  Future<VolunteerEarningsData> getVolunteerEarnings({String? referralCode});
  Future<List<ReferredUserItem>> getReferredUsers({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  });
  Future<List<ReferredUserItem>> getReferralHistory({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  });
  Future<ReferralNetworkNode> getReferralNetwork({
    String? referralCode,
    int depth = 3,
    String? district,
    String? taluka,
    String? cityVillage,
  });
  Future<ShareableLinkData> getShareableLink({String? referralCode});
  Future<SendReferralResult> sendReferralLink({
    required String email,
    String? referralCode,
    String? recipientName,
    String? message,
  });
}
