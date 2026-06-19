import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/services/services.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  final _friends = Services.friends;
  final Set<String> _selectedFriendIds = {};

  late Future<List<UserFriend>> _future;

  @override
  void initState() {
    super.initState();
    _future = _friends.getUserFriends();
  }

  void _toggleFriend(UserFriend friend) {
    final friendId = friend.userProfile.id;

    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        _selectedFriendIds.add(friendId);
      }
    });
  }

  void _openJio() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<UserFriend>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final friends = (snapshot.data ?? [])
                    .where((friend) => friend.status == FriendshipStatus.accepted)
                    .toList();

                if (friends.isEmpty) {
                  return const Center(child: Text('No friends yet'));
                }

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isSelected = _selectedFriendIds.contains(
                      friend.userProfile.id,
                    );

                    return ListTile(
                      onTap: () => _toggleFriend(friend),
                      title: Text(friend.userProfile.displayName),
                      subtitle: Text('@${friend.userProfile.username}'),
                      trailing: IconButton(
                        tooltip: isSelected
                            ? 'Remove from invitation'
                            : 'Add to invitation',
                        onPressed: () => _toggleFriend(friend),
                        icon: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openJio,
                child: const Text('Open Jio'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}