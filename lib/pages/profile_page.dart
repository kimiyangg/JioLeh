import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/pages/profile_edit_page.dart';

import 'package:jio_leh/services/services.dart';

import "package:jio_leh/theme.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _account = Services.account;

  // The loaded profile. Null until it finishes loading.                                                                                                                                                                                                                                                                          
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _account.getUserProfile();
    setState(() => _profile = profile);
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
    final titleSize = context.scaledFont(AppTextSizes.heading);
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
                          fontSize: titleSize + 2,
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
                                        onPressed: _profile == null
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
                                        onPressed: null,
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
