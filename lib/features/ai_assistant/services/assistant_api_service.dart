import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/assistant_api_models.dart';

class AssistantApiService {
  // ── Config ──────────────────────────────────────────────────────────
  // Production URL: https://n8n.srv1563394.hstgr.cloud/webhook/ai-tool-recommend
  static const String _webhookUrl =
      'https://n8n.srv1563394.hstgr.cloud/webhook-test/ai-tool-recommend/';
  static const String _apiKey = '__n8n_BLANK_VALUE_e5362baf-c777-4d57-a609-6eaf1f9e87f6';
  static const Duration _timeout = Duration(seconds: 30);

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
