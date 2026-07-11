import 'package:jio_leh/models/suggested_place.dart';

/// The contract for the "Suggested for You" recommendation feature. The
/// whole app depends on this, so the real Supabase service can be swapped
/// for a fake in tests.
abstract class SuggestedPlacesService {
  /// Fetches up to [limit] places friends have rated highly, ranked by the
  /// current scoring model, and logs an impression row for each one shown
  /// so engagement can be used as training data later.
  Future<List<SuggestedPlace>> getSuggestedPlaces({int limit = 10});

  /// Marks a previously-shown suggestion as clicked (the user opened it).
  Future<void> recordSuggestionClicked(String placeId);

  /// Marks a previously-shown suggestion as saved (the user pinned it).
  Future<void> recordSuggestionSaved(String placeId);
}
