import 'package:flutter/foundation.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/services/friends_service.dart';
import 'package:jio_leh/services/open_jio_service.dart';

/// Presentation state and logic for [InvitationsPage].
///
/// Call [start] once after construction to kick off the initial load and realtime subscription. Mirrors the pattern in [AuthGateModel].
class InvitationsPageModel extends ChangeNotifier {
  InvitationsPageModel({
    required this.openJio,
    required this.friends,
  });

  // Dependencies
  final OpenJioService openJio;
  final FriendsService friends;

  // States: what it holds
  List<OpenJioEvent> _sentEvents = [];
  List<OpenJioEvent> _pendingEvents = [];
  List<OpenJioEvent> _acceptedEvents = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;
  bool _disposed = false;

  // Getters: intentionally unchangable here, only readable
  List<OpenJioEvent> get sentEvents => _sentEvents;
  List<OpenJioEvent> get pendingEvents => _pendingEvents;
  List<OpenJioEvent> get acceptedEvents => _acceptedEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedTab => _selectedTab;

  void Function()? _unsubscribe;

  void start() {
    loadEvents();
    _subscribeToInvites();
  }

  Future<void> loadEvents() async {

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allFriends = await friends.getUserFriends();
      final sent = await openJio.getSentEvents(allFriends);
      final received = await openJio.getReceivedEvents();

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
    // Save event to db and get event ID
    final id = await openJio.saveEvent(event);

    if (_disposed) return;
    _sentEvents = [
      OpenJioEvent(
        id: id,
        invitedFriends: event.invitedFriends,
        dateTime: event.dateTime,
        caption: event.caption,
        locationName: event.locationName,
      ),
      // ..._sentEvents means putting the original stuff in the list back into the new list
      ..._sentEvents,
    ];
    notifyListeners();
  }

  /// Updates an edited jio, then reloads so derived fields (place category, going count) stay correct.
  ///
  /// Rethrows on failure so the page can surface a snack bar.
  Future<void> updateEvent(OpenJioEvent event) async {
    await openJio.updateEvent(event);
    if (_disposed) return;
    await loadEvents();
  }

  /// Deletes one of the current user's own jios and removes it locally.
  ///
  /// Rethrows on failure so the page can surface a snack bar.
  Future<void> deleteEvent(OpenJioEvent event) async {
    await openJio.deleteEvent(event.id!);
    if (_disposed) return;
    _sentEvents = _sentEvents.where((e) => e.id != event.id).toList();
    notifyListeners();
  }

  /// Accepts or declines [event] and immediately reflects the change locally.
  ///
  /// Rethrows on failure so the page can surface a snack bar.
  Future<void> respondToInvite(OpenJioEvent event, InviteStatus response) async {
    await openJio.respondToInvite(event.id!, response);

    if (_disposed) return;

    // remove the event in question from both the list first, and then add it to the correct list afterwards
    _pendingEvents = _pendingEvents.where((e) => e.id != event.id).toList();
    _acceptedEvents = _acceptedEvents.where((e) => e.id != event.id).toList();

    if (response == InviteStatus.accepted) {
      _acceptedEvents = [
        OpenJioEvent(
          id: event.id,
          invitedFriends: const [],
          dateTime: event.dateTime,
          caption: event.caption,
          locationName: event.locationName,
          placeId: event.placeId,
          senderId: event.senderId,
          senderName: event.senderName,
          senderAvatarUrl: event.senderAvatarUrl,
          inviteStatus: InviteStatus.accepted,
          // The server count now includes this user's freshly-accepted invite.
          goingCount: event.goingCount == null ? null : event.goingCount! + 1,
          placeCategory: event.placeCategory,
        ),
        ..._acceptedEvents,
      ];
    }
    notifyListeners();
  }

  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void _subscribeToInvites() {
    // Two Steps implemented: First subsubribe to invites, then remember where unsubscribe can be called
    _unsubscribe = openJio.subscribeToInvites(loadEvents);
  }

  @override
  void dispose() {
    _disposed = true;
    _unsubscribe?.call();
    super.dispose();
  }
}
