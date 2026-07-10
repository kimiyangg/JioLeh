import 'package:flutter/material.dart';

import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';
import 'package:jio_leh/widgets/app_field_box.dart';

// A single ranked row (rank 4+) on the leaderboard: rank, avatar, name,
// points. Highlighted when it belongs to the current user.
class LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = entry.profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return AppFieldBox(
      height: 65,
      color: isCurrentUser
          ? AppColors.lightWidgetBackground.withValues(alpha: 0.12)
          : null,
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.body),
                color: AppColors.lightSubtitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppAvatar(
            radius: 18,
            image: hasAvatar ? NetworkImage(avatarUrl) : null,
            placeholder: Icons.person,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isCurrentUser ? 'You' : entry.profile.displayName,
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.body),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.stars,
                size: 16,
                color: AppColors.lightWidgetBackground,
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontSize: context.scaledFont(AppTextSizes.body),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}