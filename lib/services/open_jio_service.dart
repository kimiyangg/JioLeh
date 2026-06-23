import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';

class OpenJioService {
  final SupabaseClient _client;

  const OpenJioService(this._client);

// Saves a new Open Jio event to the database, 
//creates status row for each invite, and returns the generated event ID.
  Future<String> saveEvent(
    OpenJioEvent event,
    String senderId,
  ) async {
    final friendIds = event.invitedFriends
        .map((friend) => friend.userProfile.id)
        .toList();

    final row = await _client
        .from('open_jio_events')
        .insert({
          'user_id': senderId,
          'invited_friend_ids': friendIds,
          'date_time': event.dateTime.toIso8601String(),
          'caption': event.caption,
          'location_name': event.locationName,
        })
        .select()
        .single();

    final eventId = row['id'] as String;

    await _client.from('open_jio_invite_statuses').insert(
          friendIds
              .map((id) => {
                    'event_id': eventId,
                    'invitee_id': id,
                    'status': InviteStatus.pending.name,
                  })
              .toList(),
        );

    return eventId;
  }

  Future<List<OpenJioEvent>> getSentEvents(
    String userId,
    List<UserFriend> allFriends,
  ) async {
    final rows = await _client
        .from('open_jio_events')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

      return rows.map((row) {
      final ids = List<String>.from(row['invited_friend_ids'] as List);
      return OpenJioEvent(
        id: row['id'] as String,
        invitedFriends:
            allFriends.where((f) => ids.contains(f.userProfile.id)).toList(),
        dateTime: DateTime.parse(row['date_time'] as String),
        caption: row['caption'] as String,
        locationName: row['location_name'] as String,
      );
    }).toList();
  }

  /// Fetches events the current user was invited to, with their invite status.
  Future<List<OpenJioEvent>> getReceivedEvents(String userId) async {
    final eventRows = await _client
        .from('open_jio_events')
        .select()
        .filter('invited_friend_ids', 'cs', '{$userId}')
        .order('created_at', ascending: false);

    if (eventRows.isEmpty) return [];

    final eventIds = eventRows.map((r) => r['id'] as String).toList();
    final senderIds =
        eventRows.map((r) => r['user_id'] as String).toSet().toList();

    final results = await Future.wait([
      _client
          .from('open_jio_invite_statuses')
          .select()
          .eq('invitee_id', userId)
          .inFilter('event_id', eventIds),
      _client
          .from('profiles')
          .select('id, display_name')
          .inFilter('id', senderIds),
    ]);

    final statusRows = results[0] as List<dynamic>;
    final profileRows = results[1] as List<dynamic>;

    final statusByEvent = {
      for (final s in statusRows)
        s['event_id'] as String: s['status'] as String
    };
    final nameById = {
      for (final p in profileRows)
        p['id'] as String: p['display_name'] as String,
    };

    return eventRows.map((row) {
      final eventId = row['id'] as String;
      final senderId = row['user_id'] as String;
      final rawStatus = statusByEvent[eventId] ?? InviteStatus.pending.name;

      return OpenJioEvent(
        id: eventId,
        invitedFriends: const [],
        dateTime: DateTime.parse(row['date_time'] as String),
        caption: row['caption'] as String,
        locationName: row['location_name'] as String,
        senderId: senderId,
        senderName: nameById[senderId],
        inviteStatus: InviteStatus.values.byName(rawStatus),
      );
    }).toList();
  }

  /// Accepts or declines an invite.
  Future<void> respondToInvite(
    String eventId,
    String userId,
    InviteStatus status,
  ) async {
    await _client
        .from('open_jio_invite_statuses')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('invitee_id', userId);
  }

  /// Subscribes to new invites sent to [userId] and calls [onNew] for each.
  RealtimeChannel subscribeToInvites(String userId, void Function() onNew) {
    return _client
        .channel('open_jio_invites_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'open_jio_invite_statuses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'invitee_id',
            value: userId,
          ),
          callback: (_) => onNew(),
        )
        .subscribe();
  }
}
