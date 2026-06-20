import 'package:jio_leh/models/user_friend.dart';

class OpenJioEvent {
  const OpenJioEvent({
    required this.invitedFriends,
  });

  final List<UserFriend> invitedFriends;

  String get friendNames {
    return invitedFriends
        .map((friend) => friend.userProfile.displayName)
        .join(', ');
  }
}