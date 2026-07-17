import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/map/widgets/map_toolbar.dart';

void main() {
  // MapToolbar is a Positioned, so it must live inside a Stack.
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Stack(children: [child])));

  MapToolbar toolbar({
    VoidCallback? onRecenter,
    VoidCallback? onSuggestions,
    VoidCallback? onToggleFog,
    bool fogEnabled = true,
  }) {
    return MapToolbar(
      onRecenter: onRecenter ?? () {},
      onSuggestions: onSuggestions ?? () {},
      onToggleFog: onToggleFog ?? () {},
      fogEnabled: fogEnabled,
    );
  }

  group('MapToolbar', () {
    testWidgets('tapping the recenter button fires onRecenter', (tester) async {
      var recenters = 0;
      await tester.pumpWidget(wrap(toolbar(onRecenter: () => recenters++)));

      await tester.tap(find.byIcon(Icons.my_location));

      expect(recenters, 1);
    });

    testWidgets('tapping the suggestions button fires onSuggestions',
        (tester) async {
      var opens = 0;
      await tester.pumpWidget(wrap(toolbar(onSuggestions: () => opens++)));

      await tester.tap(find.byIcon(Icons.thumb_up));

      expect(opens, 1);
    });

    testWidgets('tapping the fog button fires onToggleFog', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(wrap(toolbar(onToggleFog: () => toggles++)));

      await tester.tap(find.byIcon(Icons.cloud));

      expect(toggles, 1);
    });

    testWidgets('fog icon is cloud when enabled', (tester) async {
      await tester.pumpWidget(wrap(toolbar(fogEnabled: true)));

      expect(find.byIcon(Icons.cloud), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });

    testWidgets('fog icon is cloud_off when disabled', (tester) async {
      await tester.pumpWidget(wrap(toolbar(fogEnabled: false)));

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsNothing);
    });
  });
}
