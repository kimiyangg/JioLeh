import 'package:flutter/widgets.dart';

import 'package:jio_leh/models/user_inserted_pin.dart';
import 'package:jio_leh/pages/map/map_page_model.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/map/location_form_page.dart';

Future<void> addPin(BuildContext context, MapPageModel model) async {
  final position = model.currentPosition;
  if (position == null) return;

  await showLocationFormPage(
    context,
    PinType.restaurant,
    latitude: position.latitude,
    longitude: position.longitude,
    onSave: (result) => model.savePin(
      UserInsertedPin(
        latitude: result.latitude ?? position.latitude,
        longitude: result.longitude ?? position.longitude,
        formalName: result.formalName,
        customName: result.name,
        emoji: result.pinType.emoji,
        rating: result.rating == 0 ? null : result.rating,
        review: result.review,
        isPrivate: result.isPrivate!,
        provider: result.provider,
        providerPlaceId: result.providerPlaceId,
      ),
      result.selectedPhotos,
      existingPlaceId: result.existingPlaceId,
    ),
  );
}
