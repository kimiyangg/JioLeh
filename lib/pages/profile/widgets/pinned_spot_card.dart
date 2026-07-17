import 'package:flutter/material.dart';

import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/profile/models/pinned_spot_entry.dart';
import 'package:jio_leh/theme.dart';

/// A single card in the "My Pinned Spots" grid. Shows the pin's photo (or a
/// plain color block if it has none), the user's own star rating, the place
/// name, and its category.
class PinnedSpotCard extends StatelessWidget {
  const PinnedSpotCard({super.key, required this.entry});

  final PinnedSpotEntry entry;

  @override
  Widget build(BuildContext context) {
    final name = entry.pin.customName ?? entry.place.name;
    final categoryLabel = PinType.fromEmoji(entry.place.category)?.label;
    final rating = entry.pin.rating;
    final thumbnailUrl = entry.thumbnailUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.elements),
          child: Stack(
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: thumbnailUrl == null
                    ? const ColoredBox(color: AppColors.lightSection)
                    : Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: AppColors.lightSection,
                          );
                        },
                      ),
              ),
              if (rating != null)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTextSizes.caption,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.scaledFont(AppTextSizes.body),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (categoryLabel != null)
          Text(
            categoryLabel,
            style: TextStyle(
              fontSize: context.scaledFont(AppTextSizes.label),
              color: AppColors.lightSubtitle,
            ),
          ),
      ],
    );
  }
}
