import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';
import 'package:jio_leh/widgets/app_field_box.dart';

// A single user row shared across the friends tabs: avatar + name/username on a white card, with an optional [trailing] widget (a view-profile arrow, accept/reject buttons, or a status label).
class FriendTile extends StatelessWidget {
  final UserProfile profile;
  final Widget? trailing;

  const FriendTile({super.key, required this.profile, this.trailing});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return AppFieldBox(
      height: 65,
      child: Row(
        children: [
          const SizedBox(width: 20),
          AppAvatar(
            radius: 20,
            image: hasAvatar ? NetworkImage(avatarUrl) : null,
            placeholder: Icons.person,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: TextStyle(
                    fontSize: context.scaledFont(AppTextSizes.body),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "@${profile.username}",
                  style: TextStyle(
                    fontSize: context.scaledFont(AppTextSizes.label),
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
