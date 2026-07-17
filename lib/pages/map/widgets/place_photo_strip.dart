import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// The horizontally scrolling photo strip at the top of the shared place
/// details sheet: every friend's photos merged, first photo widest.
/// Renders nothing if [photoUrls] is empty.
class PlacePhotoStrip extends StatelessWidget {
  const PlacePhotoStrip({super.key, required this.photoUrls});

  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: AppPlaceSheet.photoStripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppPlaceSheet.photoGap),
        itemBuilder: (context, index) {
          final width = index == 0
              ? AppPlaceSheet.leadPhotoWidth
              : AppPlaceSheet.photoWidth;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.elements),
            child: Image.network(
              photoUrls[index],
              width: width,
              height: AppPlaceSheet.photoStripHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  width: width,
                  child: const ColoredBox(
                    color: Colors.black12,
                    child: Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
