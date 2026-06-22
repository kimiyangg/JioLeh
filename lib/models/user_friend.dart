// Model class representing a user friend with its details
import 'package:jio_leh/models/user_profile.dart';

class UserFriend {
  final UserProfile userProfile;
  final FriendshipStatus status;
  final FriendDirection direction;

  const UserFriend({
    required this.userProfile,
    required this.status,
    required this.direction,
  });

  factory UserFriend.fromMap(Map<String, dynamic> map, FriendDirection direction) {
    return UserFriend(
      userProfile: UserProfile.fromMap(map['profiles'] as Map<String, dynamic>),
      status: FriendshipStatus.values.byName(map['status'] as String),
      direction: direction,
    );
  }

  // An accepted (mutual) friend.
  bool get isAccepted => status == FriendshipStatus.accepted;

  // A pending request the other user sent me — shown under Requests.
  bool get isIncomingRequest =>
      status == FriendshipStatus.pending && direction == FriendDirection.incoming;

  // A pending request I sent that they haven't accepted — shown under Sent.
  bool get isOutgoingRequest =>
      status == FriendshipStatus.pending && direction == FriendDirection.outgoing;
}

// Enum representing, from the current user's perspective, who initiated the
// friendship: incoming means the other user sent the request to me, outgoing
// means I sent the request to them.
enum FriendDirection {
  incoming,
  outgoing,
}

// Enum representing the status of a friendship
enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}
