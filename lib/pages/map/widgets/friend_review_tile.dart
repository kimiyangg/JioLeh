import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';

/// One friend's review of a shared place, in Google Maps review-list style:
/// avatar + name, stars, review text, then their photo thumbnails.
/// [profile] is null if the friend's profile couldn't be loaded.
class FriendReviewTile extends StatelessWidget {
  const FriendReviewTile({
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

    return Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                size: 16,
              ),
          ],
        ),
        if (review.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review,
            style: TextStyle(
              fontSize: context.scaledFont(AppTextSizes.body),
              color: AppColors.lightText,
            ),
          ),
        ],
        if (photoUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: AppPlaceSheet.reviewThumb,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoUrls.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppPlaceSheet.photoGap),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.elements),
                child: Image.network(
                  photoUrls[index],
                  width: AppPlaceSheet.reviewThumb,
                  height: AppPlaceSheet.reviewThumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: AppPlaceSheet.reviewThumb,
                      height: AppPlaceSheet.reviewThumb,
                      child: ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
