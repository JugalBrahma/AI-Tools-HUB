import 'package:toolshub/core/config/app_config.dart';

/// Centralized access to all API URLs and keys.
/// Values are loaded from `.env` via [AppConfig.init()].
class ApiConstants {
  ApiConstants._(); // prevent instantiation

  // ── URLs ──────────────────────────────────────────────────────────────
  static String get assistantWebhookUrl => AppConfig.assistantWebhookUrl;
  static String get paymentWebhookUrl  => AppConfig.paymentWebhookUrl;

  // ── Keys ──────────────────────────────────────────────────────────────
  static String get n8nApiKey => AppConfig.n8nApiKey;

  // ── Timeouts ──────────────────────────────────────────────────────────
  static const Duration defaultTimeout = Duration(minutes: 3);
}
