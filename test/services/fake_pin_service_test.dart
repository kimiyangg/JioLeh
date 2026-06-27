import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';
import 'package:jio_leh/services/pin_service.dart';

import 'fakes/fake_pin_service.dart';

void main() {
  test('FakePinService can stand in for PinService', () async {
    const place = Place(
      id: 'place-1',
      name: 'Coffee Spot',
      latitude: 1.3,
      longitude: 103.8,
    );
    final service = FakePinService(
      places: const [place],
      photoUrls: const ['signed-url'],
    );
    final PinService contract = service;

    const pin = UserInsertedPin(
      latitude: 1.3,
      longitude: 103.8,
      formalName: 'Coffee Spot',
      emoji: 'pin',
      isPrivate: false,
    );

    await contract.saveUserInsertedPin(pin, const []);
    final places = await contract.loadPlacesNearLocation(
      latitude: 1.3,
      longitude: 103.8,
      radiusKm: 2,
    );
    final urls = await contract.createPhotoUrls(const ['photo-path']);

    expect(service.saveUserInsertedPinCalls, 1);
    expect(service.lastSavedPin, pin);
    expect(service.loadPlacesNearLocationCalls, 1);
    expect(service.lastLatitude, 1.3);
    expect(service.lastLongitude, 103.8);
    expect(service.lastRadiusKm, 2);
    expect(places, const [place]);
    expect(service.createPhotoUrlsCalls, 1);
    expect(service.lastPhotoPaths, const ['photo-path']);
    expect(urls, const ['signed-url']);
  });
}
