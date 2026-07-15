import 'dart:typed_data';

/// The contract for turning a photo's raw bytes into descriptive tags
/// (e.g. "food", "outdoor"). The real implementation calls Google Cloud
/// Vision; tests use a fake so no network call happens.
abstract class PhotoTaggingService {
  /// Returns tag labels for [imageBytes], most-confident first. Returns an
  /// empty list if no label clears the confidence threshold.
  Future<List<String>> tagPhoto(Uint8List imageBytes);
}

class PhotoTaggingException implements Exception {
  final String message;
  const PhotoTaggingException(this.message);
  @override
  String toString() => message;
}