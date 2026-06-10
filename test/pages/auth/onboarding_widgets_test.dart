import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/pages/auth/onboarding_widgets.dart';

void main() {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  void setScreenSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final devices = <String, Size>{
    'iPhone SE (320 wide)': const Size(320, 800),
    'iPhone 16 Pro (402 wide)': const Size(402, 874),
    'large phone (440 wide)': const Size(440, 900),
  };

  // We use September to test cuz its the longest month name
  group("ProfileForm", () {
    Widget buildForm() {
      return MaterialApp(
        home: Scaffold(
          body: ProfileForm(
            displayNameController: TextEditingController(),
            dayController: TextEditingController(),
            yearController: TextEditingController(),
            selectedMonth: 'September',
            months: months,
            onMonthChanged: (_) {},
          ),
        ),
      );
    }

    devices.forEach((name, size) {
      testWidgets('renders the form without overflow on $name', (tester) async {
        setScreenSize(tester, size);

        await tester.pumpWidget(buildForm());

        // An overflow during layout is recorded as an exception. None expected.
        expect(tester.takeException(), isNull);

        // The labels and the long month value should all be present.
        expect(find.text('YOUR NAME'), findsOneWidget);
        expect(find.text('BIRTHDAY · OPTIONAL'), findsOneWidget);
        expect(find.text('September'), findsOneWidget);
      });
    });
  });

  group('WelcomeHeader', () {
    Widget buildHeader() {
      return MaterialApp(
        home: Scaffold(
          body: WelcomeHeader(),
        ),
      );
    }

    devices.forEach((name, size) {
      testWidgets('title wraps in one line $name', (tester) async {
        setScreenSize(tester, size);
        await tester.pumpWidget(buildHeader());

        const title = "Welcome! Let's set you up";
        final finder = find.text(title);
        expect(finder, findsOneWidget);

        final renderParagraph = tester.renderObject<RenderParagraph>(finder);
        final boxes = renderParagraph.getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: title.length),
        );
        final lineCount = boxes.map((box) => box.top.round()).toSet().length;

        expect(lineCount, 1);
      });
    });
  });

}
