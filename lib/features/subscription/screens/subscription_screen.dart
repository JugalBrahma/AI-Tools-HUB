import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart';
import 'package:toolshub/features/subscription/services/payment_integration_service.dart';
import 'package:toolshub/features/subscription/models/price_plan.dart';
import 'package:toolshub/core/navigation/app_navigator.dart';
import 'package:toolshub/core/utils/html_stub.dart'
    if (dart.library.html) 'dart:html'
    as html;

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback onDismiss;

  const SubscriptionScreen({super.key, required this.onDismiss});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isProcessing = false;
  String? _processingPlan;
  late PricePlan _activePlan;

  @override
  void initState() {
    super.initState();
    _activePlan = _detectPlan();
  }

  /// Detects India via locale country code → all locales → IST timezone offset.
  PricePlan _detectPlan() {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    if (dispatcher.locale.countryCode == 'IN') return PricePlan.india;
    if (dispatcher.locales.any((l) => l.countryCode == 'IN'))
      return PricePlan.india;
    final tzOffset = DateTime.now().timeZoneOffset.inMinutes;
    debugPrint('🌍 TZ offset: ${tzOffset}min');
    if (tzOffset == 330) return PricePlan.india; // IST = UTC+5:30
    return PricePlan.global;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020203),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildPricingCards(),
                  _buildTrustBadges(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF020203).withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: widget.onDismiss,
        icon: const Icon(Icons.close, color: Colors.white70),
      ),
      centerTitle: true,
      title: Text(
        'Subscription',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4A89FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4A89FF).withOpacity(0.3)),
          ),
          child: Text(
            'UNLOCK PREMIUM ACCESS',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A89FF),
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Choose the plan that\nworks for you',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Get access to advanced AI tool discovery, priority\nsupport, and exclusive daily briefing features.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCards() {
    final auth = context.watch<AuthProvider>();
    final isTrial = auth.plan == 'trial' || auth.status == 'trial';
    final isPro = auth.isPro && !isTrial;
    final hasActivePlan = auth.isPro || isTrial;
    final isFree = !hasActivePlan;

    final isIndia = _activePlan.isIndia;
    final trialPlan = PricePlan.getTrial(isIndia);
    final proPlan = PricePlan.getPro(isIndia);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _pricingCard('Free', '0', [
                  'Basic Search',
                  '10 Bookmarks',
                  '2 AI generations / month',
                ], isCurrentPlan: isFree, isLocked: hasActivePlan),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _pricingCard(
                  'Trial',
                  trialPlan.displayPrice.replaceAll(trialPlan.symbol, ''),
                  ['7 AI generations / day', 'Full Bookmarks', '4 Days Duration'],
                  plan: trialPlan,
                  suffix: '/4 days',
                  subLabel: 'One-time payment',
                  isFeatured: true,
                  badgeText: 'TRIAL OFFER',
                  isCurrentPlan: isTrial,
                  isLocked: hasActivePlan,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _pricingCard(
                  'Pro',
                  proPlan.displayPrice.replaceAll(proPlan.symbol, ''),
                  [
                    '7 AI generations / day',
                    'Unlimited Bookmarks',
                    'Daily Briefings',
                    'Priority Support',
                  ],
                  plan: proPlan,
                  isCurrentPlan: isPro,
                  isLocked: hasActivePlan,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _pricingCard('Free', '0', [
                'Basic Search',
                '10 Bookmarks',
                '2 AI generations / month',
              ], isCurrentPlan: isFree, isLocked: hasActivePlan),
              const SizedBox(height: 24),
              _pricingCard(
                'Trial',
                trialPlan.displayPrice.replaceAll(trialPlan.symbol, ''),
                ['7 AI generations / day', 'Full Bookmarks', '4 Days Duration'],
                plan: trialPlan,
                suffix: '/4 days',
                subLabel: 'One-time payment',
                isFeatured: true,
                badgeText: 'TRIAL OFFER',
                isCurrentPlan: isTrial,
                isLocked: hasActivePlan,
              ),
              const SizedBox(height: 24),
              _pricingCard(
                'Pro',
                proPlan.displayPrice.replaceAll(proPlan.symbol, ''),
                [
                  '7 AI generations / day',
                  'Unlimited Bookmarks',
                  'Daily Briefings',
                  'Priority Support',
                ],
                plan: proPlan,
                isCurrentPlan: isPro,
                isLocked: hasActivePlan,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _pricingCard(
    String title,
    String price,
    List<String> features, {
    PricePlan? plan,
    bool isFeatured = false,
    String suffix = '/mo',
    String subLabel = 'Billed monthly',
    String badgeText = 'MOST POPULAR',
    bool isCurrentPlan = false,
    bool isLocked = false,
  }) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(minHeight: 480),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFeatured ? const Color(0xFF4A89FF) : const Color(0xFF1A1A24),
          width: isFeatured ? 2 : 1,
        ),
        boxShadow: isFeatured
            ? [
                BoxShadow(
                  color: const Color(0xFF4A89FF).withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
              ]
            : null,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A89FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Show crossed-out original price if there's a discount
              if (plan != null && plan.originalPrice != plan.displayPrice) ...[
                Text(
                  plan.originalPrice,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white38,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white38,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '${_activePlan.symbol}$price',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                suffix,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show discount percentage if applicable
          if (plan != null && plan.originalPrice != plan.displayPrice)
            Text(
              'Limited time offer',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF00D4AA),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              subLabel,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white24),
            ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF1A1A24)),
          const SizedBox(height: 32),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00D4AA),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isProcessing || isCurrentPlan || isLocked)
                  ? null
                  : () => _handleSubscriptionTrigger(title, plan),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: (title == 'Free' || isCurrentPlan || isLocked)
                    ? const Color(0xFF1A1A24)
                    : null,
                disabledForegroundColor: (title == 'Free' || isCurrentPlan || isLocked)
                    ? Colors.white54
                    : null,
                backgroundColor: isFeatured
                    ? const Color(0xFF4A89FF)
                    : Colors.white,
                foregroundColor: isFeatured ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing && _processingPlan == title
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isCurrentPlan ? 'Current Plan' : (isLocked ? 'Locked (Plan Active)' : 'Get Started'),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _handleSubscriptionTrigger(String title, PricePlan? plan) async {
    if (kDebugMode) {
      print('Subscription button clicked for plan: $title');
    }
    if (title == 'Free' || plan == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) {
      if (mounted) {
        await showGeneralDialog(
          context: context,
          barrierColor: Colors.black54,
          barrierDismissible: true,
          barrierLabel: 'Dismiss',
          transitionDuration: const Duration(milliseconds: 350),
          transitionBuilder: (_, anim, __, child) {
            final curve = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(curve),
              child: FadeTransition(opacity: curve, child: child),
            );
          },
          pageBuilder: (dialogContext, _, __) => Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4A89FF).withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A89FF).withOpacity(0.08),
                          blurRadius: 40,
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4A89FF).withOpacity(0.15),
                                const Color(0xFF00D4AA).withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4A89FF).withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Color(0xFF4A89FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign in to subscribe',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Create an account to unlock this plan',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            AppNavigator.toLogin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A89FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingPlan = title;
    });

    try {
      final isTest = plan.tier == SubscriptionTier.test;
      final planDays = plan.tier == SubscriptionTier.trial
          ? 4
          : (plan.tier == SubscriptionTier.pro ? 30 : 0);
      final purchaseDate = DateTime.now().toUtc().toIso8601String();

      final expiryDate = isTest
          ? DateTime.now()
                .toUtc()
                .add(const Duration(minutes: 2))
                .toIso8601String()
          : DateTime.now()
                .toUtc()
                .add(Duration(days: planDays))
                .toIso8601String();

      final responseData = await PaymentIntegrationService.sendPaymentDataToN8N(
        uid: user.uid,
        userEmail: user.email ?? '',
        amountPaise: plan.amountSmallest,
        plan: isTest ? 'test' : plan.tier.name,
        currency: plan.currency,
        planDays: planDays,
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
      );

      final paymentUrl =
          responseData?['short_url'] ?? responseData?['payment_url'];
      final status = responseData?['status']?.toString().toLowerCase();
      final isSuccess = status == 'success' || status == 'created';

      if (paymentUrl != null && isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to payment gateway...'),
              backgroundColor: Color(0xFF00D4AA),
            ),
          );
        }
        html.window.location.href = paymentUrl;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not connect to payment server. Please try again.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingPlan = null;
        });
      }
    }
  }

  Widget _buildTrustBadges() {
    return Column(
      children: [
        Text(
          'SECURE RECURRING BILLING',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white24,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 40,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _badge(Icons.security, '256-bit SSL'),
            _badge(Icons.verified_user, 'PCI Compliant'),
            _badge(Icons.autorenew, 'Cancel Anytime'),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          '* All purchases are final. Strict no-refund policy applies.',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white24,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }


  Widget _badge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white24, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}

// ── Sign-In Benefit Row ────────────────────────────────────────────────────────

class _SignInBenefit extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _SignInBenefit({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
