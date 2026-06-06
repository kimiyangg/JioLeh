// Model class representing a user friend with its details
import 'package:jio_leh/models/user_profile.dart';

class UserFriend {
  final UserProfile userProfile;
  final FriendshipStatus status;

  const UserFriend({
    required this.userProfile,
    required this.status,
  });

  factory UserFriend.fromMap(Map<String, dynamic> map) {
    return UserFriend(
      userProfile: UserProfile.fromMap(map['profiles'] as Map<String, dynamic>),
      status: FriendshipStatus.values.byName(map['status'] as String),
    );
  }
}

// Enum representing the status of a friendship
enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}
