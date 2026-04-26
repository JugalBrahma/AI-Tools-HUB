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
      topPick: data['top_pick'] != null
          ? Recommendation.fromJson(data['top_pick'], isTopPick: true)
          : null,
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

class FeatureMatch {
  final List<String> matched;
  final List<String> missing;

  FeatureMatch({this.matched = const [], this.missing = const []});

  factory FeatureMatch.fromJson(Map<String, dynamic> json) {
    return FeatureMatch(
      matched: List<String>.from(json['matched'] ?? []),
      missing: List<String>.from(json['missing'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {'matched': matched, 'missing': missing};
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

  // — new fields —
  final String freeTierReality;
  final bool budgetWarning;
  final bool soloOnly;
  final String perfectFor;
  final String skipIf;
  final String effortToValue;
  final String oneThingItDoesBest;
  final String oneThingThatWillFrustrateYou;
  final String firstThingToTry;
  final FeatureMatch? featureMatch; // top_pick only
  final bool prioritySatisfied; // top_pick only
  final String referenceToolComparison; // top_pick only

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
    this.freeTierReality = '',
    this.budgetWarning = false,
    this.soloOnly = false,
    this.perfectFor = '',
    this.skipIf = '',
    this.effortToValue = '',
    this.oneThingItDoesBest = '',
    this.oneThingThatWillFrustrateYou = '',
    this.firstThingToTry = '',
    this.featureMatch,
    this.prioritySatisfied = true,
    this.referenceToolComparison = '',
  });

  factory Recommendation.fromJson(
    Map<String, dynamic> json, {
    bool isTopPick = false,
  }) {
    return Recommendation(
      toolName: json['tool_name'] ?? json['toolName'] ?? 'Unknown Tool',
      url: json['url'] ?? '',
      price: json['price'] ?? 'Price not specified',
      fitScoreReason: json['fit_score_reason'] ?? '',
      whyItFits: json['why_it_fits'] ?? json['reason'] ?? '',
      tradeoffs: json['tradeoffs'] ?? '',
      bestFor: json['best_for'] ?? '',
      freshnessStatus: json['freshness_status'] ?? 'unknown',
      evidenceSummary: json['evidence_summary'] ?? '',
      caution: json['caution'] ?? '',
      // new fields
      freeTierReality: json['free_tier_reality'] ?? '',
      budgetWarning: json['budget_warning'] ?? false,
      soloOnly: json['solo_only'] ?? false,
      perfectFor: json['perfect_for'] ?? '',
      skipIf: json['skip_if'] ?? '',
      effortToValue: json['effort_to_value'] ?? '',
      oneThingItDoesBest: json['one_thing_it_does_best'] ?? '',
      oneThingThatWillFrustrateYou:
          json['one_thing_that_will_frustrate_you'] ?? '',
      firstThingToTry: json['first_thing_to_try'] ?? '',
      // top_pick only fields — safe to parse for alternatives too, just null
      featureMatch: json['feature_match'] != null
          ? FeatureMatch.fromJson(json['feature_match'])
          : null,
      prioritySatisfied: json['priority_satisfied'] ?? true,
      referenceToolComparison: json['reference_tool_comparison'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'tool_name': toolName,
    'url': url,
    'price': price,
    'fit_score_reason': fitScoreReason,
    'why_it_fits': whyItFits,
    'tradeoffs': tradeoffs,
    'best_for': bestFor,
    'freshness_status': freshnessStatus,
    'evidence_summary': evidenceSummary,
    'caution': caution,
    'free_tier_reality': freeTierReality,
    'budget_warning': budgetWarning,
    'solo_only': soloOnly,
    'perfect_for': perfectFor,
    'skip_if': skipIf,
    'effort_to_value': effortToValue,
    'one_thing_it_does_best': oneThingItDoesBest,
    'one_thing_that_will_frustrate_you': oneThingThatWillFrustrateYou,
    'first_thing_to_try': firstThingToTry,
    'feature_match': featureMatch?.toJson(),
    'priority_satisfied': prioritySatisfied,
    'reference_tool_comparison': referenceToolComparison,
  };
}
