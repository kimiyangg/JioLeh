import 'package:jio_leh/routing/deep_link_parser.dart';

/// Remembers a profile link that arrives before the app is ready to show it,
/// then hands it back once the app is ready.
///
/// This is a plain class with no Flutter code, so it can be tested on its own
/// without building any UI.
class ProfileLinkHolder {
  String? _savedId;

  /// A link arrived. Returns the profile id to open now if [isReady];
  /// otherwise saves it for later and returns null.
  String? handleLink(Uri uri, {required bool isReady}) {
    final id = profileIdFromDeepLink(uri);
    if (id == null) return null; // not a profile link
    if (isReady) return id; // ready → open now
    _savedId = id; // not ready → keep it
    return null;
  }

  /// The app just became ready. Returns the saved id once, or null if there
  /// is none.
  String? takeSavedLink() {
    final id = _savedId;
    _savedId = null;
    return id;
  }
}
