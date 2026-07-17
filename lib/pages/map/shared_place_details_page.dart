import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/map/shared_place_details_page_model.dart';
import 'package:jio_leh/pages/map/widgets/friend_pin_card.dart';
import 'package:jio_leh/pages/map/widgets/place_photo_strip.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/tag_chip_row.dart';

/// Opens the shared place details as a draggable bottom sheet
Future<void> showSharedPlaceDetailsSheet(BuildContext context, Place place) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: AppPlaceSheet.initialExtent,
      minChildSize: AppPlaceSheet.minExtent,
      maxChildSize: AppPlaceSheet.maxExtent,
      expand: false,
      builder: (context, scrollController) => SharedPlaceDetailsSheet(
        place: place,
        scrollController: scrollController,
      ),
    ),
  );
}

/// Shown when a place has been pinned by more than one friend: combines every
/// friend's rating, review, and photos for that place into a single sheet,
/// keyed by the shared/formal place name.
class SharedPlaceDetailsSheet extends StatefulWidget {
  const SharedPlaceDetailsSheet({
    super.key,
    required this.place,
    required this.scrollController,
  });

  final Place place;
  final ScrollController scrollController;

  @override
  State<SharedPlaceDetailsSheet> createState() =>
      _SharedPlaceDetailsSheetState();
}

class _SharedPlaceDetailsSheetState extends State<SharedPlaceDetailsSheet> {
  late final SharedPlaceDetailsPageModel _model;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _model = SharedPlaceDetailsPageModel(
      place: widget.place,
      account: services.account,
      pins: services.pins,
      auth: services.auth,
    )
      ..addListener(_rebuild)
      ..load();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _model
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  IconData _starIconFor(int position, double rating) {
    if (rating >= position - 0.25) return Icons.star;
    if (rating >= position - 0.75) return Icons.star_half;
    return Icons.star_border;
  }

  Widget _buildHeader() {
    final categoryLabel = PinType.fromEmoji(widget.place.category)?.label;

    return Text.rich(
      TextSpan(
        text: widget.place.name,
        style: TextStyle(
          fontSize: context.scaledFont(AppTextSizes.heading),
          fontWeight: FontWeight.w900,
          color: AppColors.lightText,
        ),
        children: [
          if (categoryLabel != null)
            TextSpan(
              text: ' · $categoryLabel',
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.label),
                fontWeight: FontWeight.bold,
                color: AppColors.lightSubtitle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double average) {
    return Row(
      children: [
        Text(
          average.toStringAsFixed(1),
          style: TextStyle(
            fontSize: context.scaledFont(AppTextSizes.body),
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(width: 6),
        for (var star = 1; star <= 5; star++)
          Icon(
            _starIconFor(star, average),
            color: Colors.amber,
            size: 20,
          ),
        const SizedBox(width: 6),
        Text(
          '(${_model.ratingCount})',
          style: TextStyle(
            fontSize: context.scaledFont(AppTextSizes.label),
            color: AppColors.lightSubtitle,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren() {
    final statusHeight =
        MediaQuery.of(context).size.height * AppPlaceSheet.initialExtent;

    if (_model.isLoading) {
      return [
        SizedBox(
          height: statusHeight,
          child: const Center(child: BrandLoadingAnimation.compact()),
        ),
      ];
    }

    if (_model.error != null) {
      return [
        SizedBox(
          height: statusHeight,
          child: Center(
            child: Text(
              'Could not load location details: ${_model.error}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    final average = _model.averageRating;

    return [
      PlacePhotoStrip(photoUrls: _model.allPhotoUrls),
      if (_model.allPhotoUrls.isNotEmpty) const SizedBox(height: 16),
      _buildHeader(),
      if (_model.allTags.isNotEmpty) ...[
        const SizedBox(height: 8),
        TagChipRow(tags: _model.allTags, scrollable: true),
      ],
      if (average != null) ...[
        const SizedBox(height: 8),
        _buildRatingRow(average),
      ],
      const SizedBox(height: 16),
      for (final entry in _model.entries) ...[
        FriendPinCard(
          profile: entry.profile,
          pin: entry.pin,
          photoUrls: entry.photoUrls,
          isCurrentUser: entry.isCurrentUser,
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.elements),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: AppPlaceSheet.handleWidth,
              height: AppPlaceSheet.handleHeight,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightSubtitle,
                borderRadius: BorderRadius.circular(
                  AppPlaceSheet.handleHeight / 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: _buildChildren(),
            ),
          ),
        ],
      ),
    );
  }
}
