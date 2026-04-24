import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get assistantWebhookUrl =>
      dotenv.env['N8N_ASSISTANT_WEBHOOK_URL'] ?? '';

  static String get paymentWebhookUrl =>
      dotenv.env['N8N_PAYMENT_WEBHOOK_URL'] ?? '';

  static String get n8nApiKey => dotenv.env['N8N_API_KEY'] ?? '';

  /// Initialize the configuration (load .env)
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}
