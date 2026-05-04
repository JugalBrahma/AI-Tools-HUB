import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toolshub/core/config/api_constants.dart';

class PaymentIntegrationService {
  static String get _n8nWebhookUrl => ApiConstants.paymentWebhookUrl;

  /// Sends subscription data to n8n to initiate a payment session or record intent.
  /// [amount] should be in paise (e.g., 10000 for ₹100.00)
  static Future<Map<String, dynamic>?> sendPaymentDataToN8N({
    required String uid,
    required String userEmail,
    required int amountPaise,
    required String plan,
    required String currency,
    required int planDays,
    required String purchaseDate,
    required String expiryDate,
  }) async {
    // Preserve full URL context so users return to the same page after payment.
    // Strip any existing Razorpay params to avoid nesting.
    final currentUri = Uri.base;
    print('🔍 DEBUG: Uri.base = $currentUri');
    print('🔍 DEBUG: Uri.base.toString() = ${currentUri.toString()}');
    print('🔍 DEBUG: Uri.base.queryParameters = ${currentUri.queryParameters}');

    final cleanUri = currentUri.replace(
      queryParameters: Map.from(currentUri.queryParameters)
        ..remove('razorpay_payment_link_status')
        ..remove('razorpay_payment_id')
        ..remove('razorpay_payment_link_id')
        ..remove('razorpay_signature'),
    );
    final callbackUrl = cleanUri.toString();
    print('🔍 DEBUG: callbackUrl = $callbackUrl');

    print('🚀 CALLING N8N: $_n8nWebhookUrl');
    print(
      '📦 PAYLOAD: ${{'uid': uid, 'plan': plan, 'plan_days': planDays, 'purchase_date': purchaseDate, 'expiry_date': expiryDate, 'amount_paise': amountPaise, 'currency': currency, 'user_email': userEmail, 'callback_url': callbackUrl}}',
    );

    try {
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': ApiConstants.n8nApiKey,
        },
        body: jsonEncode({
          'uid': uid,
          'plan': plan,
          'plan_days': planDays,
          'purchase_date': purchaseDate,
          'expiry_date': expiryDate,
          'amount_paise': amountPaise,
          'currency': currency,
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
