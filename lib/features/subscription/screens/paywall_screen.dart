import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toolshub/core/providers/auth_provider.dart';
import 'package:toolshub/core/navigation/app_navigator.dart';
import 'package:toolshub/features/subscription/models/price_plan.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RazorpayCheckoutService — keeps checkout logic away from widgets
// ─────────────────────────────────────────────────────────────────────────────

class RazorpayCheckoutService {
  static const String _razorpayKeyId = 'rzp_test_YOUR_KEY_HERE'; // ← replace

  final Razorpay _razorpay = Razorpay();

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  /// Opens the Razorpay checkout with the given plan and user details.
  void openCheckout({
    required PricePlan plan,
    required String uid,
    required String userEmail,
    required String userName,
  }) {
    final options = <String, dynamic>{
      'key': _razorpayKeyId,
      'amount': plan.amountSmallest,
      'currency': plan.currency,
      'name': 'AI Tools Hub',
      'description': 'Pro Subscription',
      'prefill': {
        'email': userEmail,
        'contact': '',
        'name': userName,
      },
      'notes': {
        'uid': uid,       // used to update Firestore after payment
        'plan': plan.tier.name,
        'currency': plan.currency,
      },
      'theme': {'color': '#4A89FF'},
      'modal': {'ondismiss': true},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Razorpay open error: $e');
    }
  }

  void dispose() => _razorpay.clear();
}

// ─────────────────────────────────────────────────────────────────────────────
// PaywallScreen
// ─────────────────────────────────────────────────────────────────────────────

class PaywallScreen extends StatefulWidget {
  final VoidCallback onDismiss;

  const PaywallScreen({super.key, required this.onDismiss});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late PricePlan _selectedPlan;
  final RazorpayCheckoutService _checkoutService = RazorpayCheckoutService();
  late AnimationController _priceAnimController;
  late Animation<double> _priceAnim;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = _detectLocale();

    _priceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _priceAnim = CurvedAnimation(
      parent: _priceAnimController,
      curve: Curves.easeOut,
    );
    _priceAnimController.forward();

    _checkoutService.init(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onWallet: _handleExternalWallet,
    );
  }

  // ── Locale detection ───────────────────────────────────────────────────────

  PricePlan _detectLocale() {
    // Strategy 1: direct countryCode from primary locale (works on mobile)
    final primaryLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    if (primaryLocale.countryCode == 'IN') return PricePlan.proIndia;

    // Strategy 2: scan all locales (some browsers report en-IN in secondary slots)
    final allLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    if (allLocales.any((l) => l.countryCode == 'IN')) return PricePlan.proIndia;

    // Strategy 3: timezone offset — IST is always UTC+5:30 = 330 minutes.
    // This is the most reliable signal on Flutter Web where locale country
    // codes are often stripped by the browser.
    final tzOffset = DateTime.now().timeZoneOffset.inMinutes;
    debugPrint('🌍 Locale: ${primaryLocale.toLanguageTag()} | TZ offset: ${tzOffset}min');
    if (tzOffset == 330) return PricePlan.proIndia;

    return PricePlan.proGlobal;
  }

  // ── Checkout ───────────────────────────────────────────────────────────────

  void _openSpecificCheckout(PricePlan plan) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      AppNavigator.toLogin(context);
      return;
    }

    setState(() => _isProcessing = true);

    _checkoutService.openCheckout(
      plan: plan,
      uid: user.uid,
      userEmail: user.email ?? '',
      userName: user.displayName ?? 'User',
    );
  }

  void _openCheckout() {
    _openSpecificCheckout(_selectedPlan);
  }




  // ── Razorpay callbacks ─────────────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    debugPrint('✅ Payment success: ${response.paymentId}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! ID: ${response.paymentId}'),
          backgroundColor: const Color(0xFF00D4AA),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onDismiss();
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    debugPrint('❌ Payment failed: ${response.message}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Payment failed. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    debugPrint('💳 External wallet: ${response.walletName}');
  }

  @override
  void dispose() {
    _checkoutService.dispose();
    _priceAnimController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020203),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                child: Column(
                  children: [
                    _buildProBadge(),
                    const SizedBox(height: 32),
                    _buildPriceBlock(),
                    const SizedBox(height: 40),
                    _buildFeatureList(),
                    const SizedBox(height: 48),
                    _buildSubscribeButton(),
                    const SizedBox(height: 32),
                    _buildTestPlanContainer(),
                    const SizedBox(height: 32),
                    _buildLegalText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF020203).withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: widget.onDismiss,
        icon: const Icon(Icons.close, color: Colors.white60),
      ),
      centerTitle: true,
      title: Text(
        'Upgrade to Pro',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A89FF), Color(0xFF00D4AA)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'PRO',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Unlock Everything',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Full AI access, unlimited bookmarks,\npriority support & more.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white38,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBlock() {
    return FadeTransition(
      opacity: _priceAnim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(_priceAnim),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF4A89FF).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A89FF).withOpacity(0.08),
                blurRadius: 60,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _selectedPlan.displayPrice,
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedPlan.isIndia ? 'One-time (INR)' : 'One-time (USD)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      (Icons.smart_toy_rounded, 'AI Stack Assistant — Unlimited'),
      (Icons.bookmark_rounded, 'Unlimited Bookmarks'),
      (Icons.newspaper_rounded, 'Daily Intelligence Briefings'),
      (Icons.support_agent_rounded, 'Priority Support'),
      (Icons.update_rounded, 'All Future Updates Included'),
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A89FF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4A89FF).withOpacity(0.15),
                      ),
                    ),
                    child: Icon(f.$1, size: 17, color: const Color(0xFF4A89FF)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    f.$2,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _openCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A89FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4A89FF).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Subscribe Now — ${_selectedPlan.displayPrice}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }



  Widget _buildLegalText() {
    return Text(
      'Secure payment via Razorpay. Cancel anytime.',
      style: GoogleFonts.inter(fontSize: 11, color: Colors.white12),
    );
  }

  Widget _buildTestPlanContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4A4A).withOpacity(0.05),
        border: Border.all(color: const Color(0xFFFF4A4A).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report_rounded, color: Color(0xFFFF4A4A), size: 18),
              const SizedBox(width: 8),
              Text(
                'Developer Test Plan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF4A4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use this ₹1 plan to test the 1-minute expiration logic. It sets "plan": "test" for the webhook.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isProcessing ? null : () => _openSpecificCheckout(PricePlan.test),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF4A4A)),
                foregroundColor: const Color(0xFFFF4A4A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4A4A)),
                      ),
                    )
                  : Text(
                      'Test Purchase (₹1)',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
