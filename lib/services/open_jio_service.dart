import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';

/// The contract for Open Jio event operations. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
/// Write a sibling class if a new backend is needed in the future.
abstract class OpenJioService {
  /// Saves a new Open Jio [event] for the current user, creates a pending status
  /// row for each invitee, and returns the generated event ID.
  Future<String> saveEvent(OpenJioEvent event);

  /// Updates the current user's own [event] (matched by its id) and syncs the
  /// invitee list: newly added friends get a pending status row, removed
  /// friends have their status row deleted.
  Future<void> updateEvent(OpenJioEvent event);

  /// Deletes the current user's own event; cascades clear its invite statuses.
  Future<void> deleteEvent(String eventId);

  /// Fetches the events the current user has sent, resolving invitees against
  /// [allFriends].
  Future<List<OpenJioEvent>> getSentEvents(List<UserFriend> allFriends);

  /// Fetches the events the current user was invited to, with their invite status.
  Future<List<OpenJioEvent>> getReceivedEvents();

  /// Accepts or declines the current user's invite on [eventId].
  Future<void> respondToInvite(String eventId, InviteStatus status);

  /// Subscribes to new invites for the current user and calls [onNew] for each.
  ///
  /// Returns a function that cancels the subscription when invoked.
  void Function() subscribeToInvites(void Function() onNew);
}

/// Base class for all Open Jio related exceptions.
class OpenJioException implements Exception {
  final String message;
  const OpenJioException(this.message);
  @override
  String toString() => message;
}

/// Thrown when there is no matching invite to respond to (missing row or not the user's).
class InviteNotFound extends OpenJioException {
  const InviteNotFound() : super('No matching invite to respond to.');
}
