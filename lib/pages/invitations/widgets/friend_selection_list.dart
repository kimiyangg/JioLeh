import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_friend.dart';
class FriendSelectionList extends StatelessWidget {
  const FriendSelectionList({
    super.key,
    required this.friends,
    required this.selectedFriendIds,
    required this.onToggle,
  });

  final List<UserFriend> friends;
  final Set<String> selectedFriendIds;
  final void Function(UserFriend) onToggle;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const Center(child: Text('No friends yet'));
    }
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final isSelected = selectedFriendIds.contains(friend.userProfile.id);

        return ListTile(
          onTap: () => onToggle(friend),
          title: Text(friend.userProfile.displayName),
          subtitle: Text('@${friend.userProfile.username}'),
          trailing: IconButton(
            tooltip: isSelected ? 'Remove from OpenJio' : 'Add to OpenJio',
            onPressed: () => onToggle(friend),
            icon: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
          ),
        );
        // same ListTile code from the current page
      },
    );
  }
}
