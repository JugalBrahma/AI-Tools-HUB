import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart';
import 'package:toolshub/features/subscription/services/payment_integration_service.dart';
import 'dart:html' if (dart.library.io) 'package:toolshub/core/utils/html_stub.dart' as html;

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback onDismiss;

  const SubscriptionScreen({super.key, required this.onDismiss});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isYearly = true;
  bool _isProcessing = false;
  String? _processingPlan;

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
                  _buildBillingToggle(),
                  const SizedBox(height: 48),
                  _buildPricingCards(),
                  const SizedBox(height: 60),
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

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleItem('Monthly', !isYearly),
          _toggleItem('Yearly (Save 30%)', isYearly),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isYearly = label.contains('Yearly')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A1A24) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCards() {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _pricingCard('Free', '0', ['Basic Search', '10 Bookmarks', 'Community Support'])),
            const SizedBox(width: 24),
            Expanded(child: _pricingCard('Pro', isYearly ? '12' : '19', ['AI Assistant V2', 'Unlimited Bookmarks', 'Daily Briefings', 'Priority Support'], isFeatured: true)),
            const SizedBox(width: 24),
            Expanded(child: _pricingCard('Expert', isYearly ? '32' : '49', ['API Access', 'Custom Workflow', 'Early Beta access', 'Dedicated Account Manager'])),
          ],
        );
      } else {
        return Column(
          children: [
            _pricingCard('Free', '0', ['Basic Search', '10 Bookmarks', 'Community Support']),
            const SizedBox(height: 24),
            _pricingCard('Pro', isYearly ? '12' : '19', ['AI Assistant V2', 'Unlimited Bookmarks', 'Daily Briefings', 'Priority Support'], isFeatured: true),
            const SizedBox(height: 24),
            _pricingCard('Expert', isYearly ? '32' : '49', ['API Access', 'Custom Workflow', 'Early Beta access', 'Dedicated Account Manager']),
          ],
        );
      }
    });
  }

  Widget _pricingCard(String title, String price, List<String> features, {bool isFeatured = false}) {
    return Container(
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
                )
              ]
            : null,
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A89FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MOST POPULAR',
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
              Text(
                '\$$price',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/mo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isYearly ? 'Billed annually' : 'Billed monthly',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF1A1A24)),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00D4AA), size: 18),
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
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _handleSubscriptionTrigger(title, price),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFeatured ? const Color(0xFF4A89FF) : Colors.white,
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
                      title == 'Free' ? 'Current Plan' : 'Get Started',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscriptionTrigger(String plan, String price) async {
    if (kDebugMode) {
      print('Subscription button clicked for plan: $plan');
    }
    if (plan == 'Free') return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to subscribe.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingPlan = plan;
    });

    try {
      // Convert price string to int paise (e.g. "19" -> 1900)
      final amountPaise = (double.parse(price) * 100).toInt();

      final responseData = await PaymentIntegrationService.sendPaymentDataToN8N(
        uid: user.uid,
        userEmail: user.email ?? '',
        amountPaise: amountPaise,
      );

      // Support both n8n-formatted and raw Razorpay responses
      final paymentUrl = responseData?['short_url'] ?? responseData?['payment_url'];
      final status = responseData?['status']?.toString().toLowerCase();
      final isSuccess = status == 'success' || status == 'created';

      if (paymentUrl != null && isSuccess) {
        if (kDebugMode) {
          print('✅ Payment link ready. Redirecting in same tab to: $paymentUrl');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to payment gateway...'),
              backgroundColor: Color(0xFF00D4AA),
            ),
          );
        }
        // Redirect in THIS same tab so Razorpay can redirect back here after payment
        // This is what allows the success detection in AppShell to work
        html.window.location.href = paymentUrl;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not connect to payment server. Please try again.'),
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
