import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/auth/gate/profile_link_holder.dart';

void main() {
  // A real profile deep link, and a link that is not a profile link.
  final profileUri = Uri.parse('com.gijios.jioleh://profile/abc123');
  final otherUri = Uri.parse('com.gijios.jioleh://login-callback/');

  test('opens immediately when the app is ready', () {
    final holder = ProfileLinkHolder();

    expect(holder.handleLink(profileUri, isReady: true), 'abc123');
    // It returned the id straight away, so nothing was saved.
    expect(holder.takeSavedLink(), isNull);
  });

  test('saves when not ready, then releases the id once', () {
    final holder = ProfileLinkHolder();

    // Not ready yet: it saves the id and opens nothing now.
    expect(holder.handleLink(profileUri, isReady: false), isNull);
    // Becoming ready: the saved id comes back...
    expect(holder.takeSavedLink(), 'abc123');
    // ...but only once.
    expect(holder.takeSavedLink(), isNull);
  });

  test('ignores links that are not profile links', () {
    final holder = ProfileLinkHolder();

    expect(holder.handleLink(otherUri, isReady: false), isNull);
    expect(holder.takeSavedLink(), isNull); // nothing was saved
  });

  test('takeSavedLink is null when nothing is saved', () {
    final holder = ProfileLinkHolder();

    expect(holder.takeSavedLink(), isNull);
  });
}
