import 'package:flutter/material.dart';
import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/pages/invitations/invitations_page_model.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page.dart';

import 'package:jio_leh/pages/invitations/widgets/received_event_card.dart';
import 'package:jio_leh/pages/invitations/widgets/your_jio_card.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_dialog.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_selection_bar.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';

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

  Future<void> _editJio(OpenJioEvent event) async {
    final updated = await Navigator.push<OpenJioEvent>(
      context,
      MaterialPageRoute(builder: (_) => OpenJioFormPage(event: event)),
    );
    if (updated == null || !mounted) return;

    try {
      await _model.updateEvent(updated);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar(
        'Failed to save changes. Please try again.',
        kind: SnackBarKind.error,
      );
    }
  }

  Future<void> _deleteJio(OpenJioEvent event) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete this jio?',
      message: 'This removes the jio for everyone invited.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await _model.deleteEvent(event);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar(
        'Failed to delete. Please try again.',
        kind: SnackBarKind.error,
      );
    }
  }

  Future<void> _leaveJio(OpenJioEvent event) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Leave this jio?',
      message: 'You will leave this jio.',
      confirmLabel: 'Leave',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await _respond(event, InviteStatus.declined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppPageHeader(title: 'OpenJios', closeBtn: false),
                  const SizedBox(height: 12),
                  AppPrimaryButton(
                    icon: Icons.add,
                    label: 'Open a Jio',
                    onPressed: _openJioForm,
                    backgroundColor: Colors.black,
                  ),
                  const SizedBox(height: 24),
                  AppSelectionBar(
                    items: [
                      const AppSelectionItem(label: 'Your Jios'),
                      AppSelectionItem(
                        label: 'Received',
                        badgeCount: _model.pendingEvents.length,
                      ),
                    ],
                    selectedIndex: _model.selectedTab,
                    onChanged: _model.selectTab,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      return const Center(child: BrandLoadingAnimation.compact());
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
    final tab = _model.selectedTab;

    if (tab == 0) {
      final hasJios =
          _model.sentEvents.isNotEmpty || _model.acceptedEvents.isNotEmpty;
      if (!hasJios) {
        return const Center(child: Text('No jios yet'));
      }
      return ListView(
        children: [
          ..._model.sentEvents.map(
            (e) => YourJioCard(
              event: e,
              onEdit: () => _editJio(e),
              onDelete: () => _deleteJio(e),
            ),
          ),
          ..._model.acceptedEvents.map(
            (e) => YourJioCard(
              event: e,
              onChanged: _model.loadEvents,
              onLeave: () => _leaveJio(e),
            ),
          ),
        ],
      );
    }

    if (_model.pendingEvents.isEmpty) {
      return const Center(child: Text('No pending invites'));
    }
    return ListView(
      children: _model.pendingEvents
          .map((e) => ReceivedEventCard(
                event: e,
                onAccept: () => _respond(e, InviteStatus.accepted),
                onDecline: () => _respond(e, InviteStatus.declined),
              ))
          .toList(),
    );
  }
}
                
