// Model class representing a user profile with its details
class UserProfile {
  final String id;
  final String username;
  final String displayName;
  // Birthday and bio are nullable because they are optional fields in the onboarding form
  final DateTime? birthday;
  final String? bio;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.birthday,
    required this.bio,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id:        map['id'] as String,
      username:  map['username'] as String,
      displayName: map['display_name'] as String,
      birthday:  map['birthday'] != null ? DateTime.parse(map['birthday']) : null,
      bio:       map['bio'] as String?,
    );
  }
}