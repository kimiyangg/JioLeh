import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/pages/friends/widgets/friend_tile.dart';

// The Requests tab body, split into two sections: incoming requests the user
// can accept/reject, and outgoing requests they've sent that are still pending.
// A dumb widget — the page loads the data and handles the actions.
class RequestsTab extends StatelessWidget {
  final List<UserFriend> requests; // incoming, pending — awaiting my response
  final List<UserFriend> sent; // outgoing, pending — awaiting their response
  final void Function(UserProfile) onAccept;
  final void Function(UserProfile) onReject;

  const RequestsTab({
    super.key,
    required this.requests,
    required this.sent,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty && sent.isEmpty) {
      return Center(
        child: Text(
          'No requests',
          style: TextStyle(fontSize: context.scaledFont(AppTextSizes.body)),
        ),
      );
    }
    return ListView(
      children: [
        const AppSectionLabel(text: 'Requests'),
        const SizedBox(height: 10),
        if (requests.isEmpty)
          const _EmptyNote('No incoming requests')
        else
          for (final r in requests) ...[
            FriendTile(
              profile: r.userProfile,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Accept',
                    color: AppColors.lightWidgetBackground,
                    icon: const Icon(Icons.check),
                    onPressed: () => onAccept(r.userProfile),
                  ),
                  IconButton(
                    tooltip: 'Reject',
                    color: AppColors.danger,
                    icon: const Icon(Icons.close),
                    onPressed: () => onReject(r.userProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 10),
        const AppSectionLabel(text: 'Sent'),
        const SizedBox(height: 10),
        if (sent.isEmpty)
          const _EmptyNote('No sent requests')
        else
          for (final s in sent) ...[
            FriendTile(
              profile: s.userProfile,
              trailing: Text(
                'Pending',
                style: TextStyle(
                  color: AppColors.lightSubtitle,
                  fontWeight: FontWeight.w600,
                  fontSize: context.scaledFont(AppTextSizes.label),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

// A subtle placeholder line shown when a section has no entries.
class _EmptyNote extends StatelessWidget {
  final String text;
  const _EmptyNote(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.lightSubtitle,
        fontSize: context.scaledFont(AppTextSizes.label),
      ),
    );
  }
}
