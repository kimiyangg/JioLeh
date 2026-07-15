import 'package:flutter/foundation.dart';

import 'package:jio_leh/pages/profile/models/pinned_spot_entry.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/pin_service.dart';

/// Presentation state for [MyPinnedSpotsPage].
class MyPinnedSpotsPageModel extends ChangeNotifier {
  MyPinnedSpotsPageModel({required this.pins, required this.auth});

  final PinService pins;
  final AuthService auth;

  List<PinnedSpotEntry> _entries = const [];
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;

  List<PinnedSpotEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = auth.getCurrentUserId();
      final places = await pins.loadPlacesPinnedByUser(userId);

      final paths = <String>[];
      for (final place in places) {
        if (place.pins.isEmpty) continue;
        final pin = place.pins.first;
        if (pin.photoPaths.isNotEmpty) {
          paths.add(pin.photoPaths.first);
        }
      }

      final urls = paths.isEmpty
          ? <String>[]
          : await pins.createPhotoUrls(paths);

      var urlIndex = 0;
      final entries = <PinnedSpotEntry>[];
      for (final place in places) {
        if (place.pins.isEmpty) continue;
        final pin = place.pins.first;

        String? thumbnailUrl;
        if (pin.photoPaths.isNotEmpty) {
          thumbnailUrl = urls[urlIndex];
          urlIndex++;
        }

        entries.add(
          PinnedSpotEntry(place: place, pin: pin, thumbnailUrl: thumbnailUrl),
        );
      }

      if (_disposed) return;
      _entries = entries;
      _isLoading = false;
    } catch (e, st) {
      if (_disposed) return;
      debugPrint('MyPinnedSpotsPageModel.load: $e\n$st');
      _isLoading = false;
      _error = e.toString();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}