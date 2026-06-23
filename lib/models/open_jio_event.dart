import 'package:jio_leh/models/user_friend.dart';

/// The current user's response to an invite they received.
enum InviteStatus { pending, accepted, declined }
class OpenJioEvent {
  const OpenJioEvent({
    this.id, 
    required this.invitedFriends,
    required this.dateTime, 
    required this.caption,
    required this.locationName,
    this.senderId, 
    this.senderName,
    this.inviteStatus
  });

  final String? id;
  final List<UserFriend> invitedFriends;
  final DateTime dateTime;
  final String caption;
  final String locationName;
  final String? senderId; // The user ID of the person who sent the invite
  final String? senderName; // The display name of the person who sent the invite
  final InviteStatus? inviteStatus; // The current user's response to the invite

  String get friendNames {
    return invitedFriends
        .map((friend) => friend.userProfile.displayName)
        .join(', ');
  }
}