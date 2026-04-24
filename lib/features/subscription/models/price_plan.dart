/// Represents a specific subscription tier with its regional pricing.
enum SubscriptionTier {
  free,
  trial,
  pro,
  test,
}

class PricePlan {
  final String currency;
  final String symbol;
  final int amountSmallest;
  final String displayPrice;
  final String countryCode;
  final SubscriptionTier tier;

  const PricePlan({
    required this.currency,
    required this.symbol,
    required this.amountSmallest,
    required this.displayPrice,
    required this.countryCode,
    required this.tier,
  });

  // ── India Region ──────────────────────────────────────────────────────────
  static const PricePlan proIndia = PricePlan(
    currency: 'INR',
    symbol: '₹',
    amountSmallest: 65700, // ₹657.00
    displayPrice: '₹657',
    countryCode: 'IN',
    tier: SubscriptionTier.pro,
  );

  static const PricePlan trialIndia = PricePlan(
    currency: 'INR',
    symbol: '₹',
    amountSmallest: 9400, // ₹94.00
    displayPrice: '₹94',
    countryCode: 'IN',
    tier: SubscriptionTier.trial,
  );

  // ── Global Region ─────────────────────────────────────────────────────────
  static const PricePlan proGlobal = PricePlan(
    currency: 'USD',
    symbol: '\$',
    amountSmallest: 700, // $7.00
    displayPrice: '\$7',
    countryCode: 'US',
    tier: SubscriptionTier.pro,
  );

  static const PricePlan trialGlobal = PricePlan(
    currency: 'USD',
    symbol: '\$',
    amountSmallest: 100, // $1.00
    displayPrice: '\$1',
    countryCode: 'US',
    tier: SubscriptionTier.trial,
  );

  // ── Test Logic ────────────────────────────────────────────────────────────
  static const PricePlan test = PricePlan(
    currency: 'INR',
    symbol: '₹',
    amountSmallest: 100, // ₹1.00
    displayPrice: '₹1 (Test)',
    countryCode: 'TEST',
    tier: SubscriptionTier.test,
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Gets the Pro plan for a region.
  static PricePlan getPro(bool isIndia) => isIndia ? proIndia : proGlobal;

  /// Gets the Trial plan for a region.
  static PricePlan getTrial(bool isIndia) => isIndia ? trialIndia : trialGlobal;

  bool get isIndia => countryCode == 'IN';
  
  // Legacy aliases for backward compatibility during refactor
  static const PricePlan india = proIndia;
  static const PricePlan global = proGlobal;
  PricePlan get toggled => isIndia ? global : india;
}
