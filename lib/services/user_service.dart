import '../models/user.dart';
import '../services/api_client.dart';

class UserService {
  static final UserService instance = UserService._();
  UserService._();

  Future<User?> updateProfile(Map<String, dynamic> fields) async {
    // Remove null values
    fields.removeWhere((key, value) => value == null);
    if (fields.isEmpty) return null;

    final resp = await ApiClient().patch('/api/v1/users/me', fields);
    if (resp.isSuccess && resp.data != null) {
      final userData = resp.data!;
      return User(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
        phoneNumber: userData['phone_number'] as String?,
        profileImage: userData['avatar_url'] as String?,
        createdAt: DateTime.parse(userData['created_at'] as String),
        points: userData['points'] as int? ?? 0,
        role: userData['role'] as String? ?? 'user',
        isStaffRegistered: userData['is_staff_registered'] as bool? ?? false,
        privacyPolicyAccepted: userData['privacy_policy_accepted'] as bool?,
      );
    }
    throw Exception(resp.message ?? 'Failed to update profile');
  }
}
