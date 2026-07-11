import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/suggested_place.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/services/suggested_places_service.dart';
import 'package:jio_leh/theme.dart';

class SuggestedPlacesSection extends StatefulWidget {
  const SuggestedPlacesSection({super.key});

  @override
  State<SuggestedPlacesSection> createState() =>
      _SuggestedPlacesSectionState();
}

class _SuggestedPlacesSectionState extends State<SuggestedPlacesSection> {
  late final SuggestedPlacesService _suggestedPlaces;
  bool _didInit = false;

  late Future<List<SuggestedPlace>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    _suggestedPlaces = ServiceProvider.of(context)!.suggestedPlaces;
    _future = _suggestedPlaces.getSuggestedPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SuggestedPlace>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: BrandLoadingAnimation.compact());
        }
        // Suggestions are a nice-to-have; hide the section instead of
        // surfacing an error for something the user didn't explicitly ask for.
        if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
          return const SizedBox.shrink();
        }

        final places = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Suggested for You',
                style: TextStyle(
                  fontSize: context.scaledFont(AppTextSizes.subtitle),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return _SuggestedPlaceCard(
                    place: places[index],
                    onTap: () =>
                        _suggestedPlaces.recordSuggestionClicked(places[index].placeId),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestedPlaceCard extends StatelessWidget {
  const _SuggestedPlaceCard({required this.place, required this.onTap});

  final SuggestedPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rating = place.avgFriendRating?.round() ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightSection,
          borderRadius: BorderRadius.circular(AppRadii.elements),
          boxShadow: AppShadows.field,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.body),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (place.avgFriendRating != null)
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
            Text(
              '${place.friendCount} friend${place.friendCount == 1 ? '' : 's'} visited',
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.caption),
                color: AppColors.lightSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
