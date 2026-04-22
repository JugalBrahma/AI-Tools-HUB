import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:toolshub/core/utils/html_stub.dart' if (dart.library.html) 'dart:html' as html;

class PaymentIntegrationService {
  static const String _n8nWebhookUrl = 'https://n8n.srv1563394.hstgr.cloud/webhook-test/create-payment';

  /// Sends subscription data to n8n to initiate a payment session or record intent.
  /// [amount] should be in paise (e.g., 10000 for ₹100.00)
  static Future<Map<String, dynamic>?> sendPaymentDataToN8N({
    required String uid,
    required String userEmail,
    required int amountPaise,
    required String plan,
  }) async {
    final callbackUrl = html.window.location.origin;

    print('🚀 CALLING N8N: $_n8nWebhookUrl');
    print('📦 PAYLOAD: ${{
      'uid': uid,
      'plan': plan,
      'amount_paise': amountPaise,
      'user_email': userEmail,
      'callback_url': callbackUrl,
    }}');

    try {
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': '__n8n_BLANK_VALUE_e5362baf-c777-4d57-a609-6eaf1f9e87f6',
        },
        body: jsonEncode({
          'uid': uid,
          'plan': plan,
          'amount_paise': amountPaise,
          'user_email': userEmail,
          'callback_url': callbackUrl,
        }),
      );

      print('📥 N8N STATUS: ${response.statusCode}');
      print('📥 N8N RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded = jsonDecode(response.body);
        
        // Handle if response is a List (common in n8n)
        Map<String, dynamic>? data;
        if (decoded is List && decoded.isNotEmpty) {
          data = decoded.first as Map<String, dynamic>?;
        } else if (decoded is Map<String, dynamic>) {
          data = decoded;
        }

        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ CRITICAL ERROR IN WEBHOOK: $e');
      return null;
    }
  }
}
