import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// Request Model
// ─────────────────────────────────────────────────────────────────────────────

class AssistantRequest {
  final String category;
  final String goal;
  final String budget;
  final String teamSize;
  final List<String> mustHaveFeatures;
  final String priority;
  final List<String> avoid;
  final String? referenceTool;

  AssistantRequest({
    required this.category,
    required this.goal,
    required this.budget,
    required this.teamSize,
    required this.mustHaveFeatures,
    required this.priority,
    required this.avoid,
    this.referenceTool,
  });

  Map<String, dynamic> toJson() => {
    "category": category,
    "goal": goal,
    "budget": budget,
    "teamSize": teamSize,
    "mustHaveFeatures": mustHaveFeatures,
    "priority": priority,
    "avoid": avoid,
    "referenceTool": referenceTool ?? 'None',
  };
}


// ─────────────────────────────────────────────────────────────────────────────
// Response Model
// ─────────────────────────────────────────────────────────────────────────────

class AssistantResponse {
  final bool success;
  final Recommendation? topPick;
  final List<Recommendation> alternatives;
  final List<String> missingInformation;
  final String confidenceLevel;

  AssistantResponse({
    required this.success,
    this.topPick,
    required this.alternatives,
    this.missingInformation = const [],
    this.confidenceLevel = 'Medium',
  });

  factory AssistantResponse.fromJson(dynamic json) {
    // n8n often returns a list [ { "output": { ... } } ]
    Map<String, dynamic> data;
    
    if (json is List) {
      if (json.isEmpty) throw Exception('Empty response from AI assistant');
      final firstItem = json.first as Map<String, dynamic>;
      data = firstItem['output'] ?? firstItem['data'] ?? firstItem;
    } else if (json is Map<String, dynamic>) {
      data = json['output'] ?? json['data'] ?? json;
    } else {
      throw Exception('Unexpected response format');
    }
    
    return AssistantResponse(
      success: data['success'] ?? true,
      topPick: data['top_pick'] != null ? Recommendation.fromJson(data['top_pick']) : null,
      alternatives: (data['alternatives'] as List? ?? [])
          .map((i) => Recommendation.fromJson(i))
          .toList(),
      missingInformation: List<String>.from(data['missing_information'] ?? []),
      confidenceLevel: data['confidence_level'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'top_pick': topPick?.toJson(),
    'alternatives': alternatives.map((e) => e.toJson()).toList(),
    'missing_information': missingInformation,
    'confidence_level': confidenceLevel,
  };
}

class Recommendation {
  final String toolName;
  final String url;
  final String price;
  final String fitScoreReason;
  final String whyItFits;
  final String tradeoffs;
  final String bestFor;
  final String freshnessStatus;
  final String evidenceSummary;
  final String caution;

  Recommendation({
    required this.toolName,
    required this.url,
    required this.price,
    required this.fitScoreReason,
    required this.whyItFits,
    required this.tradeoffs,
    required this.bestFor,
    required this.freshnessStatus,
    required this.evidenceSummary,
    required this.caution,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      toolName: json['toolName'] ?? json['tool_name'] ?? 'Unknown Tool',
      url: json['url'] ?? '',
      price: json['price'] ?? 'Price not specified',
      fitScoreReason: json['fit_score_reason'] ?? '',
      whyItFits: json['why_it_fits'] ?? json['reason'] ?? '',
      tradeoffs: json['tradeoffs'] ?? '',
      bestFor: json['best_for'] ?? '',
      freshnessStatus: json['freshness_status'] ?? 'unknown',
      evidenceSummary: json['evidence_summary'] ?? '',
      caution: json['caution'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'toolName': toolName,
    'url': url,
    'price': price,
    'fit_score_reason': fitScoreReason,
    'why_it_fits': whyItFits,
    'tradeoffs': tradeoffs,
    'best_for': bestFor,
    'freshness_status': freshnessStatus,
    'evidence_summary': evidenceSummary,
    'caution': caution,
  };
}
