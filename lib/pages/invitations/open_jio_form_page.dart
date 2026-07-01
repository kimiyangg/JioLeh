import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/services/open_jio_service.dart';
import 'package:jio_leh/pages/invitations/widgets/friend_selection_list.dart';
import 'package:jio_leh/util/datetime_format.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_dialog.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_text_field.dart';

class OpenJioFormPage extends StatefulWidget {
  const OpenJioFormPage({super.key, this.event});

  // If event is provided, the form will be in view mode and will display the event details.
  final OpenJioEvent? event;

  @override
  State<OpenJioFormPage> createState() => _OpenJioFormPageState();
}

class _OpenJioFormPageState extends State<OpenJioFormPage> {
  final Set<String> _selectedFriendIds = {};
  DateTime? _selectedDateTime;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLeaving = false;
  bool _didInit = false;

  late final OpenJioService _openJio;
  late Future<List<UserFriend>> _future;

  bool get _isViewMode => widget.event != null;
  bool get _isReceivedEvent => widget.event?.senderName != null;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final e = widget.event!;
      _selectedDateTime = e.dateTime;
      _captionController.text = e.caption;
      _locationController.text = e.locationName;
      _selectedFriendIds.addAll(e.invitedFriends.map((f) => f.userProfile.id));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _openJio = services.openJio;
    _future = widget.event != null
        ? Future.value(widget.event!.invitedFriends)
        : services.friends.getUserFriends();
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
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _toggleFriend(UserFriend friend) {
    final id = friend.userProfile.id;

    setState(() {
      if (_selectedFriendIds.contains(id)) {
        _selectedFriendIds.remove(id);
      } else {
        _selectedFriendIds.add(id);
      }
    });
  }

  Future<void> _leave() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Leave this jio?',
      message: 'You will leave this jio.',
      confirmLabel: 'Leave',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLeaving = true);
    try {
      await _openJio.respondToInvite(widget.event!.id!, InviteStatus.declined);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLeaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave. Please try again.')),
      );
    }
  }

  void _submit(List<UserFriend> friends) {
    final selectedFriends = friends
        .where((friend) => _selectedFriendIds.contains(friend.userProfile.id))
        .toList();

    Navigator.pop(
      context,
      OpenJioEvent(
        invitedFriends: selectedFriends,
        dateTime: _selectedDateTime!,
        caption: _captionController.text.trim(),
        locationName: _locationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _selectedFriendIds.isNotEmpty && _selectedDateTime != null;

    final hasFriends = !_isViewMode || widget.event!.invitedFriends.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  title: _isViewMode ? 'Jio Details' : 'Open a Jio',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<UserFriend>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: BrandLoadingAnimation.compact());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final friends = _isViewMode
                          ? (snapshot.data ?? [])
                          : (snapshot.data ?? [])
                                .where(
                                  (friend) =>
                                      friend.status ==
                                      FriendshipStatus.accepted,
                                )
                                .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isReceivedEvent) ...[
                            const AppSectionLabel(text: 'Sent by'),
                            const SizedBox(height: 8),
                            AppFieldBox(
                              height: AppFieldHeights.single,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.event!.senderName!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const AppSectionLabel(text: 'Date & Time'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _isViewMode ? null : _pickDateTime,
                            child: AppFieldBox(
                              height: AppFieldHeights.single,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _selectedDateTime != null
                                        ? formatDateTime(_selectedDateTime!)
                                        : 'Pick a date and time',
                                    style: TextStyle(
                                      fontSize: AppTextSizes.textFieldHint,
                                      color: _selectedDateTime != null
                                          ? Colors.black
                                          : Colors.grey,
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
                            readOnly: _isViewMode,
                          ),
                          const SizedBox(height: 16),
                          const AppSectionLabel(text: 'Location'),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _locationController,
                            hintText: 'Enter a location name…',
                            readOnly: _isViewMode,
                          ),
                          const SizedBox(height: 16),
                          if (hasFriends) ...[
                            AppSectionLabel(
                              text: _isReceivedEvent
                                  ? 'Also invited'
                                  : 'Invited Friends',
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: FriendSelectionList(
                                friends: friends,
                                selectedFriendIds: _selectedFriendIds,
                                onToggle: _toggleFriend,
                                readOnly: _isViewMode,
                              ),
                            ),
                          ],
                          if (!hasFriends) const Spacer(),
                          if (!_isViewMode) ...[
                            const SizedBox(height: 16),
                            AppPrimaryButton(
                              label: 'OpenJio',
                              onPressed: canSubmit
                                  ? () => _submit(friends)
                                  : null,
                            ),
                          ],
                          if (_isReceivedEvent) ...[
                            const SizedBox(height: 16),
                            AppPrimaryButton(
                              label: 'Leave',
                              onPressed: _isLeaving ? null : _leave,
                              isLoading: _isLeaving,
                              backgroundColor: AppColors.danger,
                              liftColor: AppColors.dangerShadow,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
