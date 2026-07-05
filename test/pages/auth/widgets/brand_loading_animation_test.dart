import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';

void main() {
  group('BrandLoadingAnimation onIntroComplete', () {
    testWidgets('invokes onIntroComplete once the intro animation finishes',
        (tester) async {
      var completedCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BrandLoadingAnimation(onIntroComplete: () => completedCount++),
        ),
      );

      // Not complete yet right after the first frame.
      expect(completedCount, 0);

      // Advance past the 1500ms intro duration.
      await tester.pump(const Duration(milliseconds: 1600));
      expect(completedCount, 1);

      // Advancing further runs the idle loop — must not fire again.
      await tester.pump(const Duration(milliseconds: 2000));
      expect(completedCount, 1);
    });

    testWidgets('compact variant fires onIntroComplete after its shorter intro',
        (tester) async {
      var completedCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BrandLoadingAnimation.compact(
            onIntroComplete: () => completedCount++,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(completedCount, 1);
    });

    testWidgets('builds fine with no callback provided', (tester) async {
      // Most existing call sites don't pass onIntroComplete at all — this
      // must keep working exactly as it did before the callback was added.
      await tester.pumpWidget(const MaterialApp(home: BrandLoadingAnimation()));

      await tester.pump(const Duration(milliseconds: 1600));

      expect(tester.takeException(), isNull);
    });
  });
}
