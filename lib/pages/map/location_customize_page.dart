import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_selection_bar.dart';
import 'package:jio_leh/widgets/app_text_field.dart';

import 'package:jio_leh/theme.dart';

class LocationCustomization {
  final PinType pinType;
  // The official/formal name of the place (maps to places.name later).
  final String formalName;
  // The user's own preference name for the pin (maps to user_pins.custom_name).
  final String name;
  final int rating;
  final String review;
  final bool? isPrivate;
  final List<XFile> selectedPhotos;
  final List<String> photoUrls;

  const LocationCustomization({
    this.pinType = PinType.restaurant,
    this.formalName = '',
    required this.name,
    required this.rating,
    required this.review,
    this.isPrivate,
    this.selectedPhotos = const [],
    this.photoUrls = const [],
  });
}

Future<LocationCustomization?> showLocationCustomizePage(
  BuildContext context,
  PinType selectedType, {
  LocationCustomization? initialCustomization,
  bool isReadOnly = false,
  double? latitude,
  double? longitude,
  Future<void> Function(LocationCustomization customization)? onSave,
}) {
  return Navigator.of(context).push<LocationCustomization>(
    MaterialPageRoute(
      builder: (_) => LocationCustomizePage(
        selectedType: selectedType,
        initialCustomization: initialCustomization,
        isReadOnly: isReadOnly,
        latitude: latitude,
        longitude: longitude,
        onSave: onSave,
      ),
    ),
  );
}

class LocationCustomizePage extends StatefulWidget {
  final PinType selectedType;
  final LocationCustomization? initialCustomization;
  final bool isReadOnly;
  final double? latitude;
  final double? longitude;
  final Future<void> Function(LocationCustomization customization)? onSave;

  const LocationCustomizePage({
    super.key,
    required this.selectedType,
    this.initialCustomization,
    this.isReadOnly = false,
    this.latitude,
    this.longitude,
    this.onSave,
  });

  @override
  State<LocationCustomizePage> createState() => _LocationCustomizePageState();
}

class _LocationCustomizePageState extends State<LocationCustomizePage> {
  late final TextEditingController _formalNameController;
  late final TextEditingController _nameController;
  late final TextEditingController _reviewController;
  late PinType _currentType;
  late int _rating;
  late bool? _isPrivate;
  var _isSaving = false;
  bool _suggestionsFetched = false;
  bool _loadingSuggestions = false;
  List<NearbyPlace> _nearbyPlaces = const [];
  bool _suggestionsDismissed = false;

  final _imagePicker = ImagePicker();
  final _selectedPhotos = <XFile>[];

  List<String> get _existingPhotoUrls =>
      widget.initialCustomization?.photoUrls ?? const <String>[];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCustomization;
    _formalNameController = TextEditingController(
      text: initial?.formalName ?? '',
    );
    _nameController = TextEditingController(text: initial?.name ?? '');
    _reviewController = TextEditingController(text: initial?.review ?? '');
    _currentType = widget.selectedType;
    _rating = initial?.rating ?? 0;
    _isPrivate = initial?.isPrivate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchNearbySuggestions();
  }

  Future<void> _fetchNearbySuggestions() async {
    if (_suggestionsFetched || widget.isReadOnly) return;

    final latitude = widget.latitude;
    final longitude = widget.longitude;
    if (latitude == null || longitude == null) return;

    _suggestionsFetched = true;
    setState(() {
      _loadingSuggestions = true;
    });

    final places = await ServiceProvider.of(
      context,
    )!.places.getNearbyPlaces(latitude: latitude, longitude: longitude);

    if (!mounted) return;

    setState(() {
      _nearbyPlaces = places;
      _loadingSuggestions = false;
    });
  }

  static const _maxSuggestions = 5;

  List<NearbyPlace>? get _suggestionsToShow {
    if (widget.isReadOnly || _suggestionsDismissed || _nearbyPlaces.isEmpty) {
      return null;
    }
    return _nearbyPlaces.take(_maxSuggestions).toList();
  }

  void _selectSuggestion(NearbyPlace place) {
    setState(() {
      _formalNameController.text = place.name;
      _suggestionsDismissed = true;
    });
  }

  void _dismissSuggestions() {
    setState(() {
      _suggestionsDismissed = true;
    });
  }

  @override
  void dispose() {
    _formalNameController.dispose();
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_selectedPhotos.length >= 3) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
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

    if (_isPrivate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose Friends or Private.')),
      );
      return;
    }

    final customization = LocationCustomization(
      pinType: _currentType,
      formalName: _formalNameController.text.trim(),
      name: _nameController.text.trim(),
      review: _reviewController.text.trim(),
      rating: _rating,
      isPrivate: _isPrivate,
      selectedPhotos: List.unmodifiable(_selectedPhotos),
    );

    final onSave = widget.onSave;
    if (onSave == null) {
      Navigator.pop(context, customization);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await onSave(customization);

      if (!mounted) return;

      Navigator.pop(context, customization);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save location: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestionsToShow;

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
                AppPageHeader(
                  title: widget.isReadOnly
                      ? 'Location details'
                      : 'Customise location',
                ),
                const SizedBox(height: 16),
                if (!widget.isReadOnly) ...[
                  const Text(
                    'Location type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  AppSelectionBar(
                    items: [
                      for (final option in PinType.values)
                        AppSelectionItem(
                          label: '${option.emoji} ${option.label}',
                        ),
                    ],
                    selectedIndex: PinType.values.indexOf(_currentType),
                    onChanged: (index) {
                      if (_isSaving) return;
                      setState(() {
                        _currentType = PinType.values[index];
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                if (!widget.isReadOnly && _loadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                if (suggestions != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightSection,
                      borderRadius: BorderRadius.circular(AppRadii.elements),
                      boxShadow: AppShadows.field,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var index = 0; index < suggestions.length; index++)
                          InkWell(
                            onTap: () => _selectSuggestion(suggestions[index]),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: index < suggestions.length - 1
                                  ? const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Text(suggestions[index].name),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _dismissSuggestions,
                    child: Text(
                      "Can't find it? Type it in below.",
                      style: TextStyle(
                        fontSize: context.scaledFont(AppTextSizes.caption),
                        color: AppColors.lightSubtitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const AppSectionLabel(text: 'Formal location name'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _formalNameController,
                  hintText: 'Example: Springleaf Prata Place',
                  readOnly: widget.isReadOnly,
                ),

                const SizedBox(height: 12),

                const AppSectionLabel(text: 'Your name for it'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _nameController,
                  hintText: 'Example: My favourite prata place',
                  readOnly: widget.isReadOnly,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Rate this location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var star = 1; star <= 5; star++)
                      IconButton(
                        onPressed: widget.isReadOnly
                            ? null
                            : () {
                                setState(() {
                                  _rating = star;
                                });
                              },
                        icon: Icon(
                          star <= _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Visibility',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                AppSelectionBar(
                  items: const [
                    AppSelectionItem(label: 'Friends'),
                    AppSelectionItem(label: 'Private'),
                  ],
                  selectedIndex: _isPrivate == null
                      ? -1
                      : (_isPrivate! ? 1 : 0),
                  onChanged: (index) {
                    if (widget.isReadOnly || _isSaving) return;
                    setState(() {
                      _isPrivate = index == 1;
                    });
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

                const Text(
                  'Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
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
                                          onPressed: _isSaving
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
                                : OutlinedButton(
                                    onPressed: _isSaving ? null : _pickPhoto,
                                    child: const Icon(Icons.add_a_photo),
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
                  onPressed: _isSaving ? null : _onSavePressed,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
