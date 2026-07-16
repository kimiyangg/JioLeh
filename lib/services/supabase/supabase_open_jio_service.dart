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
  SupabaseOpenJioService({required SupabaseClient client, required this.auth,})
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
  Future<void> updateEvent(OpenJioEvent event) async {
    final eventId = event.id!;

    // Explicit place_id so switching back to a free-text location clears the link.
    await _client
        .from('open_jio_events')
        .update({...event.toMap(), 'place_id': event.placeId})
        .eq('id', eventId);

    // Sync invitees against what is currently stored.
    final statusRows = await _client
        .from('open_jio_invite_statuses')
        .select('invitee_id')
        .eq('event_id', eventId);
    final existingIds =
        statusRows.map((r) => r['invitee_id'] as String).toSet();
    final selectedIds =
        event.invitedFriends.map((f) => f.userProfile.id).toSet();

    final addedIds = selectedIds.difference(existingIds);
    if (addedIds.isNotEmpty) {
      await _client.from('open_jio_invite_statuses').insert(
            addedIds
                .map((id) => {
                      'event_id': eventId,
                      'invitee_id': id,
                      'status': InviteStatus.pending.name,
                    })
                .toList(),
          );
    }

    final removedIds = existingIds.difference(selectedIds);
    if (removedIds.isNotEmpty) {
      await _client
          .from('open_jio_invite_statuses')
          .delete()
          .eq('event_id', eventId)
          .inFilter('invitee_id', removedIds.toList());
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _client.from('open_jio_events').delete().eq('id', eventId);
  }

  @override
  Future<List<OpenJioEvent>> getSentEvents(
    List<UserFriend> allFriends,
  ) async {
    final userId = auth.getCurrentUserId();
    final eventRows = await _client
        .from('open_jio_events')
        .select('*, places(category)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (eventRows.isEmpty) return [];

    // The current user's own avatar, shown on their sent-jio cards.
    final ownProfile = await _client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    final ownAvatarUrl = ownProfile?['avatar_url'] as String?;

    // Invitees now live only in the status table, so fetch them per event.
    final eventIds = eventRows.map((r) => r['id'] as String).toList();
    final statusRows = await _client
        .from('open_jio_invite_statuses')
        .select('event_id, invitee_id, status')
        .inFilter('event_id', eventIds);

    // Group invitee ids under their event, and count accepted invitees per event.
    final inviteeIdsByEvent = <String, List<String>>{};
    final goingCountByEvent = <String, int>{};
    for (final s in statusRows) {
      final eventId = s['event_id'] as String;
      final inviteeId = s['invitee_id'] as String;
      if (!inviteeIdsByEvent.containsKey(eventId)) {
        inviteeIdsByEvent[eventId] = [];
      }
      inviteeIdsByEvent[eventId]!.add(inviteeId);
      if (s['status'] as String == InviteStatus.accepted.name) {
        goingCountByEvent[eventId] = (goingCountByEvent[eventId] ?? 0) + 1;
      }
    }

    return eventRows.map((row) {
      final eventId = row['id'] as String;
      final ids = inviteeIdsByEvent[eventId] ?? const <String>[];
      return OpenJioEvent.fromMap(
        row,
        invitedFriends:
            allFriends.where((f) => ids.contains(f.userProfile.id)).toList(),
        // senderName stays null for own events; it doubles as the received-vs-sent discriminator.
        senderAvatarUrl: ownAvatarUrl,
        goingCount: goingCountByEvent[eventId] ?? 0,
      );
    }).toList();
  }

  @override
  Future<List<OpenJioEvent>> getReceivedEvents() async {
    final userId = auth.getCurrentUserId();
    // Which events am I invited to? My own rows are the source of truth.
    final myEventIds = await _client
        .from('open_jio_invite_statuses')
        .select('event_id')
        .eq('invitee_id', userId);

    if (myEventIds.isEmpty) return [];

    final eventIds = myEventIds.map((r) => r['event_id'] as String).toList();

    // Every invitee's status for those events (fellow invitees can see each other's status).
    final statusRows = await _client
        .from('open_jio_invite_statuses')
        .select('event_id, invitee_id, status')
        .inFilter('event_id', eventIds);

    // Build a lookup of my status per event, and an accepted-count per event.
    final statusByEvent = <String, String>{};
    final goingCountByEvent = <String, int>{};
    for (final s in statusRows) {
      final eventId = s['event_id'] as String;
      final status = s['status'] as String;
      if (s['invitee_id'] as String == userId) {
        statusByEvent[eventId] = status;
      }
      if (status == InviteStatus.accepted.name) {
        goingCountByEvent[eventId] = (goingCountByEvent[eventId] ?? 0) + 1;
      }
    }

    // Fetch those events (RLS allows it via the EXISTS-over-statuses policy) and their senders.
    final eventRows = await _client
        .from('open_jio_events')
        .select('*, places(category)')
        .inFilter('id', eventIds)
        .order('created_at', ascending: false);

    final senderIds =
        eventRows.map((r) => r['user_id'] as String).toSet().toList();
    final profileRows = await _client
        .from('profiles')
        .select('id, display_name, avatar_url')
        .inFilter('id', senderIds);

    // Build lookups of sender name/avatar by id.
    final nameById = <String, String>{};
    final avatarById = <String, String?>{};
    for (final p in profileRows) {
      nameById[p['id'] as String] = p['display_name'] as String;
      avatarById[p['id'] as String] = p['avatar_url'] as String?;
    }

    return eventRows.map((row) {
      final eventId = row['id'] as String;
      final senderId = row['user_id'] as String;
      final rawStatus = statusByEvent[eventId] ?? InviteStatus.pending.name;

      return OpenJioEvent.fromMap(
        row,
        senderName: nameById[senderId],
        senderAvatarUrl: avatarById[senderId],
        status: InviteStatus.values.byName(rawStatus),
        goingCount: goingCountByEvent[eventId] ?? 0,
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
