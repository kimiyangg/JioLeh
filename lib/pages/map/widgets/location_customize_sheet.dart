import 'package:flutter/material.dart';

import 'package:jio_leh/pages/map/models/pin_type.dart';

class LocationCustomization {
  final String name;
  final int rating;
  final String review;

  const LocationCustomization({
    required this.name,
    required this.rating,
    required this.review,
  });
}

Future<LocationCustomization?> showLocationCustomizeSheet(
  BuildContext context,
  PinType selectedType,
) async {
  final nameController = TextEditingController();
  final reviewController = TextEditingController();
  var rating = 0;

  return showModalBottomSheet<LocationCustomization>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
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
                        '${selectedType.emoji} Customise location',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: nameController,
                        autofocus: true,
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
                              onPressed: () {
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

                      const SizedBox(height: 16),

                      FilledButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            LocationCustomization(
                              name: nameController.text.trim(),
                              review: reviewController.text.trim(),
                              rating: rating,
                            ),
                          );
                        },
                        child: const Text('Enter'),
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