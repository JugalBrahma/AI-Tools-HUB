import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:toolshub/core/config/app_config.dart';
import '../models/assistant_api_models.dart';

class AssistantApiService {
  // ── Config ──────────────────────────────────────────────────────────
  static final String _webhookUrl = AppConfig.assistantWebhookUrl;
  static final String _apiKey = AppConfig.n8nApiKey;
  static const Duration _timeout = Duration(minutes: 3);

  /// Sends the prompt and filters to the n8n webhook.
  Future<AssistantResponse> getRecommendations(AssistantRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(_webhookUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': _apiKey,
              'Accept': 'application/json',
              'User-Agent': 'FlutterApp/1.0',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      print('[API] Response Status: ${response.statusCode}');
      print('[API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return AssistantResponse.fromJson(decoded);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection.');
    } on http.ClientException {
      throw Exception('Request failed: Could not reach the server.');
    } catch (e) {
      if (e.toString().contains('Timeout')) {
        throw Exception('Request timed out. The AI is taking too long.');
      }
      throw Exception('Oops: ${e.toString()}');
    }
  }
}
