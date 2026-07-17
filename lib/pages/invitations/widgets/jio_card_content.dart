import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/map/shared_place_details_page.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/datetime_format.dart';
import 'package:jio_leh/widgets/app_avatar.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';

// Organism — the shared body of a jio card: sender header, time pill, caption,
// place preview, and the going row. [actions] is the trailing slot (Chat pill
// for YourJioCard, Accept/Decline for ReceivedEventCard); [menu] is the
// optional three-dots overflow menu in the header corner.
class JioCardContent extends StatelessWidget {
  const JioCardContent({
    super.key,
    required this.event,
    required this.actions,
    this.menu,
  });

  final OpenJioEvent event;
  final Widget actions;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = event.senderAvatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Padding(
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
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: event.senderName ?? 'You',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    children: const [
                      TextSpan(
                        text: ' opened a jio',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: AppTextSizes.body),
                ),
              ),
              ?menu,
            ],
          ),
          const SizedBox(height: 10),
          _TimePill(dateTime: event.dateTime),
          const SizedBox(height: 10),
          Text(event.caption),
          const SizedBox(height: 12),
          _PlacePreview(event: event),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _GoingRow(event: event)),
              actions,
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.dateTime});

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final label = formatRelativeDateTime(dateTime);
    final icon = label.startsWith('Tonight')
        ? Icons.nightlight_round
        : Icons.schedule;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.darkButton,
        borderRadius: BorderRadius.circular(AppRadii.elements),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: AppTextSizes.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacePreview extends StatelessWidget {
  const _PlacePreview({required this.event});

  final OpenJioEvent event;

  // Opens the shared place-details page (friends' pins for this place). Only possible when the jio links a places row; free-text locations have nothing to open.
  Future<void> _openPlace(BuildContext context) async {
    final pins = ServiceProvider.of(context)!.pins;

    try {
      final place = await pins.loadPlaceById(event.placeId!);
      if (place == null || !context.mounted) return;
      showSharedPlaceDetailsSheet(context, place);
    } catch (_) {
      if (!context.mounted) return;
      context.showAppSnackBar(
        'Could not load place details.',
        kind: SnackBarKind.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = event.placeCategory;
    final categoryLabel = PinType.fromEmoji(category)?.label;
    final hasPlace = event.placeId != null;

    return GestureDetector(
      onTap: hasPlace ? () => _openPlace(context) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mintSection,
          borderRadius: BorderRadius.circular(AppRadii.elements),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightSection,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: category == null
                    ? const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.lightSubtitle,
                      )
                    : Text(category, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (categoryLabel != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.lightSubtitle,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          categoryLabel,
                          style: const TextStyle(
                            fontSize: AppTextSizes.caption,
                            color: AppColors.lightSubtitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasPlace)
              const Icon(Icons.chevron_right, color: AppColors.lightSubtitle),
          ],
        ),
      ),
    );
  }
}

class _GoingRow extends StatelessWidget {
  const _GoingRow({required this.event});

  final OpenJioEvent event;

  @override
  Widget build(BuildContext context) {
    final goingCount = event.goingCount;
    if (goingCount == null) return const SizedBox.shrink();

    final isAccepted = event.inviteStatus == InviteStatus.accepted;
    final label = isAccepted && goingCount > 0
        ? 'You + ${goingCount - 1} going'
        : '$goingCount going';

    return Row(
      children: [
        _AvatarStack(event: event),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppTextSizes.caption,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSubtitle,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.event});

  final OpenJioEvent event;

  // Sender avatar for received cards; first few invitees for your own cards.
  List<String?> get _avatarUrls {
    if (event.senderName != null) return [event.senderAvatarUrl];
    return event.invitedFriends
        .take(3)
        .map((UserFriend f) => f.userProfile.avatarUrl)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _avatarUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    const diameter = 26.0;
    const overlap = 17.0;

    return SizedBox(
      height: diameter,
      width: diameter + (urls.length - 1) * overlap,
      child: Stack(
        children: [
          for (var i = 0; i < urls.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightSection, width: 2),
                ),
                child: AppAvatar(
                  radius: (diameter - 4) / 2,
                  image: urls[i] == null || urls[i]!.isEmpty
                      ? null
                      : NetworkImage(urls[i]!),
                  placeholder: Icons.person,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
