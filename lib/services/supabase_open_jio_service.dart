import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/open_jio_service.dart';

/// The real [OpenJioService] used in production, backed by Supabase.
/// Write a sibling class if a new backend is needed in the future.
class SupabaseOpenJioService extends OpenJioService {
  final AuthService auth;
  final SupabaseClient _client;

  // `required this.auth` stores the injected AuthService in the auth field.
  SupabaseOpenJioService({required SupabaseClient client, required this.auth})
    : _client = client;

  @override
  Future<String> saveEvent(OpenJioEvent event) async {
    final senderId = auth.getCurrentUserId();
    final friendIds = event.invitedFriends
        .map((friend) => friend.userProfile.id)
        .toList();

    // Insert the event first. This is the "anchor" row the invites depend on.
    final row = await _client
        .from('open_jio_events')
        .insert({'user_id': senderId, ...event.toMap()})
        .select()
        .single();
    final eventId = row['id'] as String;

    try {
      // Add a pending status row per invitee. If this throws, the event above is already saved.
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
    } catch (_) {
      // Compensating delete: undo the orphaned event (ON DELETE CASCADE clears any partial status rows too).
      await _client.from('open_jio_events').delete().eq('id', eventId);
      // rethrow so the caller learns the save failed instead of seeing a phantom success.
      rethrow;
    }
  }

  @override
  Future<List<OpenJioEvent>> getSentEvents(
    List<UserFriend> allFriends,
  ) async {
    final userId = auth.getCurrentUserId();
    final eventRows = await _client
        .from('open_jio_events')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (eventRows.isEmpty) return [];

    // Invitees now live only in the status table, so fetch them per event.
    final eventIds = eventRows.map((r) => r['id'] as String).toList();
    final statusRows = await _client
        .from('open_jio_invite_statuses')
        .select('event_id, invitee_id')
        .inFilter('event_id', eventIds);

    // Group invitee ids under their event.
    final inviteeIdsByEvent = <String, List<String>>{};
    for (final s in statusRows) {
      final eventId = s['event_id'] as String;
      final inviteeId = s['invitee_id'] as String;
      if (!inviteeIdsByEvent.containsKey(eventId)) {
        inviteeIdsByEvent[eventId] = [];
      }
      inviteeIdsByEvent[eventId]!.add(inviteeId);
    }

    return eventRows.map((row) {
      final ids = inviteeIdsByEvent[row['id'] as String] ?? const <String>[];
      return OpenJioEvent.fromMap(
        row,
        invitedFriends:
            allFriends.where((f) => ids.contains(f.userProfile.id)).toList(),
      );
    }).toList();
  }

  @override
  Future<List<OpenJioEvent>> getReceivedEvents() async {
    final userId = auth.getCurrentUserId();
    // Which events am I invited to? Ask the status table — my own rows are the source of truth.
    final myStatuses = await _client
        .from('open_jio_invite_statuses')
        .select('event_id, status')
        .eq('invitee_id', userId);

    if (myStatuses.isEmpty) return [];

    final eventIds = myStatuses.map((r) => r['event_id'] as String).toList();
    // Build a lookup of my status for each event.
    final statusByEvent = <String, String>{};
    for (final s in myStatuses) {
      statusByEvent[s['event_id'] as String] = s['status'] as String;
    }

    // Fetch those events (RLS allows it via the new EXISTS-over-statuses policy) and their senders.
    final eventRows = await _client
        .from('open_jio_events')
        .select()
        .inFilter('id', eventIds)
        .order('created_at', ascending: false);

    final senderIds =
        eventRows.map((r) => r['user_id'] as String).toSet().toList();
    final profileRows = await _client
        .from('profiles')
        .select('id, display_name')
        .inFilter('id', senderIds);

    // Build a lookup of sender name by id.
    final nameById = <String, String>{};
    for (final p in profileRows) {
      nameById[p['id'] as String] = p['display_name'] as String;
    }

    return eventRows.map((row) {
      final eventId = row['id'] as String;
      final senderId = row['user_id'] as String;
      final rawStatus = statusByEvent[eventId] ?? InviteStatus.pending.name;

      return OpenJioEvent.fromMap(
        row,
        senderName: nameById[senderId],
        status: InviteStatus.values.byName(rawStatus),
      );
    }).toList();
  }

  @override
  Future<void> respondToInvite(
    String eventId,
    InviteStatus status,
  ) async {
    final userId = auth.getCurrentUserId();
    final updated = await _client
        .from('open_jio_invite_statuses')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('invitee_id', userId)
        .select();

    if (updated.isEmpty) {
      throw const InviteNotFound();
    }
  }

  @override
  void Function() subscribeToInvites(void Function() onNew) {
    final userId = auth.getCurrentUserId();
    final channel = _client
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

    return () {
      channel.unsubscribe();
    };
  }
}
