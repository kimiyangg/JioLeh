import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';

class OpenJioService {
  final SupabaseClient _client;

  OpenJioService(this._client);

  Future<void> saveOpenJioEvent(
    OpenJioEvent event,
    String userId,
  ) async {
    final friendIds = event.invitedFriends
        .map((friend) => friend.userProfile.id)
        .toList();

    await _client.from('open_jio_events').insert({
      'user_id': userId,
      'invited_friend_ids': friendIds,
      'date_time': event.dateTime.toIso8601String(),
      'caption': event.caption,
      'location_name': event.locationName,
    });
  }

  Future<List<OpenJioEvent>> getUserOpenJioEvents(
    String userId,
    List<UserFriend> allFriends,
  ) async {
    final response = await _client
        .from('open_jio_events')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final events = (response as List).map((data) {
      final friendIds = List<String>.from(data['invited_friend_ids'] as List);
      final invitedFriends = allFriends
          .where((friend) => friendIds.contains(friend.userProfile.id))
          .toList();

      return OpenJioEvent(
        invitedFriends: invitedFriends,
        dateTime: DateTime.parse(data['date_time'] as String),
        caption: data['caption'] as String,
        locationName: data['location_name'] as String,
      );
    }).toList();

    return events;
  }
}