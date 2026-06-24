import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/pages/profile/widgets/profile_card.dart';

void main() {
  const profile = UserProfile(
    id: 'u1',
    username: 'kimi',
    displayName: 'Kimi Yang',
    birthday: null,
    bio: null,
    avatarUrl: null,
  );

  // Every widget needs a MaterialApp ancestor for theme and Directionality.
  Widget wrap({required bool isOwnProfile, required bool isAlreadyFriend}) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileCard(
          profile: profile,
          isOwnProfile: isOwnProfile,
          onEdit: () {},
          onShare: () {},
          isSendingRequest: false,
          requestSent: false,
          isAlreadyFriend: isAlreadyFriend,
          onAddFriend: () {},
        ),
      ),
    );
  }

  group('ProfileCard friend action', () {
    testWidgets('an accepted friend shows a disabled Friends status, not Add',
        (tester) async {
      await tester.pumpWidget(
        wrap(isOwnProfile: false, isAlreadyFriend: true),
      );

      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Add as Friend'), findsNothing);

      // A FilledButton with a null callback reports itself as disabled.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('a non-friend shows the Add as Friend action', (tester) async {
      await tester.pumpWidget(
        wrap(isOwnProfile: false, isAlreadyFriend: false),
      );

      expect(find.text('Add as Friend'), findsOneWidget);
      expect(find.text('Friends'), findsNothing);
    });

    testWidgets('your own profile shows neither Friends nor Add', (tester) async {
      await tester.pumpWidget(
        wrap(isOwnProfile: true, isAlreadyFriend: false),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Friends'), findsNothing);
      expect(find.text('Add as Friend'), findsNothing);
    });
  });
}
