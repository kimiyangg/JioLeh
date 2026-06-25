import 'package:flutter/material.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/datetime_format.dart';

class YourJioCard extends StatelessWidget {
  const YourJioCard({super.key, required this.event, this.onChanged});

  final OpenJioEvent event;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final isReceived = event.senderName != null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        onTap: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => OpenJioFormPage(event: event)),
          );
          if (changed == true) onChanged?.call();
        },
        leading: Icon(
          isReceived ? Icons.check_circle_outline : Icons.markunread_mailbox,
          size: 32,
          color: isReceived ? Colors.green : null,
        ),
        title: Text(
          event.caption,
          style: const TextStyle(fontSize: AppTextSizes.subtitle),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created by ${event.senderName ?? 'You'}'),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.lightSubtitle,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${event.locationName} · ${formatDateTime(event.dateTime)}',
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
