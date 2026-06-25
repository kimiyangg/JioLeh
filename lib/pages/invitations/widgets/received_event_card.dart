import 'package:flutter/material.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/datetime_format.dart';

/// Organism — a card for a pending invite, with Accept and Decline actions.
class ReceivedEventCard extends StatelessWidget {
  const ReceivedEventCard({
    super.key,
    required this.event,
    required this.onAccept,
    required this.onDecline,
  });

  final OpenJioEvent event;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        leading: const Icon(Icons.mail_outline, size: 32),
        title: Text(
          event.caption,
          style: const TextStyle(fontSize: AppTextSizes.subtitle),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created by ${event.senderName ?? 'Someone'}'),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.lightSubtitle,
                ),
                const SizedBox(width: 4),
                Expanded(child: Text(event.locationName)),
              ],
            ),
            Text(formatDateTime(event.dateTime)),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Accept',
              color: AppColors.lightWidgetBackground,
              icon: const Icon(Icons.check),
              onPressed: onAccept,
            ),
            IconButton(
              tooltip: 'Decline',
              color: AppColors.danger,
              icon: const Icon(Icons.close),
              onPressed: onDecline,
            ),
          ],
        ),
      ),
    );
  }
}
