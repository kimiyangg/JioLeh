import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/pages/friends/friends_page_model.dart';
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
  late final FriendsPageModel _model;
  bool _didInit = false;

  final _searchController = TextEditingController();

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
    _model = FriendsPageModel(
      friends: services.friends,
      account: services.account,
      auth: services.auth,
      points: services.points,
    )
      ..addListener(_rebuild)
      ..start();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _searchController.dispose();
    _model
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        context.showAppSnackBar('$error', kind: SnackBarKind.error);
      }
    }
  }

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) return;
    await _model.search(_searchController.text);
    if (!mounted) return;
    if (_model.searchResult == null) {
      context.showAppSnackBar('No user found');
    }
  }

  // Sends a friend request to the searched [user]. On success clears the search
  // box, so the new request shows under Requests → Sent.
  Future<void> _sendRequest(UserProfile user) async {
    try {
      await _model.sendRequest(user);
      if (!mounted) return;
      _searchController.clear();
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
                selectedIndex: _model.selectedTab,
                onChanged: _model.selectTab,
              ),
              const SizedBox(height: 20),
              // Search-to-invite lives in the Requests tab only.
              if (_model.selectedTab == 1) ...[
                FriendSearchBar(
                  controller: _searchController,
                  searching: _model.searching,
                  result: _model.searchResult,
                  onSearch: _search,
                  onSendRequest: _sendRequest,
                ),
                const SizedBox(height: 15),
              ],
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      return const Center(child: BrandLoadingAnimation.compact());
    }
    if (_model.error != null) {
      return Center(
        child: Text(
          'Error: ${_model.error}',
          style: TextStyle(fontSize: context.scaledFont(AppTextSizes.body)),
        ),
      );
    }

    final tab = _model.selectedTab;
    if (tab == 0) {
      return FriendsTab(friends: _model.acceptedFriends);
    }
    if (tab == 1) {
      return RequestsTab(
        requests: _model.incomingRequests,
        sent: _model.outgoingRequests,
        onAccept: (p) => _runAction(() => _model.acceptRequest(p)),
        onReject: (p) => _runAction(() => _model.rejectRequest(p)),
      );
    }
    if (tab == 2) {
      return LeaderboardTab(
        entries: _model.leaderboard,
        currentUserId: _model.currentUserId,
      );
    }
    return const SizedBox.shrink();
  }
}
