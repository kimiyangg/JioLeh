import 'package:flutter/widgets.dart';

import 'package:jio_leh/models/user_inserted_pin.dart';
import 'package:jio_leh/pages/map/map_page_model.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/map/widgets/location_customize_page.dart';

Future<void> addPin(BuildContext context, MapPageModel model) async {
  final position = model.currentPosition;
  if (position == null) return;

  await showLocationCustomizePage(
    context,
    PinType.restaurant,
    onSave: (customization) => model.savePin(
      UserInsertedPin(
        latitude: position.latitude,
        longitude: position.longitude,
        formalName: customization.formalName,
        customName: customization.name,
        emoji: customization.pinType.emoji,
        rating: customization.rating == 0 ? null : customization.rating,
        review: customization.review,
        isPrivate: customization.isPrivate!,
      ),
      customization.selectedPhotos,
    ),
  );
}
