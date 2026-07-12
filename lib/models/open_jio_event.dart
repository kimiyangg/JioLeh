import 'package:jio_leh/models/user_friend.dart';

/// The current user's response to an invite they received.
enum InviteStatus { pending, accepted, declined }
class OpenJioEvent {
  final String? id;
  final List<UserFriend> invitedFriends;
  final DateTime dateTime;
  final String caption;
  final String locationName;
  final String? placeId; // The linked places row; null for free-text locations
  final String? senderId; // The user ID of the person who sent the invite
  final String? senderName; // The display name of the person who sent the invite
  final InviteStatus? inviteStatus; // The current user's response to the invite

  const OpenJioEvent({
    this.id,
    required this.invitedFriends,
    required this.dateTime,
    required this.caption,
    required this.locationName,
    this.placeId,
    this.senderId,
    this.senderName,
    this.inviteStatus
  });

  factory OpenJioEvent.fromMap(
    Map<String, dynamic> map, {
    List<UserFriend> invitedFriends = const [],
    String? senderName,
    InviteStatus? status,
  }) {
    return OpenJioEvent(
      id: map['id'] as String,
      invitedFriends: invitedFriends,
      dateTime: DateTime.parse(map['date_time'] as String),
      caption: map['caption'] as String,
      locationName: map['location_name'] as String,
      placeId: map['place_id'] as String?,
      senderId: map['user_id'] as String?,
      senderName: senderName,
      inviteStatus: status,
    );
  }

  String get friendNames {
    return invitedFriends
        .map((friend) => friend.userProfile.displayName)
        .join(', ');
  }

  Map<String, dynamic> toMap() => {
        'date_time': dateTime.toIso8601String(),
        'caption': caption,
        'location_name': locationName,
        if (placeId != null) 'place_id': placeId,
      };
}