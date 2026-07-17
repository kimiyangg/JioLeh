import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/services/location_service.dart';
import 'package:jio_leh/services/open_jio_service.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page_model.dart';
import 'package:jio_leh/pages/invitations/widgets/friend_avatar_wrap.dart';
import 'package:jio_leh/util/datetime_format.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_dialog.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_map_snippet.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_secondary_button.dart';
import 'package:jio_leh/widgets/app_section_heading.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';
import 'package:jio_leh/widgets/app_text_field.dart';

class OpenJioFormPage extends StatefulWidget {
  const OpenJioFormPage({super.key, this.event});

  // If event is provided: the host gets an editable form that pops the updated event; an invitee gets a read-only view with a Leave button.
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

  late final OpenJioFormPageModel _model;

  late final OpenJioService _openJio;
  late Future<List<UserFriend>> _future;

  // Fallback map centre before a place is chosen: Singapore.
  static const _defaultLatitude = 1.3521;
  static const _defaultLongitude = 103.8198;

  bool get _isReceivedEvent => widget.event?.senderName != null;
  bool get _isOwnEvent => widget.event != null && !_isReceivedEvent;

  @override
  void dispose() {
    if (_didInit) {
      _model.removeListener(_onModelChanged);
      _model.dispose();
    }
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onModelChanged() {
    if (mounted) setState(() {});
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
    _locationController.addListener(_clearStaleSelection);
  }

  // A picked place is only valid while the text still matches it; editing the text reverts to free-text mode.
  void _clearStaleSelection() {
    final selected = _model.selectedPlace;
    if (selected == null) return;
    if (_locationController.text == selected.name) return;
    _model.clearSelectedPlace();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty || _model.isSearching) return;

    await _model.searchPlaces(query);
    if (!mounted) return;

    if (_model.searchResults.isEmpty) {
      context.showAppSnackBar('No places found. Try a different name.');
      return;
    }

    final chosen = await showModalBottomSheet<NearbyPlace>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _model.searchResults.length,
          itemBuilder: (context, index) {
            final place = _model.searchResults[index];
            return ListTile(
              title: Text(place.name),
              subtitle: place.address == null ? null : Text(place.address!),
              onTap: () => Navigator.pop(context, place),
            );
          },
        ),
      ),
    );
    if (chosen == null || !mounted) return;

    _model.selectPlace(chosen);
    _locationController.text = chosen.name;
  }

  Future<void> _popularAround() async {
    if (_model.loadingNearby) return;

    try {
      await _model.loadPopularNearby();
    } on LocationException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, kind: SnackBarKind.error);
      return;
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar(
        'Failed to load nearby places. Please try again.',
        kind: SnackBarKind.error,
      );
      return;
    }
    if (!mounted) return;

    if (_model.nearbyPopularPlaces.isEmpty) {
      context.showAppSnackBar('No popular places nearby.');
      return;
    }

    final chosen = await showModalBottomSheet<Place>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _model.nearbyPopularPlaces.length,
          itemBuilder: (context, index) {
            final place = _model.nearbyPopularPlaces[index];
            return ListTile(
              title: Text(
                place.category == null
                    ? place.name
                    : '${place.category} ${place.name}',
              ),
              subtitle: Text(
                place.pinCount == 1
                    ? 'Pinned by 1 friend'
                    : 'Pinned by ${place.pinCount} friends',
              ),
              onTap: () => Navigator.pop(context, place),
            );
          },
        ),
      ),
    );
    if (chosen == null || !mounted) return;

    _model.selectExistingPlace(chosen);
    _locationController.text = chosen.name;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _openJio = services.openJio;
    // Invitees only see who was invited; the host (and create mode) gets the full friends list so invitees can be changed.
    _future = _isReceivedEvent
        ? Future.value(widget.event!.invitedFriends)
        : services.friends.getUserFriends();
    _model = OpenJioFormPageModel(
      place: services.places,
      pins: services.pins,
      location: services.location,
    )..addListener(_onModelChanged);
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

  Future<void> _submit(List<UserFriend> friends) async {
    final selectedFriends = friends
        .where((friend) => _selectedFriendIds.contains(friend.userProfile.id))
        .toList();

    final resolvedPlaceId = await _model.resolvePlaceId();
    if (!mounted) return;

    // On edit, an untouched location keeps its original place link; changed text without a new pick becomes free-text.
    final original = widget.event;
    final locationUnchanged =
        original != null &&
        _locationController.text.trim() == original.locationName;

    Navigator.pop(
      context,
      OpenJioEvent(
        id: original?.id,
        invitedFriends: selectedFriends,
        dateTime: _selectedDateTime!,
        caption: _captionController.text.trim(),
        locationName: _locationController.text.trim(),
        placeId:
            resolvedPlaceId ?? (locationUnchanged ? original.placeId : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _selectedFriendIds.isNotEmpty && _selectedDateTime != null;

    final hasFriends =
        !_isReceivedEvent || widget.event!.invitedFriends.isNotEmpty;

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
                  title: _isReceivedEvent
                      ? 'Jio Details'
                      : (_isOwnEvent ? 'Edit Jio' : 'Open a Jio'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<UserFriend>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: BrandLoadingAnimation.compact(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final friends = _isReceivedEvent
                          ? (snapshot.data ?? [])
                          : (snapshot.data ?? [])
                                .where(
                                  (friend) =>
                                      friend.status ==
                                      FriendshipStatus.accepted,
                                )
                                .toList();

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
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
                            if (!_isReceivedEvent ||
                                _model.selectedPlace != null) ...[
                              AppMapSnippet(
                                latitude:
                                    _model.selectedPlace?.latitude ??
                                    _defaultLatitude,
                                longitude:
                                    _model.selectedPlace?.longitude ??
                                    _defaultLongitude,
                                emoji: _model.selectedPlace == null ? '' : '📍',
                                zoom: _model.selectedPlace == null
                                    ? AppMapSnip.cityZoom
                                    : AppMapSnip.zoom,
                              ),
                              const SizedBox(height: 16),
                            ],
                            const AppSectionHeading(text: 'Location'),
                            const SizedBox(height: 8),
                            AppTextField(
                              controller: _locationController,
                              hintText: 'Type a place name to search…',
                              readOnly: _isReceivedEvent,
                              onSubmitted: _isReceivedEvent
                                  ? null
                                  : _searchLocation,
                              suffixIcon: _isReceivedEvent
                                  ? null
                                  : Icons.search,
                              onSuffixTap:
                                  _isReceivedEvent || _model.isSearching
                                  ? null
                                  : () => _searchLocation(
                                      _locationController.text,
                                    ),
                            ),
                            if (!_isReceivedEvent) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppSecondaryButton(
                                      label: _model.loadingNearby
                                          ? 'Loading'
                                          : 'Popular around',
                                      icon: Icons.link,
                                      backgroundColor:
                                          AppColors.lightWidgetBackground,
                                      onPressed: _model.loadingNearby
                                          ? null
                                          : _popularAround,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            const AppSectionHeading(text: 'Date & Time'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _isReceivedEvent ? null : _pickDateTime,
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
                            const AppSectionHeading(text: 'Caption'),
                            const SizedBox(height: 8),
                            AppTextField(
                              controller: _captionController,
                              hintText: 'Add a short caption…',
                              readOnly: _isReceivedEvent,
                            ),
                            const SizedBox(height: 16),
                            if (hasFriends) ...[
                              AppSectionHeading(
                                text: _isReceivedEvent
                                    ? 'Also invited'
                                    : 'Invited Friends',
                              ),
                              const SizedBox(height: 8),
                              FriendAvatarWrap(
                                friends: friends,
                                selectedFriendIds: _selectedFriendIds,
                                onToggle: _toggleFriend,
                                readOnly: _isReceivedEvent,
                              ),
                            ],
                            if (!hasFriends) const SizedBox(height: 16),
                            if (!_isReceivedEvent) ...[
                              const SizedBox(height: 16),
                              AppPrimaryButton(
                                label: _isOwnEvent ? 'Save' : 'OpenJio',
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
                        ),
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
