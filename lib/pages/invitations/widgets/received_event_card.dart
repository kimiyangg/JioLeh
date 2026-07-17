import 'package:flutter/material.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/invitations/widgets/jio_card_content.dart';
import 'package:jio_leh/theme.dart';

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
      color: AppColors.lightSection,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: JioCardContent(
        event: event,
        actions: Row(
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
