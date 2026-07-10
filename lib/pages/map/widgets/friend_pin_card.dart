import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';

/// One friend's rating, review, and photos for a shared place, shown on
/// [SharedPlaceDetailsPage]. [profile] is null if the friend's profile
/// couldn't be loaded; the card falls back to a placeholder name/avatar.
class FriendPinCard extends StatelessWidget {
  const FriendPinCard({
    super.key,
    required this.profile,
    required this.pin,
    required this.photoUrls,
    required this.isCurrentUser,
  });

  final UserProfile? profile;
  final UserPin pin;
  final List<String> photoUrls;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final rating = pin.rating ?? 0;
    final review = pin.review?.trim() ?? '';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(
                  radius: 18,
                  image: hasAvatar ? NetworkImage(avatarUrl) : null,
                  placeholder: Icons.person,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    profile?.displayName ?? 'Unknown friend',
                    style: TextStyle(
                      fontSize: context.scaledFont(AppTextSizes.body),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightWidgetBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTextSizes.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  Icon(
                    star <= rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.isEmpty ? 'No review written.' : review,
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.body),
                fontStyle: review.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: review.isEmpty
                    ? AppColors.lightSubtitle
                    : AppColors.lightText,
              ),
            ),
            if (photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final url in photoUrls)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 90,
                            height: 90,
                            child: ColoredBox(
                              color: Colors.black12,
                              child: Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
