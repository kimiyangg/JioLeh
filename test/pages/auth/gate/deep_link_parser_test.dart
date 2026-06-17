import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/auth/gate/deep_link_parser.dart';

void main() {
  test('returns the id for a valid profile link', () {
    final uri = Uri.parse('com.gijios.jioleh://profile/abc123');
    expect(profileIdFromDeepLink(uri), 'abc123');
  });

  test('returns null for a different scheme', () {
    final uri = Uri.parse('https://profile/abc123');
    expect(profileIdFromDeepLink(uri), isNull);
  });

  test('returns null for a different host', () {
    final uri = Uri.parse('com.gijios.jioleh://login-callback/abc123');
    expect(profileIdFromDeepLink(uri), isNull);
  });

  test('returns null when there is more than one path segment', () {
    final uri = Uri.parse('com.gijios.jioleh://profile/abc123/extra');
    expect(profileIdFromDeepLink(uri), isNull);
  });

  test('returns null when there is no id', () {
    final uri = Uri.parse('com.gijios.jioleh://profile');
    expect(profileIdFromDeepLink(uri), isNull);
  });
}
