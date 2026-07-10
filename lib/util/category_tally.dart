import 'package:jio_leh/models/user_pin.dart';

/// Picks the category most pins agree on.
///
/// Ties are broken by whichever tied category's pin was created most recently.
///
/// Returns null when [pins] is empty — there's nothing to vote on.
String? computeCategory(List<UserPin> pins) {
  if (pins.isEmpty) return null;

  final counts = <String, int>{};
  final mostRecentCreatedAt = <String, DateTime>{};

  for (final pin in pins) {
    counts[pin.emoji] = (counts[pin.emoji] ?? 0) + 1;

    final existing = mostRecentCreatedAt[pin.emoji];
    if (existing == null || pin.createdAt.isAfter(existing)) {
      mostRecentCreatedAt[pin.emoji] = pin.createdAt;
    }
  }

  String? winner;
  for (final emoji in counts.keys) {
    if (winner == null) {
      winner = emoji;
      continue;
    }

    final currentCount = counts[emoji]!;
    final winnerCount = counts[winner]!;

    if (currentCount > winnerCount) {
      winner = emoji;
    } else if (currentCount == winnerCount &&
        mostRecentCreatedAt[emoji]!.isAfter(mostRecentCreatedAt[winner]!)) {
      winner = emoji;
    }
  }

  return winner;
}
