import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/pages/profile/models/pinned_spot_entry.dart';
import 'package:jio_leh/pages/profile/my_pinned_spots_page.dart';
import 'package:jio_leh/pages/profile/widgets/pinned_spot_card.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/pin_service.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_section_heading.dart';

const _previewCount = 4;

/// Shows a small preview grid of places the current user has pinned, with
/// a "See all" link to the full list. Only makes sense on your own profile.
class PinnedSpotsSection extends StatefulWidget {
  const PinnedSpotsSection({super.key, this.userId});

  final String? userId;

  @override
  State<PinnedSpotsSection> createState() => _PinnedSpotsSectionState();
}

class _PinnedSpotsSectionState extends State<PinnedSpotsSection> {
  late PinService _pins;
  late AuthService _auth;
  Future<List<PinnedSpotEntry>>? _future;

  bool get _isOwnProfile => widget.userId == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = ServiceProvider.of(context)!;
    _pins = services.pins;
    _auth = services.auth;
    _future ??= _loadEntries();
  }

  Future<List<PinnedSpotEntry>> _loadEntries() async {
    final userId = widget.userId ?? _auth.getCurrentUserId();
    final places = await _pins.loadPlacesPinnedByUser(userId);

    final paths = <String>[];
    for (final place in places) {
      if (place.pins.isEmpty) continue;
      final pin = place.pins.first;
      if (pin.photoPaths.isNotEmpty) {
        paths.add(pin.photoPaths.first);
      }
    }

    final urls = paths.isEmpty
        ? <String>[]
        : await _pins.createPhotoUrls(paths);

    var urlIndex = 0;
    final entries = <PinnedSpotEntry>[];
    for (final place in places) {
      if (place.pins.isEmpty) continue;
      final pin = place.pins.first;

      String? thumbnailUrl;
      if (pin.photoPaths.isNotEmpty) {
        thumbnailUrl = urls[urlIndex];
        urlIndex++;
      }

      entries.add(
        PinnedSpotEntry(place: place, pin: pin, thumbnailUrl: thumbnailUrl),
      );
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PinnedSpotEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: BrandLoadingAnimation.compact());
        }

        if (snapshot.hasError) {
          return Text(
            _isOwnProfile
                ? "Couldn't load your pinned spots."
                : "Couldn't load pinned spots.",
          );
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return Text(
            _isOwnProfile
                ? 'No pinned spots yet. Start pinning places you visit!'
                : 'No pinned spots yet.',
          );
        }

        final preview = entries.length > _previewCount
            ? entries.sublist(0, _previewCount)
            : entries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSectionHeading(
                    text: _isOwnProfile ? 'My Pins' : 'Pins',
                  ),
                ),
                if (_isOwnProfile)
                  GestureDetector(
                    onTap: () => showMyPinnedSpotsPage(context),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.lightWidgetBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                for (final entry in preview)
                  PinnedSpotCard(entry: entry),
              ],
            ),
          ],
        );
      },
    );
  }
}