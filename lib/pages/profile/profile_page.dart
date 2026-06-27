import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/pages/profile/profile_page_model.dart';
import 'package:jio_leh/pages/profile/widgets/profile_card.dart';
import 'package:jio_leh/routing/app_routing.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfilePageModel _model;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Services come from the provider, which can't be read in initState. Do the
    // one-time setup here (didChangeDependencies can fire more than once).
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _model = ProfilePageModel(
      account: services.account,
      friends: services.friends,
      auth: services.auth,
      userId: widget.userId,
    )..addListener(_onModelChanged);

    _model.loadProfile();
  }

  @override
  void dispose() {
    if (_didInit) {
      _model.removeListener(_onModelChanged);
      _model.dispose();
    }
    super.dispose();
  }

  void _onModelChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _sendFriendRequest() async {
    final profile = _model.profile;
    final result = await _model.sendFriendRequest();
    if (!mounted) return;

    switch (result.status) {
      case FriendRequestStatus.sent:
        context.showAppSnackBar(
          'Friend request sent to ${profile?.displayName ?? 'this user'}',
          kind: SnackBarKind.success,
        );
      case FriendRequestStatus.failure:
        context.showAppSnackBar('${result.error}', kind: SnackBarKind.error);
      case FriendRequestStatus.noProfile:
      case FriendRequestStatus.ownProfile:
      case FriendRequestStatus.alreadySending:
      case FriendRequestStatus.disposed:
        return;
    }
  }

  Future<void> _editProfile() async {
    final profile = _model.profile;
    if (profile == null) return;

    final updatedProfile = await Navigator.push<UserProfile?>(
      context,
      AppRoutes.profileEdit(profile),
    );

    if (updatedProfile != null && mounted) {
      _model.replaceProfile(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: AppPageHeader(
                title: 'Profile',
                // Show the close button only when viewing a specific user's
                // profile. The home "my profile" tab passes no userId.
                closeBtn: widget.userId != null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _model.error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load profile.'),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _model.loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final profile = _model.profile;
    if (profile == null) {
      return const Center(child: Text('Profile not found.'));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(
            profile: profile,
            isOwnProfile: _model.isOwnProfile,
            onEdit: _editProfile,
            onShare: () => Navigator.push(
              context,
              AppRoutes.shareCode(profile),
            ),
            isSendingRequest: _model.sendingFriendRequest,
            requestSent: _model.friendRequestSent,
            isAlreadyFriend: _model.isAlreadyFriend,
            onAddFriend: _sendFriendRequest,
          ),
          // Logout only makes sense on your own profile, not when viewing
          // someone else's.
          const SizedBox(height: 16),
          if (_model.isOwnProfile)
            AppPrimaryButton(
              backgroundColor: AppColors.danger,
              liftColor: AppColors.dangerShadow,
              label: 'Log out',
              onPressed: _model.signOut,
            ),
        ],
      ),
    );
  }
}
