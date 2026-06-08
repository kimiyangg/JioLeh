import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/map/widgets/pin_type_picker.dart';

// A widget test renders a widget in a fake screen and lets us tap, type, and
// check what is shown — without a real device or network.
//
// showPinTypePicker opens a bottom sheet of PinType buttons and returns the one
// the user taps (or null if they dismiss it). We test that behaviour here.
void main() {
  // Helper: builds a tiny app whose only button opens the picker, and remembers
  // whatever the picker returns so the test can assert on it.
  Widget testApp(void Function(PinType?) onResult) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          // Builder gives us a context that sits *under* MaterialApp, which the
          // bottom sheet needs.
          builder: (context) => ElevatedButton(
            onPressed: () async => onResult(await showPinTypePicker(context)),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  testWidgets('shows a button for every PinType', (tester) async {
    // pumpWidget renders the widget into the test environment.
    await tester.pumpWidget(testApp((_) {}));

    // Tap the button that opens the sheet.
    await tester.tap(find.text('open'));
    // pumpAndSettle waits for all the animations to finish, including the sheet sliding up.
    await tester.pumpAndSettle();

    expect(find.text('Choose location type'), findsOneWidget);
    // Every enum option should have its own button.
    for (final option in PinType.values) {
      expect(find.text('${option.emoji} ${option.label}'), findsOneWidget);
    }
  });

  testWidgets('returns the PinType the user taps', (tester) async {
    PinType? selected;
    // Below is the lambda simplified form
    // await tester.pumpWidget(testApp((PinType? result) {
    //   selected = result;
    // }));
    await tester.pumpWidget(testApp((result) => selected = result));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Tap the "Gym" option.
    await tester.tap(find.text('${PinType.gym.emoji} ${PinType.gym.label}'));
    await tester.pumpAndSettle();

    expect(selected, PinType.gym);
  });
}
