import 'package:flutter/material.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page.dart';
import 'package:jio_leh/pages/invitations/jio_chat_page.dart';
import 'package:jio_leh/pages/invitations/widgets/jio_card_content.dart';

import 'package:jio_leh/theme.dart';

class YourJioCard extends StatelessWidget {
  const YourJioCard({
    super.key,
    required this.event,
    this.onChanged,
    this.onEdit,
    this.onLeave,
    this.onDelete,
  });

  final OpenJioEvent event;
  final VoidCallback? onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onLeave;
  final VoidCallback? onDelete;

  bool get _isReceived => event.senderName != null;

  Future<void> _openDetails(BuildContext context) async {
    if (!_isReceived) {
      onEdit?.call();
      return;
    }
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => OpenJioFormPage(event: event)),
    );
    if (changed == true) onChanged?.call();
  }

  void _onMenuSelected(String value) {
    if (value == 'edit') {
      onEdit?.call();
    } else if (value == 'leave') {
      onLeave?.call();
    } else if (value == 'delete') {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightSection,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.elements),
        onTap: () => _openDetails(context),
        child: JioCardContent(
          event: event,
          menu: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.lightSubtitle),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => _isReceived
                ? const [
                    PopupMenuItem(
                      value: 'leave',
                      child: Text(
                        'Leave',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ]
                : const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
          ),
          actions: _ChatPill(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JioChatPage(event: event)),
            ),
          ),
        ),
      ),
    );
  }
}

// Compact white "Chat" pill, mirroring the field-box surface styling.
class _ChatPill extends StatelessWidget {
  const _ChatPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightSection,
          borderRadius: BorderRadius.circular(AppRadii.elements),
          boxShadow: AppShadows.field,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: AppColors.lightWidgetBackground,
            ),
            SizedBox(width: 6),
            Text(
              'Chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppTextSizes.label,
                color: AppColors.lightWidgetBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
