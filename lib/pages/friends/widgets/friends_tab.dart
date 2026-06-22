import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/routing/app_routing.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/pages/friends/widgets/friend_tile.dart';

// The Friends tab body: the current user's accepted friends. A dumb widget — the page loads the data and passes the [friends] in.
class FriendsTab extends StatelessWidget {
  final List<UserFriend> friends;

  const FriendsTab({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return Center(
        child: Text(
          'No friends yet',
          style: TextStyle(fontSize: context.scaledFont(AppTextSizes.body)),
        ),
      );
    }
    return ListView.separated(
      itemCount: friends.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final profile = friends[index].userProfile;
        return FriendTile(
          profile: profile,
          trailing: IconButton(
            tooltip: 'View profile',
            color: AppColors.lightSubtitle,
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                Navigator.push(context, AppRoutes.profile(profile.id)),
          ),
        );
      },
    );
  }
}
