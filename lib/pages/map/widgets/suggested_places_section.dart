import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/suggested_place.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/services/suggested_places_service.dart';
import 'package:jio_leh/theme.dart';

class SuggestedPlacesSection extends StatefulWidget {
  const SuggestedPlacesSection({super.key, required this.onPlaceSelected});

  final ValueChanged<SuggestedPlace> onPlaceSelected;

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

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Suggested for You',
        style: TextStyle(
          fontSize: context.scaledFont(AppTextSizes.subtitle),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _message(BuildContext context, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.scaledFont(AppTextSizes.body),
              color: AppColors.lightSubtitle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SuggestedPlace>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: BrandLoadingAnimation.compact()),
          );
        }
        if (snapshot.hasError) {
          return _message(
            context,
            "Couldn't load suggestions. Try again later.",
          );
        }

        final places = snapshot.data ?? [];
        if (places.isEmpty) {
          return _message(
            context,
            'No suggestions yet. Add friends and start pinning places!',
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return _SuggestedPlaceCard(
                    place: places[index],
                    onTap: () {
                      _suggestedPlaces
                          .recordSuggestionClicked(places[index].placeId);
                      widget.onPlaceSelected(places[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
