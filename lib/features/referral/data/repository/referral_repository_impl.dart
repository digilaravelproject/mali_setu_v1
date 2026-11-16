import '../../domain/repository/referral_repository.dart';
import '../data_source/referral_data_source.dart';
import '../models/referral_model.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final ReferralDataSource dataSource;

  ReferralRepositoryImpl({required this.dataSource});

  @override
  Future<VolunteerEarningsData> getVolunteerEarnings({String? referralCode}) {
    return dataSource.getVolunteerEarnings(referralCode: referralCode);
  }

  @override
  Future<List<ReferredUserItem>> getReferredUsers({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return dataSource.getReferredUsers(
      referralCode: referralCode,
      userType: userType,
      status: status,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<ReferredUserItem>> getReferralHistory({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return dataSource.getReferralHistory(
      referralCode: referralCode,
      userType: userType,
      status: status,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<ReferralNetworkNode> getReferralNetwork({
    String? referralCode,
    int depth = 3,
    String? district,
    String? taluka,
    String? cityVillage,
  }) {
    return dataSource.getReferralNetwork(
      referralCode: referralCode,
      depth: depth,
      district: district,
      taluka: taluka,
      cityVillage: cityVillage,
    );
  }

  @override
  Future<ShareableLinkData> getShareableLink({String? referralCode}) {
    return dataSource.getShareableLink(referralCode: referralCode);
  }

  @override
  Future<SendReferralResult> sendReferralLink({
    required String email,
    String? referralCode,
    String? recipientName,
    String? message,
  }) {
    return dataSource.sendReferralLink(
      email: email,
      referralCode: referralCode,
      recipientName: recipientName,
      message: message,
    );
  }
}

