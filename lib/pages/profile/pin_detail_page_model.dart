import 'package:flutter/foundation.dart';

import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/services/pin_service.dart';

/// Presentation state for [PinDetailPage]. Just resolves the pin's stored
/// photo paths into temporary display URLs.
class PinDetailPageModel extends ChangeNotifier {
  PinDetailPageModel({required this.pin, required this.pins});

  final UserPin pin;
  final PinService pins;

  List<String> _photoUrls = const [];
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;

  List<String> get photoUrls => _photoUrls;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final urls = await pins.createPhotoUrls(pin.photoPaths);

      if (_disposed) return;
      _photoUrls = urls;
      _isLoading = false;
    } catch (e, st) {
      if (_disposed) return;
      debugPrint('PinDetailPageModel.load: $e\n$st');
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