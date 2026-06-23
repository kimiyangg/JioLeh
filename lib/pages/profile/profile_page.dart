import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/routing/app_routing.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';

import "package:jio_leh/theme.dart";

import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';
import 'package:jio_leh/pages/profile/widgets/profile_card.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AccountService _account;
  late final FriendsService _friends;
  late final AuthService _auth;
  bool _didInit = false;

  bool _sendingFriendRequest = false;
  bool _friendRequestSent = false;

  // The loaded profile. Null until it finishes loading.
  UserProfile? _profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Services come from the provider, which can't be read in initState. Do the
    // one-time setup here (didChangeDependencies can fire more than once).
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _account = services.account;
    _friends = services.friends;
    _auth = services.auth;

    _loadProfile();
  }

  // Whether the loaded profile belongs to the current user. If no profile is
  // loaded yet, returns false.
  bool get _isOwnProfile {
    final profile = _profile;
    if (profile == null) return false;

    return profile.id == _auth.getCurrentUserId();
  }

  // Loads the profile from the database and updates the state. If the profile
  // fails to load (e.g. due to network issues or if the profile doesn't exist),
  // shows an error message and pops the page.
  Future<void> _loadProfile() async {
    final UserProfile? profile;

    if (widget.userId == null) {
      profile = await _account.getUserProfile();
    } else {
      profile = await _account.getProfileById(widget.userId!);
    }

    if (!mounted) return;

    if (profile == null) {
      context.showAppSnackBar('Profile not found', kind: SnackBarKind.error);
      Navigator.maybePop(context);
      return;
    }

    setState(() => _profile = profile);
  }

  // Sends a friend request to the loaded profile, if it's not the current
  // user's own profile and a request isn't already being sent. Shows a success
  // or error message, and updates the state to reflect the request's status.
  Future<void> _sendFriendRequest() async {
    final profile = _profile;

    if (profile == null || _isOwnProfile || _sendingFriendRequest) {
      return;
    }

    setState(() => _sendingFriendRequest = true);

    try {
      await _friends.sendFriendRequest(profile);

      if (!mounted) return;

      setState(() => _friendRequestSent = true);

      context.showAppSnackBar(
        'Friend request sent to ${profile.displayName}',
        kind: SnackBarKind.success,
      );
    } catch (error) {
      if (!mounted) return;

      context.showAppSnackBar('$error', kind: SnackBarKind.error);
    } finally {
      if (mounted) {
        setState(() => _sendingFriendRequest = false);
      }
    }
  }

  Future<void> _editProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final updatedProfile = await Navigator.push(
      context,
      AppRoutes.profileEdit(profile),
    );

    if (updatedProfile != null && mounted) {
      setState(() => _profile = updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(
                    title: "Profile",
                    // Show the close (✕) button only when viewing a specific
                    // user's profile (a pushed route, e.g. from the friends
                    // list); the home "my profile" tab passes no userId.
                    closeBtn: widget.userId != null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: ProfileCard(
                      profile: _profile,
                      isOwnProfile: _isOwnProfile,
                      onEdit: _editProfile,
                      onShare: () => Navigator.push(
                        context,
                        // ! operator is need to ensure that profile is loaded and throw errors if profile is null
                        AppRoutes.shareCode(_profile!)
                      ),
                      isSendingRequest: _sendingFriendRequest,
                      requestSent: _friendRequestSent,
                      onAddFriend: _sendFriendRequest,
                    ),
                  ),
                  // Logout only makes sense on your own profile, not when
                  // viewing someone else's.
                  SizedBox(height: 16,),
                  if (_isOwnProfile)
                    AppPrimaryButton(
                      backgroundColor: Colors.grey,
                      liftColor: Colors.blueGrey,
                      label: "Log out",
                      onPressed: () => _auth.signOut(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
