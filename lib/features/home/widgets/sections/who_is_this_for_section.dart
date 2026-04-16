import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhoIsThisForSection extends StatefulWidget {
  const WhoIsThisForSection({super.key});

  @override
  State<WhoIsThisForSection> createState() => _WhoIsThisForSectionState();
}

class _WhoIsThisForSectionState extends State<WhoIsThisForSection> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const List<Map<String, dynamic>> audiences = [
    {
      'title': 'DEVELOPERS',
      'icon': Icons.code_rounded,
      'color': Color(0xFF00A8FF),
      'desc': 'Accelerate your deployment cycles with specialized AI coding partners.',
      'tech': 'VIBE_CODING_ENABLED',
    },
    {
      'title': 'EXECUTIVES',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF00FFD1),
      'desc': 'Scale team output with automated AI-driven augmentation strategies.',
      'tech': 'ROI_ENGINE_ACTIVE',
    },
    {
      'title': 'STUDENTS',
      'icon': Icons.school_rounded,
      'color': Color(0xFFFF9900),
      'desc': 'Unleash high-speed learning with personal AI tutors and research bots.',
      'tech': 'KNOWLEDGE_GRID_SYNC',
    },
    {
      'title': 'CREATORS',
      'icon': Icons.videocam_rounded,
      'color': Color(0xFFFF3366),
      'desc': 'Command generative AI to produce viral video and cinematic assets.',
      'tech': 'GEN_MEDIA_PROTOCOLS',
    },
    {
      'title': 'DESIGNERS',
      'icon': Icons.palette_rounded,
      'color': Color(0xFF9933FF),
      'desc': 'Transmute basic sketches into production-ready high fidelity visuals.',
      'tech': 'PIXEL_DYNAMICS_V2',
    },
    {
      'title': 'MARKETERS',
      'icon': Icons.analytics_rounded,
      'color': Color(0xFF00D4AA),
      'desc': 'Maximise user conversion with deep data-driven algorithmic insight.',
      'tech': 'CONVERSION_OPTIMISER',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Premium Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF9933FF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF9933FF).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_input_component_rounded, size: 14, color: Color(0xFF9933FF)),
              const SizedBox(width: 8),
              Text(
                'INFRASTRUCTURE_NODES',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9933FF),
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),

        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // The AI Power Spine
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _PowerGridPainter(
                            isMobile: isMobile,
                            pulse: _pulseController.value,
                            audiencesCount: audiences.length,
                          ),
                        );
                      },
                    ),
                  ),

                  // The Staggered Pipeline Cards
                  Column(
                    children: List.generate(audiences.length, (index) {
                      final isEven = index % 2 == 0;
                      final a = audiences[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isMobile) ...[
                              // Left Side
                              if (isEven)
                                _PipelineCard(audience: a, isEven: isEven, isMobile: isMobile)
                              else
                                const SizedBox(width: 500),
                              
                              // Spine Gap
                              const SizedBox(width: 100),
                              
                              // Right Side
                              if (!isEven)
                                _PipelineCard(audience: a, isEven: isEven, isMobile: isMobile)
                              else
                                const SizedBox(width: 500),
                            ] else
                              _PipelineCard(audience: a, isEven: isEven, isMobile: isMobile),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _PipelineCard extends StatelessWidget {
  final Map<String, dynamic> audience;
  final bool isEven;
  final bool isMobile;

  const _PipelineCard({
    required this.audience,
    required this.isEven,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final color = audience['color'] as Color;
    return Container(
      width: isMobile ? double.infinity : 500,
      height: 220, // Fixed height for perfect chain alignment
      padding: const EdgeInsets.all(2), // For border width
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF141417).withOpacity(0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Stack
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(audience['icon'] as IconData, color: color, size: 28),
                ),
                const SizedBox(width: 24),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audience['title'],
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        audience['tech'],
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        audience['desc'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PowerGridPainter extends CustomPainter {
  final bool isMobile;
  final double pulse;
  final int audiencesCount;

  _PowerGridPainter({
    required this.isMobile,
    required this.pulse,
    required this.audiencesCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. Draw Central Vertical Spine
    final spinePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    // Spine Glow
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), Paint()
      ..color = const Color(0xFF9933FF).withOpacity(0.02)
      ..strokeWidth = 12.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    canvas.drawLine(Offset(center, 0), Offset(center, size.height), spinePaint);

    // 2. Draw Branching Arms
    double currentY = 0;
    
    for (int i = 0; i < audiencesCount; i++) {
        final isEven = i % 2 == 0;
        // 220 (height) + 60 (bottom padding)
        final startY = i * (220.0 + 60.0); 
        final targetY = startY + 110; // Exactly half of 220 height
        
        // Branch Arm
        final armPath = Path();
        armPath.moveTo(center, targetY);
        
        if (isMobile) {
            // No horizontal arms on mobile
        } else {
           if (isEven) {
              armPath.lineTo(center - 50, targetY);
           } else {
              armPath.lineTo(center + 50, targetY);
           }
        }

        paint.color = const Color(0xFF9933FF).withOpacity(0.1);
        paint.strokeWidth = 2.0;
        canvas.drawPath(armPath, paint);

        // Junction Node
        canvas.drawCircle(Offset(center, targetY), 6, Paint()..color = const Color(0xFF0D0D0F));
        canvas.drawCircle(Offset(center, targetY), 3, Paint()..color = const Color(0xFF9933FF).withOpacity(0.5));

        // Data Pulse on Spine
        final p = (pulse + (i * 0.15)) % 1.0;
        final pulseY = p * size.height;
        
        canvas.drawCircle(Offset(center, pulseY), 3, Paint()
          ..color = const Color(0xFF9933FF).withOpacity(0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  @override
  bool shouldRepaint(covariant _PowerGridPainter oldDelegate) => true;
}
