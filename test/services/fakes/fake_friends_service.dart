import "package:jio_leh/services/friends_service.dart";
import "package:jio_leh/models/user_friend.dart";
import "package:jio_leh/models/user_profile.dart";

class FakeFriendsService extends FriendsService {

  FakeFriendsService({
    this.friends = const [],
    this.throwAlreadyExists = false,
    this.throwRequestNotFound = false,
    this.throwNotFound = false,
  });

  // Defaults live in the constructor, so each test sets only what it cares about.
  List<UserFriend> friends;

  bool throwAlreadyExists;
  bool throwRequestNotFound;
  bool throwNotFound;

  int sendFriendRequestCalls = 0;
  int acceptFriendRequestCalls = 0;
  int rejectFriendRequestCalls = 0;
  int removeFriendCalls = 0;

  void Function()? lastFriendRequestOnChange;

  @override
  Future<List<UserFriend>> getUserFriends() async => friends;

  @override
  Future<void> acceptFriendRequest(UserProfile fromUser) async {
    acceptFriendRequestCalls++;
    if (throwRequestNotFound) {
      throw FriendsRequestNotFound();
    }
  }

  @override
  Future<void> sendFriendRequest(UserProfile toUser) async {
    sendFriendRequestCalls++;
    if (throwAlreadyExists) {
      throw FriendAlreadyExists();
    }
  }

  @override
  Future<void> rejectFriendRequest(UserProfile fromUser) async {
    rejectFriendRequestCalls++;
    if (throwRequestNotFound) {
      throw FriendsRequestNotFound();
    }
  }

  @override
  Future<void> removeFriend(UserProfile friend) async {
    removeFriendCalls++;
    if (throwNotFound) {
      throw FriendNotFound();
    }
  }

  @override
  void Function() subscribeToFriendRequests(void Function() onChange) {
    lastFriendRequestOnChange = onChange;
    return () {};
  }

}