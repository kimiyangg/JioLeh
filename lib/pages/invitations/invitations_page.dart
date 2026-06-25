import 'package:flutter/material.dart';
import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/invitations/invitations_page_model.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page.dart';

import 'package:jio_leh/pages/invitations/widgets/accepted_event_card.dart';
import 'package:jio_leh/pages/invitations/widgets/received_event_card.dart';
import 'package:jio_leh/pages/invitations/widgets/sent_event_card.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  late final InvitationsPageModel _model;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _model = InvitationsPageModel(
      openJio: services.openJio,
      friends: services.friends,
    )
      ..addListener(_rebuild)
      ..start();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _model
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }


  Future<void> _openJioForm() async {
    final event = await Navigator.push<OpenJioEvent>(
      context,
      MaterialPageRoute(builder: (_) => const OpenJioFormPage()),
    );

    if (event == null || !mounted) return;

    try {
      await _model.saveEvent(event);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save jio. Please try again.')),
      );
    }
  }

  Future<void> _respond(OpenJioEvent event, InviteStatus status) async {
    try {
      await _model.respondToInvite(event, status);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to respond. Please try again.')),
      );
    }
  }

  Future<void> _confirmLeave(OpenJioEvent event) async {
  final shouldLeave = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Leave this jio?'),
      content: const Text('You will leave this accepted jio.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Leave'),
        ),
      ],
    ),
  );

  if (shouldLeave != true || !mounted) return;
  await _respond(event, InviteStatus.declined);
}
    
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openJioForm,
                child: const Text('Open a Jio'),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildBody()),
            ],
      ),
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_model.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load invitations.'),
            const SizedBox(height: 8),
            TextButton(onPressed: _model.loadEvents, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView(
      children: [
        _SectionHeader(
          title: 'Sent',
          count: _model.sentEvents.length,
          expanded: _model.sentExpanded,
          onTap: _model.toggleSent,
        ),
        if (_model.sentExpanded) ...[
          if (_model.sentEvents.isEmpty)
            const _EmptyHint('No sent jios yet')
          else
            ..._model.sentEvents.map((e) => SentEventCard(event: e)),
        ],
        _SectionHeader(
          title: 'Received',
          count: _model.pendingEvents.length,
          expanded: _model.receivedExpanded,
          onTap: _model.toggleReceived,
        ),
        if (_model.receivedExpanded) ...[
          if (_model.pendingEvents.isEmpty)
            const _EmptyHint('No pending invites')
          else
            ..._model.pendingEvents.map(
              (e) => ReceivedEventCard(
                event: e,
                onAccept: () => _respond(e, InviteStatus.accepted),
                onDecline: () => _respond(e, InviteStatus.declined),
              ),
            ),
        ],
        _SectionHeader(
          title: 'Accepted',
          count: _model.acceptedEvents.length,
          expanded: _model.acceptedExpanded,
          onTap: _model.toggleAccepted,
        ),
        if (_model.acceptedExpanded) ...[
          if (_model.acceptedEvents.isEmpty)
            const _EmptyHint('No accepted jios yet')
          else
            ..._model.acceptedEvents.map(
            (e) => AcceptedEventCard(
              event: e,
              onLeave: () => _confirmLeave(e),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
              ),
            ],
            const Spacer(),
            Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }
}
                
