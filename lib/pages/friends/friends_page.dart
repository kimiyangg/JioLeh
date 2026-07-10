import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';
import 'package:jio_leh/services/points_service.dart';
import "package:jio_leh/theme.dart";
import "package:jio_leh/widgets/app_page_header.dart";
import "package:jio_leh/widgets/app_selection_bar.dart";
import "package:jio_leh/widgets/app_snack_bar.dart";
import 'package:jio_leh/pages/friends/widgets/friend_search_bar.dart';
import 'package:jio_leh/pages/friends/widgets/friends_tab.dart';
import 'package:jio_leh/pages/friends/widgets/leaderboard_tab.dart';
import 'package:jio_leh/pages/friends/widgets/requests_tab.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final FriendsService _friends;
  late final AccountService _account;
  late final AuthService _auth;
  late final PointsService _points;
  bool _didInit = false;

  final _searchController = TextEditingController();

  late Future<List<UserFriend>> _future;

  // Cached leaderboard fetch — built lazily once accepted friends are known,
  // and cleared whenever the friend list reloads so it stays in sync.
  Future<List<LeaderboardEntry>>? _leaderboardFuture;

  // The profile found by the last search, if any.
  UserProfile? _searchResult;
  bool _searching = false;

  // Which tab is selected (0 = Friends, 1 = Requests).
  int _selectedTab = 0;

  static const _items = [
    AppSelectionItem(label: 'Friends'),
    AppSelectionItem(label: 'Requests'),
    AppSelectionItem(label: 'Leaderboard'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _friends = services.friends;
    _account = services.account;
    _auth = services.auth;
    _points = services.points;
    _future = _friends.getUserFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _friends.getUserFriends();
      _leaderboardFuture = null; // clear cached leaderboard so it reloads
    });
  }

  // Runs a friend action, shows any error, and reloads the list on success.
  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      _reload();
    } catch (error) {
      if (mounted) {
        context.showAppSnackBar('$error', kind: SnackBarKind.error);
      }
    }
  }

  Future<void> _search() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;
    setState(() => _searching = true);
    try {
      final result = await _account.findByUsername(username);
      if (!mounted) return;
      setState(() => _searchResult = result);
      if (result == null) {
        context.showAppSnackBar('No user found');
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  // Sends a friend request to the searched [user]. On success clears the search
  // result and reloads, so the new request shows under Requests → Sent.
  Future<void> _sendRequest(UserProfile user) async {
    try {
      await _friends.sendFriendRequest(user);
      if (!mounted) return;
      setState(() {
        _searchResult = null;
        _searchController.clear();
      });
      _reload();
    } catch (error) {
      if (mounted) {
        context.showAppSnackBar('$error', kind: SnackBarKind.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: "Friends",
                closeBtn: false,
              ),
              const SizedBox(height: 20),
              AppSelectionBar(
                items: _items,
                selectedIndex: _selectedTab,
                onChanged: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: 20),
              // Search-to-invite lives in the Requests tab only.
              if (_selectedTab == 1) ...[
                FriendSearchBar(
                  controller: _searchController,
                  searching: _searching,
                  result: _searchResult,
                  onSearch: _search,
                  onSendRequest: _sendRequest,
                ),
                const SizedBox(height: 15),
              ],
              Expanded(
                child: FutureBuilder<List<UserFriend>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                          child: BrandLoadingAnimation.compact());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: context.scaledFont(AppTextSizes.body),
                          ),
                        ),
                      );
                    }
                    return _buildTabBody(snapshot.data ?? const []);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shows the body for the selected tab, fed by the already-loaded [all] friends.
  Widget _buildTabBody(List<UserFriend> all) {
    if (_selectedTab == 0) {
      final friends = all.where((f) => f.isAccepted).toList();
      return FriendsTab(friends: friends);
    }
    if (_selectedTab == 1) {
      final requests = all.where((f) => f.isIncomingRequest).toList();
      final sent = all.where((f) => f.isOutgoingRequest).toList();
      return RequestsTab(
        requests: requests,
        sent: sent,
        onAccept: (p) => _runAction(() => _friends.acceptFriendRequest(p)),
        onReject: (p) => _runAction(() => _friends.rejectFriendRequest(p)),
      );
    }
    if (_selectedTab == 2) {
      return _buildLeaderboard(all);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLeaderboard(List<UserFriend> all) {
    final currentUserId = _auth.getCurrentUserId();
    _leaderboardFuture ??= _points.getLeaderboard([
      currentUserId,
      ...all.where((f) => f.isAccepted).map((f) => f.userProfile.id),
    ]);

    return FutureBuilder<List<LeaderboardEntry>>(
      future: _leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: BrandLoadingAnimation.compact());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: context.scaledFont(AppTextSizes.body)),
            ),
          );
        }
        return LeaderboardTab(
          entries: snapshot.data ?? const [],
          currentUserId: currentUserId,
        );
      },
    );
  }
}
