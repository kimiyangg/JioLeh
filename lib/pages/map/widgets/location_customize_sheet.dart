import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/pages/map/models/pin_type.dart';

class LocationCustomization {
  final String name;
  final int rating;
  final String review;
  final List<XFile> selectedPhotos;
  final List<String> photoUrls;

  const LocationCustomization({
    required this.name,
    required this.rating,
    required this.review,
    this.selectedPhotos = const [],
    this.photoUrls = const [],
  });
}

Future<LocationCustomization?> showLocationCustomizeSheet(
  BuildContext context,
  PinType selectedType, {
    LocationCustomization? initialCustomization,
    bool isReadOnly = false,
    Future<void> Function(LocationCustomization customization)? onSave,
  }
) async {
  final nameController = TextEditingController(
    text: initialCustomization?.name ?? '',
  );
  final reviewController = TextEditingController(
    text: initialCustomization?.review ?? '',
  );
  var rating = initialCustomization?.rating ?? 0;
  var isSaving = false;

  final imagePicker = ImagePicker();
  final selectedPhotos = <XFile>[];

  final existingPhotoUrls = initialCustomization?.photoUrls ?? const <String>[];

  Future<void> pickPhoto(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) async {
    if (selectedPhotos.length >= 3) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: sheetContext,
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

    if (source == null || !sheetContext.mounted) return;

    try {
      final photo = await imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );

      if (photo == null || !sheetContext.mounted) return;

      setModalState(() {
        if (selectedPhotos.length < 3) {
          selectedPhotos.add(photo);
        }
      });
    } catch (error) {
      if (!sheetContext.mounted) return;

      ScaffoldMessenger.of(sheetContext).showSnackBar(
        SnackBar(content: Text('Could not select photo: $error')),
      );
    }
  }

  return showModalBottomSheet<LocationCustomization>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return FractionallySizedBox(
            heightFactor: 0.95,
            child: SafeArea(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isReadOnly
                            ? '${selectedType.emoji} Location details'
                            : '${selectedType.emoji} Customise location',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: nameController,
                        readOnly: isReadOnly,
                        autofocus: !isReadOnly,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Location name',
                          hintText: 'Example: My favourite prata place',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Rate this location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var star = 1; star <= 5; star++)
                            IconButton(
                              onPressed: isReadOnly
                              ? null
                              : () {
                                setModalState(() {
                                  rating = star;
                                });
                              },
                              icon: Icon(
                                star <= rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 36,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: reviewController,
                        readOnly: isReadOnly,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Review',
                          hintText: 'What did you think about this place?',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (isReadOnly && existingPhotoUrls.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No photos were added.',
                            textAlign: TextAlign.center,
                          ),
                        ),

                      if (isReadOnly && existingPhotoUrls.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final url in existingPhotoUrls)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
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

                      if (!isReadOnly)
                        Row(
                          children: [
                            for (var index = 0; index < 3; index++) ...[
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: index < selectedPhotos.length
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                File(
                                                  selectedPhotos[index].path,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: IconButton.filled(
                                                onPressed: isSaving
                                                    ? null
                                                    : () {
                                                        setModalState(() {
                                                          selectedPhotos
                                                              .removeAt(index);
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
                                          onPressed: isSaving
                                              ? null
                                              : () {
                                                  pickPhoto(
                                                    sheetContext,
                                                    setModalState,
                                                  );
                                                },
                                          child: const Icon(
                                            Icons.add_a_photo,
                                          ),
                                        ),
                                ),
                              ),
                              if (index < 2) const SizedBox(width: 8),
                            ],
                          ],
                        ),

                      const SizedBox(height: 20),

                      FilledButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (isReadOnly) {
                                  Navigator.pop(sheetContext);
                                  return;
                                }

                                final customization = LocationCustomization(
                                  name: nameController.text.trim(),
                                  review: reviewController.text.trim(),
                                  rating: rating,
                                  selectedPhotos:
                                      List.unmodifiable(selectedPhotos),
                                );

                                if (onSave == null) {
                                  Navigator.pop(
                                    sheetContext,
                                    customization,
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isSaving = true;
                                });

                                try {
                                  await onSave(customization);

                                  if (!sheetContext.mounted) return;

                                  Navigator.pop(
                                    sheetContext,
                                    customization,
                                  );
                                } catch (error) {
                                  if (!sheetContext.mounted) return;

                                  setModalState(() {
                                    isSaving = false;
                                  });

                                  ScaffoldMessenger.of(sheetContext)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not save location: $error',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isReadOnly ? 'Close' : 'Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}