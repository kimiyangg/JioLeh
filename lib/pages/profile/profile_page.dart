import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/pages/profile/profile_edit_page.dart';

import 'package:jio_leh/services/services.dart';

import "package:jio_leh/theme.dart";
import 'package:jio_leh/pages/profile/share_code_page.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _account = Services.account;

  late final _friends = Services.friends;

  bool _sendingFriendRequest = false;
  bool _friendRequestSent = false;

  // The loaded profile. Null until it finishes loading.                                                                                                                                                                                                                                                                          
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Whether the loaded profile belongs to the current user. If no profile is
  // loaded yet, returns false.
  bool get _isOwnProfile {
    final profile = _profile;
    if (profile == null) return false;

    return profile.id == Services.auth.getCurrentUserId();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile not found')),
      );
      Navigator.maybePop(context);
      return;
    }

    setState(() => _profile = profile);
  }

  // Sends a friend request to the loaded profile, if it's not the current user's own profile and a request isn't already being sent. 
  //Shows a success message on success, or an error message on failure. 
  //Updates the state to reflect whether a request is being sent or has been sent.

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Friend request sent to ${profile.displayName}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingFriendRequest = false);
      }
    }
  }



  Future<void> _editProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(profile: profile),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() => _profile = updatedProfile);
    }
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatBirthday(DateTime? birthday) {
    if (birthday == null) return "";
    return "Born ${birthday.day} ${_monthNames[birthday.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = context.scaledFont(AppTextSizes.heading) + 2;
    final nameSize = context.scaledFont(AppTextSizes.button);
    final labelSize = context.scaledFont(AppTextSizes.label);

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
                  Row(
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 100),
                      FilledButton(
                        onPressed: () => Navigator.maybePop(context),
                        child: Text("Back"),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppColors.darkWidgetBackground,
                                      foregroundImage:
                                        _profile?.avatarUrl == null || _profile!.avatarUrl!.isEmpty
                                            ? null
                                            : NetworkImage(_profile!.avatarUrl!),
                                      child: _profile?.avatarUrl == null || _profile!.avatarUrl!.isEmpty
                                        ? const Icon(Icons.person, color: Colors.white)
                                        : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _profile?.displayName ?? "",
                                            style: TextStyle(
                                              fontSize: nameSize,
                                              fontWeight: FontWeight.w900
                                            ),
                                          ),
                                          Text("@${_profile?.username ?? ""}")
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _profile?.bio ??
                                            "New here and keen to meet some kakis. Always down for makan or a casual hang. Jio me la 🙂",
                                        style: TextStyle(
                                          fontSize: labelSize
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        children: [
                                          Icon(Icons.cake, size: 15,),
                                          SizedBox(width: 10,),
                                          Text(_formatBirthday(_profile?.birthday)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isOwnProfile)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF211D18),
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: const Color(0xFF211D18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: _profile == null || !_isOwnProfile // prevet others editing another user's profile
                                              ? null
                                              : _editProfile,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5,),
                                              Flexible(
                                                child: Text(
                                                  "Edit Profile",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: labelSize,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                AppColors.lightWidgetBackground,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: AppColors.lightWidgetBackground,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: _profile == null || !_isOwnProfile // prevent others sharing another user's profile
                                              ? null
                                              : () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ShareCodePage(profile: _profile!),
                                                    ),
                                                  );
                                                },  
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.share,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5,),
                                              Flexible(
                                                child: Text(
                                                  "Share Code",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: labelSize,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        )
                                      )
                                    ],
                                  )
                                  else if (!_isOwnProfile && _profile != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          onPressed: _sendingFriendRequest || _friendRequestSent
                                              ? null
                                              : _sendFriendRequest,
                                          icon: _sendingFriendRequest
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Icon(
                                                  _friendRequestSent
                                                      ? Icons.check
                                                      : Icons.person_add,
                                                ),
                                          label: Text(
                                            _friendRequestSent
                                                ? 'Friend Request Sent'
                                                : _sendingFriendRequest
                                                    ? 'Sending...'
                                                    : 'Add as Friend',
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
