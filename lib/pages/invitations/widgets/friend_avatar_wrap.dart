import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';

// Avatar-chip friend selector: a wrapping grid of avatar circles, tap to toggle, check badge on the selected ones. Controlled like [FriendSelectionList]; holds no state.
class FriendAvatarWrap extends StatelessWidget {
  const FriendAvatarWrap({
    super.key,
    required this.friends,
    required this.selectedFriendIds,
    required this.onToggle,
    this.readOnly = false,
  });

  final List<UserFriend> friends;
  final Set<String> selectedFriendIds;
  final void Function(UserFriend) onToggle;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const Center(child: Text('No friends yet'));
    }

    return Wrap(
      spacing: AppFriendChip.spacing,
      runSpacing: AppFriendChip.spacing,
      children: [for (final friend in friends) _chip(friend)],
    );
  }

  Widget _chip(UserFriend friend) {
    final profile = friend.userProfile;
    final isSelected = selectedFriendIds.contains(profile.id);
    final avatarUrl = profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return GestureDetector(
      onTap: readOnly ? null : () => onToggle(friend),
      child: SizedBox(
        width: AppFriendChip.chipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AppAvatar(
                  radius: AppFriendChip.avatarRadius,
                  image: hasAvatar ? NetworkImage(avatarUrl) : null,
                  placeholder: Icons.person,
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: AppFriendChip.badgeSize,
                      height: AppFriendChip.badgeSize,
                      decoration: BoxDecoration(
                        color: AppColors.darkButton,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.lightSection,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: AppFriendChip.badgeIconSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppFriendChip.nameGap),
            Text(
              profile.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTextSizes.caption,
                color: AppColors.lightSubtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
