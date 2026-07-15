import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:jio_leh/config/vision_env.dart';
import 'package:jio_leh/services/photo_tagging_service.dart';

class GoogleVisionPhotoTaggingService extends PhotoTaggingService {
  GoogleVisionPhotoTaggingService({
    http.Client? httpClient,
    this.confidenceThreshold = 0.7,
    this.maxResults = 10,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// Labels below this score (0.0-1.0) are dropped. 0.7 matches the "only
  /// show tags above 70% confidence" bar from the feature brief.
  final double confidenceThreshold;
  final int maxResults;

  @override
  Future<List<String>> tagPhoto(Uint8List imageBytes) async {
    try {
      final uri = Uri.https(
        'vision.googleapis.com',
        '/v1/images:annotate',
        {'key': VisionEnv.googleVisionApiKey},
      );

      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Encode(imageBytes)},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': maxResults},
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['responses'] as List<dynamic>? ?? const [];
      if (results.isEmpty) return const [];

      final firstResult = results.first as Map<String, dynamic>;
      final labels =
          firstResult['labelAnnotations'] as List<dynamic>? ?? const [];

      return labels
          .cast<Map<String, dynamic>>()
          .where(
            (label) => (label['score'] as num? ?? 0) >= confidenceThreshold,
          )
          .map((label) => (label['description'] as String).toLowerCase())
          .toList();
    } catch (_) {
      return const [];
    }
  }
}