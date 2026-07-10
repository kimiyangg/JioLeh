import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/pages/map/shared_place_details_page_model.dart';
import 'package:jio_leh/pages/map/widgets/friend_pin_card.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_page_header.dart';

/// Pushes the combined place-details page for a [place] pinned by more than
/// one friend. Mirrors the free-function style of [showLocationFormPage].
Future<void> showSharedPlaceDetailsPage(BuildContext context, Place place) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => SharedPlaceDetailsPage(place: place)),
  );
}

/// Shown when a place has been pinned by more than one friend: combines every
/// friend's rating, review, and photos for that place into a single page,
/// keyed by the shared/formal place name.
class SharedPlaceDetailsPage extends StatefulWidget {
  const SharedPlaceDetailsPage({super.key, required this.place});

  final Place place;

  @override
  State<SharedPlaceDetailsPage> createState() =>
      _SharedPlaceDetailsPageState();
}

class _SharedPlaceDetailsPageState extends State<SharedPlaceDetailsPage> {
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

  Widget _buildBody() {
    if (_model.isLoading) {
      return const Center(child: BrandLoadingAnimation());
    }

    if (_model.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load location details: ${_model.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final pinCount = widget.place.pins.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPageHeader(title: widget.place.name),
          const SizedBox(height: 4),
          Text(
            widget.place.category == null
                ? '$pinCount friends have pinned this place'
                : '${widget.place.category} · $pinCount friends have pinned this place',
            style: TextStyle(
              fontSize: context.scaledFont(AppTextSizes.label),
              color: AppColors.lightSubtitle,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(child: _buildBody()),
    );
  }
}
