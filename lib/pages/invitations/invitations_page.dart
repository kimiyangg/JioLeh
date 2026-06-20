import 'package:flutter/material.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  final List<OpenJioEvent> _events = [];

  Future<void> _openJioForm() async {
    final event = await Navigator.push<OpenJioEvent>(
      context,
      MaterialPageRoute(builder: (_) => const OpenJioFormPage()),
    );

    if (event == null || !mounted) return;

    setState(() => _events.insert(0, event));
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
          const Divider(),
          const ListTile(
            title: Text(
              'OpenJio Events',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text('No OpenJio events yet'))
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            'OpenJio sent to ${event.invitedFriends.length} friend(s)',
                          ),
                          subtitle: Text(event.friendNames),
                          leading: const Icon(Icons.markunread_mailbox),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}