import 'package:jio_leh/models/suggested_place.dart';
import 'package:jio_leh/services/suggested_places_service.dart';

class FakeSuggestedPlacesService extends SuggestedPlacesService {
  FakeSuggestedPlacesService({this.suggestions = const []});

  List<SuggestedPlace> suggestions;
  Object? getError;

  int getSuggestedPlacesCalls = 0;
  String? lastClickedPlaceId;
  String? lastSavedPlaceId;

  @override
  Future<List<SuggestedPlace>> getSuggestedPlaces({int limit = 10}) async {
    getSuggestedPlacesCalls++;
    final error = getError;
    if (error != null) throw error;
    return suggestions.take(limit).toList();
  }

  @override
  Future<void> recordSuggestionClicked(String placeId) async {
    lastClickedPlaceId = placeId;
  }

  @override
  Future<void> recordSuggestionSaved(String placeId) async {
    lastSavedPlaceId = placeId;
  }
}
