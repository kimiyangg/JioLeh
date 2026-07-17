import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/pages/profile/widgets/pinned_spots_section.dart';

import '../../../services/fakes/fake_auth_service.dart';
import '../../../services/fakes/fake_pin_service.dart';

final _me = User(
  id: 'me',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00.000Z',
);

Place _pinnedPlace() => const Place(
      id: 'pl1',
      name: 'Kopi Corner',
      latitude: 1.3,
      longitude: 103.8,
      pins: [UserPin(userId: 'friend-1', emoji: '🍽️')],
    );

Widget _wrap(FakePinService pins, {String? userId}) {
  return ServiceProvider(
    pins: pins,
    auth: FakeAuthService(user: _me, signedIn: true),
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PinnedSpotsSection(userId: userId),
        ),
      ),
    ),
  );
}

void main() {
  group('PinnedSpotsSection', () {
    testWidgets('own mode shows the See all link', (tester) async {
      final pins = FakePinService()..pinnedPlaces = [_pinnedPlace()];
      await tester.pumpWidget(_wrap(pins));
      await tester.pump();
      await tester.pump();

      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('friend mode hides the See all link', (tester) async {
      final pins = FakePinService()..pinnedPlaces = [_pinnedPlace()];
      await tester.pumpWidget(_wrap(pins, userId: 'friend-1'));
      await tester.pump();
      await tester.pump();

      expect(find.text('See all'), findsNothing);
      expect(find.text('Kopi Corner'), findsOneWidget);
    });

    testWidgets('own-mode empty state shows the prompt copy', (tester) async {
      await tester.pumpWidget(_wrap(FakePinService()));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Start pinning'), findsOneWidget);
    });

    testWidgets('friend-mode empty state shows the neutral copy',
        (tester) async {
      await tester.pumpWidget(_wrap(FakePinService(), userId: 'friend-1'));
      await tester.pump();
      await tester.pump();

      expect(find.text('No pinned spots yet.'), findsOneWidget);
      expect(find.textContaining('Start pinning'), findsNothing);
    });

    testWidgets('friend mode requests the passed userId', (tester) async {
      final pins = FakePinService();
      await tester.pumpWidget(_wrap(pins, userId: 'friend-1'));
      await tester.pump();
      await tester.pump();

      expect(pins.lastPinnedUserId, 'friend-1');
    });

    testWidgets('own mode requests the current user id', (tester) async {
      final pins = FakePinService();
      await tester.pumpWidget(_wrap(pins));
      await tester.pump();
      await tester.pump();

      expect(pins.lastPinnedUserId, 'me');
    });
  });
}
