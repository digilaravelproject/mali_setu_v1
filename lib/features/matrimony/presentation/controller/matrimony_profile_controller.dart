

import '../../data/model/profile_model.dart';

class ProfileService {
  // यहाँ आप API से data fetch करेंगे
  // अभी के लिए mock data return कर रहे हैं

  static Future<ProfileModel> fetchProfileData(String profileId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - आप इसे API call से replace कर देना
    return ProfileModel(
      id: profileId,
      name: 'Rajesh Kumar',
      age: 32,
      profession: 'Doctor',
      location: 'Delhi, India',
      religion: 'Hindu',
      caste: 'Rajput',
      education: 'MBBS, MD',
      bio: 'I am a cardiologist working at Apollo Hospital. I believe in living a balanced life with family values at the core. Enjoy traveling, reading medical journals, and playing cricket on weekends.',
      images: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
        'https://images.unsplash.com/photo-1507591064344-4c6ce005-128',
      ],
      height: '5\' 10"',
      annualIncome: '₹ 25 LPA',
      interests: ['Medical Research', 'Cricket', 'Travel', 'Classical Music', 'Reading'],
      isPremium: true,
      isVerified: true,
      partnerExpectations: 'Looking for an educated, family-oriented partner who values relationships and personal growth.',
      familyDetails: 'Joint family, Father - Businessman, Mother - Homemaker, 1 younger sister (married)',
    );
  }

  // Connection request भेजने के लिए
  static Future<bool> sendConnectionRequest(String profileId, String message) async {
    print('Sending connection request to $profileId with message: $message');
    await Future.delayed(const Duration(seconds: 1));

    // API integration करें
    // final response = await http.post(
    //   Uri.parse('$apiBaseUrl/send-connection'),
    //   body: {'profileId': profileId, 'message': message}
    // );

    return true; // Success simulation
  }

  // Profile shortlist करने के लिए
  static Future<bool> shortlistProfile(String profileId) async {
    print('Shortlisting profile: $profileId');
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Profile report करने के लिए
  static Future<bool> reportProfile(String profileId, String reason) async {
    print('Reporting profile: $profileId for reason: $reason');
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}