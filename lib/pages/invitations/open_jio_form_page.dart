import 'package:flutter/material.dart';

import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/pages/invitations/widgets/friend_selection_list.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_text_field.dart';

import 'package:jio_leh/widgets/app_field_box.dart';



class OpenJioFormPage extends StatefulWidget {
  const OpenJioFormPage({super.key});

  @override
  State<OpenJioFormPage> createState() => _OpenJioFormPageState();
}

class _OpenJioFormPageState extends State<OpenJioFormPage> {
  final _friends = Services.friends;
  final Set<String> _selectedFriendIds = {};
  DateTime? _selectedDateTime;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late Future<List<UserFriend>> _future;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _future = _friends.getUserFriends();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
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

  void _openJio(List<UserFriend> friends) {
    final selectedFriends = friends
        .where((friend) => _selectedFriendIds.contains(friend.userProfile.id))
        .toList();

    Navigator.pop(
      context,
      OpenJioEvent(invitedFriends: selectedFriends,
       dateTime: _selectedDateTime!,
        caption: _captionController.text.trim(),
        locationName: _locationController.text.trim()),
    );
  } 

  String _formatDateTime(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$day, ${dt.day} $month · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _selectedFriendIds.isNotEmpty && _selectedDateTime != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open a Jio'),
      ),
      body: FutureBuilder<List<UserFriend>>(
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionLabel(text: 'Date & Time'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: AppFieldBox(
                        height: AppFieldHeights.single,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _selectedDateTime != null
                                  ? _formatDateTime(_selectedDateTime!)
                                  : 'Pick a date and time',
                              style: TextStyle(
                                fontSize: AppTextSizes.textFieldHint,
                                color: _selectedDateTime != null ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const AppSectionLabel(text: 'Caption'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _captionController,
                      hintText: 'Add a short caption…',
                    ),
                    const SizedBox(height: 16),
                    const AppSectionLabel(text: 'Location'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _locationController,
                      hintText: 'Enter a location name…',), 
                      const SizedBox(height: 16),
                    const AppSectionLabel(text: 'Invite Friends'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: FriendSelectionList(
                  friends: friends,
                  selectedFriendIds: _selectedFriendIds,
                  onToggle: _toggleFriend,
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: AppPrimaryButton(
                  label: 'OpenJio',
                  onPressed: canSubmit ? () => _openJio(friends) : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
