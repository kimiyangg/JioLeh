import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/suggested_place.dart';
import 'package:jio_leh/pages/map/widgets/suggested_places_section.dart';

import '../../../services/fakes/fake_suggested_places_service.dart';

SuggestedPlace makePlace({String id = 'p1', String name = 'Kopi Corner'}) {
  return SuggestedPlace(
    placeId: id,
    name: name,
    latitude: 1.3521,
    longitude: 103.8198,
    avgFriendRating: 4.0,
    friendCount: 2,
    pinCount: 3,
    categoryMatch: false,
    score: 1.0,
  );
}

void main() {
  Widget wrap(
    FakeSuggestedPlacesService fake, {
    ValueChanged<SuggestedPlace>? onPlaceSelected,
  }) {
    return ServiceProvider(
      suggestedPlaces: fake,
      child: MaterialApp(
        home: Scaffold(
          body: SuggestedPlacesSection(
            onPlaceSelected: onPlaceSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('SuggestedPlacesSection', () {
    testWidgets('shows an empty message when there are no suggestions',
        (tester) async {
      await tester.pumpWidget(wrap(FakeSuggestedPlacesService()));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('No suggestions yet'), findsOneWidget);
    });

    testWidgets('shows an error message when loading fails', (tester) async {
      final fake = FakeSuggestedPlacesService()
        ..getError = Exception('network down');
      await tester.pumpWidget(wrap(fake));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining("Couldn't load suggestions"), findsOneWidget);
    });

    testWidgets('renders a card per suggestion', (tester) async {
      final fake = FakeSuggestedPlacesService(suggestions: [
        makePlace(id: 'p1', name: 'Kopi Corner'),
        makePlace(id: 'p2', name: 'Laksa House'),
      ]);
      await tester.pumpWidget(wrap(fake));
      await tester.pump();
      await tester.pump();

      expect(find.text('Kopi Corner'), findsOneWidget);
      expect(find.text('Laksa House'), findsOneWidget);
    });

    testWidgets('tapping a card records the click and reports the place',
        (tester) async {
      final fake = FakeSuggestedPlacesService(
        suggestions: [makePlace(id: 'p1', name: 'Kopi Corner')],
      );
      SuggestedPlace? selected;
      await tester.pumpWidget(
        wrap(fake, onPlaceSelected: (place) => selected = place),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Kopi Corner'));

      expect(fake.lastClickedPlaceId, 'p1');
      expect(selected?.placeId, 'p1');
    });
  });
}
