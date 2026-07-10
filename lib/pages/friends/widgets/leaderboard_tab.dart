import 'package:flutter/material.dart';

import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/pages/friends/widgets/leaderboard_podium.dart';
import 'package:jio_leh/pages/friends/widgets/leaderboard_row.dart';
import 'package:jio_leh/theme.dart';

// The Leaderboard tab body: already-loaded, already-sorted entries. A dumb
// widget — the page fetches the data and passes it in (same shape as
// FriendsTab / RequestsTab).
class LeaderboardTab extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String currentUserId;

  const LeaderboardTab({
    super.key,
    required this.entries,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No leaderboard yet',
          style: TextStyle(fontSize: context.scaledFont(AppTextSizes.body)),
        ),
      );
    }

    final top = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return ListView(
      children: [
        LeaderboardPodium(top: top, currentUserId: currentUserId),
        const SizedBox(height: 16),
        for (var i = 0; i < rest.length; i++) ...[
          LeaderboardRow(
            rank: i + 4,
            entry: rest[i],
            isCurrentUser: rest[i].profile.id == currentUserId,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}