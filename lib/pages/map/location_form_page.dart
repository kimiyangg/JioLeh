import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jio_leh/widgets/app_map_snippet.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/map/location_form_page_model.dart';
import 'package:jio_leh/pages/map/models/location_form_result.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/services/pin_service.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_secondary_button.dart';
import 'package:jio_leh/widgets/app_section_heading.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_selection_bar.dart';
import 'package:jio_leh/widgets/app_text_field.dart';

import 'package:jio_leh/theme.dart';

Future<LocationFormResult?> showLocationFormPage(
  BuildContext context,
  PinType selectedType, {
  LocationFormResult? initialValue,
  bool isReadOnly = false,
  double? latitude,
  double? longitude,
  Future<void> Function(LocationFormResult result)? onSave,
}) {
  return Navigator.of(context).push<LocationFormResult>(
    MaterialPageRoute(
      builder: (_) => LocationFormPage(
        selectedType: selectedType,
        initialValue: initialValue,
        isReadOnly: isReadOnly,
        latitude: latitude,
        longitude: longitude,
        onSave: onSave,
      ),
    ),
  );
}

class LocationFormPage extends StatefulWidget {
  final PinType selectedType;
  final LocationFormResult? initialValue;
  final bool isReadOnly;
  final double? latitude;
  final double? longitude;
  final Future<void> Function(LocationFormResult result)? onSave;

  const LocationFormPage({
    super.key,
    required this.selectedType,
    this.initialValue,
    this.isReadOnly = false,
    this.latitude,
    this.longitude,
    this.onSave,
  });

  @override
  State<LocationFormPage> createState() => _LocationFormPageState();
}

class _LocationFormPageState extends State<LocationFormPage> {
  late final LocationFormPageModel _model;
  bool _didInit = false;

  late final TextEditingController _formalNameController;
  late final TextEditingController _nameController;
  late final TextEditingController _reviewController;

  final _imagePicker = ImagePicker();
  final _selectedPhotos = <XFile>[];

  List<String> get _existingPhotoUrls =>
      widget.initialValue?.photoUrls ?? const <String>[];

  bool get _canSearchPlaces => !widget.isReadOnly && _model.canSearchPlaces;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _formalNameController = TextEditingController(
      text: initial?.formalName ?? '',
    );
    _nameController = TextEditingController(text: initial?.name ?? '');
    _reviewController = TextEditingController(text: initial?.review ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Services come from the provider, which can't be read in initState. Do the
    // one-time setup here (didChangeDependencies can fire more than once).
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _model = LocationFormPageModel(
      place: services.places,
      pins: services.pins,
      selectedType: widget.selectedType,
      initialValue: widget.initialValue,
      latitude: widget.latitude,
      longitude: widget.longitude,
    )..addListener(_onModelChanged);

    _model.start();
  }

  void _onModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_didInit) {
      _model.removeListener(_onModelChanged);
      _model.dispose();
    }
    _formalNameController.dispose();
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _onFindNearbyPressed() async {
    if (_model.suggestionsFetched) {
      _showNearbySheet();
      return;
    }

    await _model.onFindNearbyPressed();
    if (!mounted) return;

    _showNearbySheet();
  }

  void _showNearbySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        if (_model.nearbyPlaces.isEmpty) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSectionHeading(text: 'Nearby places'),
                  SizedBox(height: 16),
                  Center(child: Text('No nearby places found.')),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: AppSectionHeading(text: 'Nearby places'),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final place in _model.nearbyPlaces)
                        ListTile(
                          title: Text(place.name),
                          subtitle: place.address == null
                              ? null
                              : Text(place.address!),
                          onTap: () {
                            _selectSuggestion(place);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectSuggestion(NearbyPlace place) {
    _formalNameController.text = place.name;
    _model.selectSuggestion(place);
  }

  Future<void> _onLinkExistingPressed() async {
    if (_model.existingPlacesFetched) {
      _showExistingPlacesSheet();
      return;
    }

    await _model.onLinkExistingPressed();
    if (!mounted) return;

    _showExistingPlacesSheet();
  }

  void _showExistingPlacesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        if (_model.existingPlaces.isEmpty) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSectionHeading(text: 'Existing places'),
                  SizedBox(height: 16),
                  Center(child: Text('No existing places found nearby.')),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: AppSectionHeading(text: 'Existing places'),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final place in _model.existingPlaces)
                        ListTile(
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
                          onTap: () {
                            _selectExistingPlace(place);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectExistingPlace(Place place) {
    _formalNameController.text = place.name;
    _model.selectExistingPlace(place);
  }

  void _resetPlaceSelection() {
    _formalNameController.clear();
    _model.resetPlaceSelection();
  }

  Future<void> _pickPhoto() async {
    if (_selectedPhotos.length >= 3) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !mounted) return;

    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );

      if (photo == null || !mounted) return;

      setState(() {
        if (_selectedPhotos.length < 3) {
          _selectedPhotos.add(photo);
        }
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not select photo: $error')));
    }
  }

  Future<void> _onSavePressed() async {
    if (widget.isReadOnly) {
      Navigator.pop(context);
      return;
    }

    LocationFormResult? result;
    try {
      result = await _model.save(
        formalName: _formalNameController.text.trim(),
        name: _nameController.text.trim(),
        review: _reviewController.text.trim(),
        selectedPhotos: _selectedPhotos,
        onSave: widget.onSave,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error is PinException
          ? error.toString()
          : 'Could not save location: $error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose Friends or Private.')),
      );
      return;
    }

    Navigator.pop(context, result);
  }

  Widget _buildChosenPlaceCard() {
    final sourceLabel = _model.placeSourceLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightSection,
        borderRadius: BorderRadius.circular(AppRadii.elements),
        boxShadow: AppShadows.field,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formalNameController.text,
                  style: const TextStyle(
                    fontSize: AppTextSizes.textFieldHint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sourceLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sourceLabel,
                    style: const TextStyle(
                      fontSize: AppTextSizes.caption,
                      color: AppColors.lightSubtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightSubtitle,
            ),
            onPressed: _model.isSaving ? null : _resetPlaceSelection,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChosenPlace = _model.hasChosenPlace(_formalNameController.text);
    final lat = _model.markerLatitude;
    final lng = _model.markerLongitude;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppPageHeader(title: "Customize Location"),
                const SizedBox(height: 16),
                if (lat != null && lng != null) ...[
                  AppMapSnippet(
                    latitude: lat, 
                    longitude: lng, 
                    emoji: _model.currentType.emoji
                  ),
                  const SizedBox(height: 16),
                ],
                const AppSectionHeading(text: 'Location'),
                const SizedBox(height: 10),
                if (widget.isReadOnly || !_canSearchPlaces) ...[
                  AppTextField(
                    controller: _formalNameController,
                    hintText: 'Example: National University of Singapore',
                    readOnly: widget.isReadOnly,
                  ),
                ] else if (hasChosenPlace) ...[
                  _buildChosenPlaceCard(),
                ] else if (_model.isEnteringManually) ...[
                  AppTextField(
                    controller: _formalNameController,
                    hintText: 'Pin on your current location',
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.lightSubtitle,
                    ),
                    onPressed: _model.isSaving ? null : _resetPlaceSelection,
                    child: const Text(
                      'Search instead',
                      style: TextStyle(
                        decoration: TextDecoration.underline
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: _model.loadingSuggestions
                              ? 'Finding nearby'
                              : 'Find nearby',
                          icon: Icons.near_me,
                          onPressed: _model.loadingSuggestions
                              ? null
                              : _onFindNearbyPressed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppSecondaryButton(
                          label: _model.loadingExistingPlaces
                              ? 'Linking'
                              : 'Popular around',
                          icon: Icons.link,
                          backgroundColor: Colors.black,
                          onPressed: _model.loadingExistingPlaces
                              ? null
                              : _onLinkExistingPressed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.lightSubtitle,
                      ),
                      onPressed: _model.enterManually,
                      child: const Text(
                        "Can't find the place you want? Add it manually",
                        style: TextStyle(
                          decoration: TextDecoration.underline
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                if (!widget.isReadOnly) ...[
                  const AppSectionHeading(text: 'Location details'),
                  const SizedBox(height: 8),
                  const AppSectionLabel(text: 'Catagory'),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: _model.isTypeLocked ? AppOpacity.disabled : 1,
                    child: IgnorePointer(
                      ignoring: _model.isTypeLocked,
                      child: AppSelectionBar(
                        rows: 2,
                        items: [
                          for (final option in PinType.values)
                            AppSelectionItem(
                              label: '${option.emoji} ${option.label}',
                            ),
                        ],
                        selectedIndex: PinType.values.indexOf(_model.currentType),
                        onChanged: (index) {
                          if (_model.isSaving) return;
                          _model.setCurrentType(PinType.values[index]);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const AppSectionLabel(text: 'Your name for it'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _nameController,
                  hintText: 'Example: My favourite prata place',
                  readOnly: widget.isReadOnly,
                ),

                const SizedBox(height: 20),

                const AppSectionLabel(text: 'Your Rating'),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var star = 1; star <= 5; star++)
                      IconButton(
                        onPressed: widget.isReadOnly
                            ? null
                            : () => _model.setRating(star),
                        icon: Icon(
                          star <= _model.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                const AppSectionLabel(text: 'Visibility'),

                const SizedBox(height: 8),

                AppSelectionBar(
                  items: const [
                    AppSelectionItem(label: 'Friends'),
                    AppSelectionItem(label: 'Private'),
                  ],
                  selectedIndex: _model.isPrivate == null
                      ? -1
                      : (_model.isPrivate! ? 1 : 0),
                  onChanged: (index) {
                    if (widget.isReadOnly || _model.isSaving) return;
                    _model.setIsPrivate(index == 1);
                  },
                ),

                const SizedBox(height: 20),

                const AppSectionLabel(text: 'Review'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _reviewController,
                  hintText: 'What did you think about this place?',
                  readOnly: widget.isReadOnly,
                  height: 120,
                  maxLines: 5,
                ),

                const SizedBox(height: 20),

                const AppSectionHeading(text: 'Photos'),
                const SizedBox(height: 8),

                if (widget.isReadOnly && _existingPhotoUrls.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No photos were added.',
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (widget.isReadOnly && _existingPhotoUrls.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final url in _existingPhotoUrls)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 100,
                                height: 100,
                                child: ColoredBox(
                                  color: Colors.black12,
                                  child: Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                if (!widget.isReadOnly)
                  Row(
                    children: [
                      for (var index = 0; index < 3; index++) ...[
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: index < _selectedPhotos.length
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_selectedPhotos[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: IconButton.filled(
                                          onPressed: _model.isSaving
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _selectedPhotos.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: _model.isSaving ? null : _pickPhoto,
                                    child: const AppFieldBox(
                                      child: Center(
                                        child: Icon(Icons.add_a_photo),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        if (index < 2) const SizedBox(width: 8),
                      ],
                    ],
                  ),

                const SizedBox(height: 20),

                AppPrimaryButton(
                  label: widget.isReadOnly ? 'Close' : 'Save',
                  onPressed: _model.isSaving ? null : _onSavePressed,
                  isLoading: _model.isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
