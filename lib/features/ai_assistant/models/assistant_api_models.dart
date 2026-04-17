import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// Request Model
// ─────────────────────────────────────────────────────────────────────────────

class AssistantRequest {
  final String goal;
  final String budget;
  final String teamSize;
  final List<String> mustHaveFeatures;
  final List<String> preferredIntegrations;
  final String priority;
  final bool freshnessRequired;
  final List<String> avoid;

  AssistantRequest({
    required this.goal,
    required this.budget,
    required this.teamSize,
    required this.mustHaveFeatures,
    required this.preferredIntegrations,
    required this.priority,
    required this.freshnessRequired,
    required this.avoid,
  });

  Map<String, dynamic> toJson() => {
    "goal": goal,
    "budget": budget,
    "teamSize": teamSize,
    "mustHaveFeatures": mustHaveFeatures,
    "preferredIntegrations": preferredIntegrations,
    "priority": priority,
    "freshnessRequired": freshnessRequired,
    "avoid": avoid,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Response Model
// ─────────────────────────────────────────────────────────────────────────────

class AssistantResponse {
  final bool success;
  final Recommendation? topPick;
  final List<Recommendation> alternatives;

  AssistantResponse({
    required this.success,
    this.topPick,
    required this.alternatives,
  });

  factory AssistantResponse.fromJson(Map<String, dynamic> json) {
    return AssistantResponse(
      success: json['success'] ?? false,
      topPick: json['topPick'] != null ? Recommendation.fromJson(json['topPick']) : null,
      alternatives: (json['alternatives'] as List? ?? [])
          .map((i) => Recommendation.fromJson(i))
          .toList(),
    );
  }
}

class Recommendation {
  final String toolName;
  final String reason;

  Recommendation({required this.toolName, required this.reason});

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      toolName: json['toolName'] ?? 'Unknown Tool',
      reason: json['reason'] ?? 'Matches your requirements.',
    );
  }
}
