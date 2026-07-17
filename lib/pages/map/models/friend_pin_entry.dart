import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/models/user_profile.dart';

/// One friend's pin on a shared [Place], combined with their resolved
/// profile and display-ready photo URLs, for [SharedPlaceDetailsSheet].
class FriendPinEntry {
  const FriendPinEntry({
    required this.pin,
    required this.profile,
    required this.photoUrls,
    required this.isCurrentUser,
  });

  final UserPin pin;
  final UserProfile? profile;
  final List<String> photoUrls;
  final bool isCurrentUser;
}
