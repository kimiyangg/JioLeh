import 'package:flutter/foundation.dart';

import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';
import 'package:jio_leh/services/points_service.dart';

/// Presentation state and logic for [FriendsPage].
///
/// Call [start] once after construction to kick off the initial load and the
/// realtime subscriptions. Mirrors the pattern in [InvitationsPageModel].
class FriendsPageModel extends ChangeNotifier {
  FriendsPageModel({
    required this.friends,
    required this.account,
    required this.auth,
    required this.points,
  });

  // Dependencies
  final FriendsService friends;
  final AccountService account;
  final AuthService auth;
  final PointsService points;

  // States: what it holds
  List<UserFriend> _allFriends = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;
  UserProfile? _searchResult;
  bool _searching = false;
  bool _disposed = false;

  // Getters: intentionally unchangeable here, only readable
  List<UserFriend> get acceptedFriends =>
      _allFriends.where((f) => f.isAccepted).toList();
  List<UserFriend> get incomingRequests =>
      _allFriends.where((f) => f.isIncomingRequest).toList();
  List<UserFriend> get outgoingRequests =>
      _allFriends.where((f) => f.isOutgoingRequest).toList();
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedTab => _selectedTab;
  UserProfile? get searchResult => _searchResult;
  bool get searching => _searching;
  String get currentUserId => auth.getCurrentUserId();

  void Function()? _unsubscribeRequests;
  void Function()? _unsubscribePoints;

  void start() {
    loadFriends();
    _unsubscribeRequests = friends.subscribeToFriendRequests(loadFriends);
    _unsubscribePoints = points.subscribeToLeaderboard(loadLeaderboard);
  }

  /// Loads the friend list and, from it, the leaderboard.
  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final all = await friends.getUserFriends();
      if (_disposed) return;
      _allFriends = all;
      _leaderboard = await _fetchLeaderboard();
      _isLoading = false;
    } catch (e, st) {
      if (_disposed) return;
      debugPrint('FriendsPageModel.loadFriends: $e\n$st');
      _isLoading = false;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Refetches only the leaderboard, driven by the realtime points signal.
  Future<void> loadLeaderboard() async {
    try {
      final entries = await _fetchLeaderboard();
      if (_disposed) return;
      _leaderboard = entries;
    } catch (e, st) {
      if (_disposed) return;
      debugPrint('FriendsPageModel.loadLeaderboard: $e\n$st');
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<List<LeaderboardEntry>> _fetchLeaderboard() {
    return points.getLeaderboard([
      currentUserId,
      ...acceptedFriends.map((f) => f.userProfile.id),
    ]);
  }

  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  /// Accepts a request then reloads. Rethrows so the page can surface a snack bar.
  Future<void> acceptRequest(UserProfile fromUser) async {
    await friends.acceptFriendRequest(fromUser);
    await loadFriends();
  }

  /// Rejects a request then reloads. Rethrows so the page can surface a snack bar.
  Future<void> rejectRequest(UserProfile fromUser) async {
    await friends.rejectFriendRequest(fromUser);
    await loadFriends();
  }

  /// Searches for a user by username. Rethrows so the page can surface a snack bar.
  Future<void> search(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;

    _searching = true;
    notifyListeners();
    try {
      final result = await account.findByUsername(trimmed);
      if (_disposed) return;
      _searchResult = result;
    } finally {
      if (!_disposed) {
        _searching = false;
        notifyListeners();
      }
    }
  }

  /// Sends a friend request to [user], clears the search, then reloads.
  /// Rethrows so the page can surface a snack bar.
  Future<void> sendRequest(UserProfile user) async {
    await friends.sendFriendRequest(user);
    if (_disposed) return;
    _searchResult = null;
    await loadFriends();
  }

  void clearSearch() {
    _searchResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _unsubscribeRequests?.call();
    _unsubscribePoints?.call();
    super.dispose();
  }
}
