import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';
import 'package:jio_leh/services/open_jio_service.dart';

/// Presentation state and logic for [InvitationsPage].
///
/// Call [start] once after construction to kick off the initial load and
/// realtime subscription. Mirrors the pattern in [AuthGateModel].
class InvitationsPageModel extends ChangeNotifier {
  InvitationsPageModel({
    required this.openJio,
    required this.friends,
    required this.auth,
  });

  final OpenJioService openJio;
  final FriendsService friends;
  final AuthService auth;

  List<OpenJioEvent> _sentEvents = [];
  List<OpenJioEvent> _pendingEvents = [];
  List<OpenJioEvent> _acceptedEvents = [];
  bool _isLoading = true;
  String? _error;
  bool _sentExpanded = true;
  bool _receivedExpanded = true;
  bool _acceptedExpanded = true;
  bool _disposed = false;

  List<OpenJioEvent> get sentEvents => _sentEvents;
  List<OpenJioEvent> get pendingEvents => _pendingEvents;
  List<OpenJioEvent> get acceptedEvents => _acceptedEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get sentExpanded => _sentExpanded;
  bool get receivedExpanded => _receivedExpanded;
  bool get acceptedExpanded => _acceptedExpanded;

  RealtimeChannel? _channel;

  void start() {
    loadEvents();
    _subscribeToInvites();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = auth.getCurrentUserId();
      final allFriends = await friends.getUserFriends();
      final sent = await openJio.getSentEvents(userId, allFriends);
      final received = await openJio.getReceivedEvents(userId);

      if (_disposed) return;
      _sentEvents = sent;
      _pendingEvents =
          received.where((e) => e.inviteStatus == InviteStatus.pending).toList();
      _acceptedEvents =
          received.where((e) => e.inviteStatus == InviteStatus.accepted).toList();
      _isLoading = false;
    } catch (e, st) {
      if (_disposed) return;
      debugPrint('InvitationsPageModel.loadEvents: $e\n$st');
      _isLoading = false;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Saves a newly-created jio and prepends it to [sentEvents].
  ///
  /// Rethrows on failure so the page can surface a snack bar.
  Future<void> saveEvent(OpenJioEvent event) async {
    final userId = auth.getCurrentUserId();
    final id = await openJio.saveEvent(event, userId);

    if (_disposed) return;
    _sentEvents = [
      OpenJioEvent(
        id: id,
        invitedFriends: event.invitedFriends,
        dateTime: event.dateTime,
        caption: event.caption,
        locationName: event.locationName,
      ),
      ..._sentEvents,
    ];
    notifyListeners();
  }

  /// Accepts or declines [event] and immediately reflects the change locally.
  ///
  /// Rethrows on failure so the page can surface a snack bar.
  Future<void> respondToInvite(OpenJioEvent event, InviteStatus response) async {
    final userId = auth.getCurrentUserId();
    await openJio.respondToInvite(event.id!, userId, response);

    if (_disposed) return;
    _pendingEvents = _pendingEvents.where((e) => e.id != event.id).toList();
    if (response == InviteStatus.accepted) {
      _acceptedEvents = [
        OpenJioEvent(
          id: event.id,
          invitedFriends: const [],
          dateTime: event.dateTime,
          caption: event.caption,
          locationName: event.locationName,
          senderId: event.senderId,
          senderName: event.senderName,
          inviteStatus: InviteStatus.accepted,
        ),
        ..._acceptedEvents,
      ];
    }
    notifyListeners();
  }

  void toggleSent() => _toggle(() => _sentExpanded = !_sentExpanded);
  void toggleReceived() => _toggle(() => _receivedExpanded = !_receivedExpanded);
  void toggleAccepted() => _toggle(() => _acceptedExpanded = !_acceptedExpanded);

  void _toggle(void Function() update) {
    update();
    notifyListeners();
  }

  void _subscribeToInvites() {
    final userId = auth.getCurrentUserId();
    _channel = openJio.subscribeToInvites(userId, loadEvents);
  }

  @override
  void dispose() {
    _disposed = true;
    _channel?.unsubscribe();
    super.dispose();
  }
}
