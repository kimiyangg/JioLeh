import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/pages/profile/profile_page.dart';
import "package:jio_leh/theme.dart";
import "package:jio_leh/widgets/app_page_header.dart";
import "package:jio_leh/widgets/app_selection_bar.dart";
import 'package:jio_leh/pages/friends/widgets/friends_tab.dart';
import 'package:jio_leh/pages/friends/widgets/requests_tab.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _friends = Services.friends;
  final _account = Services.account;

  final _searchController = TextEditingController();

  late Future<List<UserFriend>> _future;

  // The profile found by the last search, if any.
  UserProfile? _searchResult;
  bool _searching = false;

  // Which tab is selected (0 = Friends, 1 = Requests).
  int _selectedTab = 0;

  static const _items = [
    AppSelectionItem(label: 'Friends'),
    AppSelectionItem(label: 'Requests'),
    AppSelectionItem(label: 'Leaderboard'),
  ];

  @override
  void initState() {
    super.initState();
    _future = _friends.getUserFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = _friends.getUserFriends());
  }

  // Runs a friend action, shows any error, and reloads the list on success.
  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  Future<void> _search() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;
    setState(() => _searching = true);
    try {
      final result = await _account.findByUsername(username);
      if (!mounted) return;
      setState(() => _searchResult = result);
      if (result == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No user found')));
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppPageHeader(
                      title: "Friends",
                      closeBtn: false,
                    ),
                    const SizedBox(height: 5),
                    AppSelectionBar(
                      items: _items,
                      selectedIndex: _selectedTab,
                      onChanged: (i) => setState(() => _selectedTab = i),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: _buildTabBody()),
                  ]
                )
              );
            }
          )
      )
    );
  }

  // Shows the placeholder body for the selected tab.
  Widget _buildTabBody() {
    if (_selectedTab == 0) return const FriendsTab();
    if (_selectedTab == 1) return const RequestsTab();
    return const SizedBox.shrink();
  }
}
//       appBar: AppBar(title: const Text('Friends')),
//       body: Column(
//         children: [
//           // Search a user by username, then send them a friend request.
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     onSubmitted: (_) => _search(),
//                     decoration: const InputDecoration(
//                       labelText: 'Search by username',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _searching ? null : _search,
//                   icon: const Icon(Icons.search),
//                 ),
//               ],
//             ),
//           ),
//           if (_searchResult != null)
//             ListTile(
//               title: Text(_searchResult!.displayName),
//               subtitle: Text('@${_searchResult!.username}'),
//               trailing: ElevatedButton(
//                 onPressed: () => _runAction(
//                   () => _friends.sendFriendRequest(_searchResult!),
//                 ),
//                 child: const Text('Add'),
//               ),
//             ),
//           const Divider(),
//           Expanded(child: _buildList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildList() {
//     return FutureBuilder<List<UserFriend>>(
//       future: _future,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final all = snapshot.data ?? [];
//         // Only incoming pending requests belong in the Requests section; a
//         // request we sent out is still pending but must not appear as if the
//         // other user is asking us.
//         final requests = all
//             .where((f) =>
//                 f.status == FriendshipStatus.pending &&
//                 f.direction == FriendDirection.incoming)
//             .toList();
//         // Requests we sent that the other user has not accepted yet.
//         final sent = all
//             .where((f) =>
//                 f.status == FriendshipStatus.pending &&
//                 f.direction == FriendDirection.outgoing)
//             .toList();
//         final friends =
//             all.where((f) => f.status == FriendshipStatus.accepted).toList();

//         return ListView(
//           children: [
//             const ListTile(
//               title: Text(
//                 'Requests',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             if (requests.isEmpty)
//               const ListTile(title: Text('No requests'))
//             else
//               for (final r in requests)
//                 ListTile(
//                   title: Text(r.userProfile.displayName),
//                   subtitle: Text('@${r.userProfile.username}'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.check, color: Colors.green),
//                         onPressed: () => _runAction(
//                           () => _friends.acceptFriendRequest(r.userProfile),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.red),
//                         onPressed: () => _runAction(
//                           () => _friends.rejectFriendRequest(r.userProfile),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             const Divider(),
//             const ListTile(
//               title: Text(
//                 'Sent',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             if (sent.isEmpty)
//               const ListTile(title: Text('No sent requests'))
//             else
//               for (final s in sent)
//                 ListTile(
//                   title: Text(s.userProfile.displayName),
//                   subtitle: Text('@${s.userProfile.username}'),
//                   trailing: const Text('Pending'),
//                 ),
//             const Divider(),
//             const ListTile(
//               title: Text(
//                 'Friends',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             if (friends.isEmpty)
//               const ListTile(title: Text('No friends yet'))
//             else
//               for (final f in friends)
//                 ListTile(
//                   title: Text(f.userProfile.displayName),
//                   subtitle: Text('@${f.userProfile.username}'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ProfilePage(
//                                 userId: f.userProfile.id,
//                               ),
//                             ),
//                           );
//                         },
//                         child: const Text('View Profile'),
//                       ),
//                       IconButton(
//                         tooltip: 'Remove friend',
//                         icon: const Icon(
//                           Icons.person_remove,
//                           color: Colors.red,
//                         ),
//                         onPressed: () => _runAction(
//                           () => _friends.removeFriend(f.userProfile),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//           ],
//         );
//       },
//     );
//   }
// }

