import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_text_field.dart';
import 'package:jio_leh/pages/friends/widgets/friend_tile.dart';

// The username search field, its trigger button,
// and (when a user is found) a tile to send them a friend request.
class FriendSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool searching;
  final UserProfile? result;
  final VoidCallback onSearch;
  final void Function(UserProfile) onSendRequest;

  const FriendSearchBar({
    super.key,
    required this.controller,
    required this.searching,
    required this.result,
    required this.onSearch,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controller,
                hintText: 'Search by username',
                onSubmitted: (_) => onSearch(),
              ),
            ),
            const SizedBox(width: 10),
            _searchButton(),
          ],
        ),
        if (result != null) ...[
          const SizedBox(height: 10),
          FriendTile(
            profile: result,
            trailing: IconButton(
              tooltip: 'Send friend request',
              color: AppColors.lightWidgetBackground,
              icon: const Icon(Icons.person_add),
              onPressed: () => onSendRequest(result),
            ),
          ),
        ],
      ],
    );
  }

  // Square white button that triggers a search, or a spinner while searching.
  Widget _searchButton() {
    return GestureDetector(
      onTap: searching ? null : onSearch,
      child: SizedBox(
        width: AppFieldHeights.single,
        height: AppFieldHeights.single,
        child: AppFieldBox(
          height: AppFieldHeights.single,
          child: Center(
            child: searching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}
