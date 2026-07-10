import 'package:flutter/material.dart';

import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';

// Top-3 podium for the leaderboard: rank 1 tallest/center, 2 and 3 either side.
class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntry> top; // up to 3 entries, already sorted
  final String currentUserId;

  const LeaderboardPodium({
    super.key,
    required this.top,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (top.isEmpty) return const SizedBox.shrink();

    final first = top.isNotEmpty ? top[0] : null;
    final second = top.length > 1 ? top[1] : null;
    final third = top.length > 2 ? top[2] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSection,
        borderRadius: BorderRadius.circular(AppRadii.elements),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _spot(context, second, rank: 2, height: 90)),
          Expanded(child: _spot(context, first, rank: 1, height: 130)),
          Expanded(child: _spot(context, third, rank: 3, height: 70)),
        ],
      ),
    );
  }

  Widget _spot(
    BuildContext context,
    LeaderboardEntry? entry, {
    required int rank,
    required double height,
  }) {
    if (entry == null) return const SizedBox.shrink();

    final avatarUrl = entry.profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final isCurrentUser = entry.profile.id == currentUserId;
    const medals = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medals[rank] ?? '', style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        AppAvatar(
          radius: rank == 1 ? 32 : 26,
          image: hasAvatar ? NetworkImage(avatarUrl) : null,
          placeholder: Icons.person,
        ),
        const SizedBox(height: 8),
        Text(
          isCurrentUser ? 'You' : entry.profile.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.scaledFont(AppTextSizes.label),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${entry.points} pts',
          style: TextStyle(
            fontSize: context.scaledFont(AppTextSizes.caption),
            color: AppColors.lightSubtitle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.lightWidgetBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}