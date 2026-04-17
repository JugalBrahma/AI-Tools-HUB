import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/features/ai_assistant/models/assistant_models.dart';
import 'package:toolshub/features/ai_assistant/models/assistant_api_models.dart';
import 'package:toolshub/features/ai_assistant/services/assistant_api_service.dart';
import 'package:toolshub/features/home/widgets/animated_background.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AssistantState _state = AssistantState();
  final AssistantApiService _apiService = AssistantApiService();
  final TextEditingController _promptController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _generateStack() async {
    final goal = _promptController.text.trim();
    if (goal.isEmpty && _state.selections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide some context or select filters.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ── Map UI to API Request ─────────────────────────────────────
      final request = AssistantRequest(
        goal: goal,
        budget: _state.selections['Budget']?.toString().toLowerCase() ?? 'not_sure',
        teamSize: 'solo', // Default or mapped from a specific filter
        mustHaveFeatures: List<String>.from(_state.selections['Must-haves'] ?? []),
        preferredIntegrations: List<String>.from(_state.selections['Integrations'] ?? []),
        priority: _state.selections['Priority']?.toString().toLowerCase() ?? 'balanced',
        freshnessRequired: _state.selections['Latest info'] == 'Verify live',
        avoid: List<String>.from(_state.selections['Avoid'] ?? []),
      );

      final response = await _apiService.getRecommendations(request);

      if (mounted) {
        _showResults(response);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResults(AssistantResponse response) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF030303),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _ResultsSheet(response: response),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSelectionChanged(FilterConfig filter, dynamic value) {
    setState(() {
      _state.selections[filter.label] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        children: [
          AnimatedGridBackground(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      // ── Header ──────────────────────────────────────────
                      ScrollReveal(
                        child: Column(
                          children: [
                            Text(
                              'AI Stack Assistant',
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Describe what you need. We’ll build the right stack.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.white54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Interaction Card ──────────────────────────────
                      ScrollReveal(
                        delay: 0.1,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C0C10),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0xFF1C1C22), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPromptInput(),
                              const SizedBox(height: 32),
                              const Divider(color: Color(0xFF1C1C22), height: 1),
                              const SizedBox(height: 24),

                              _buildFilterHeader('CORE REQUIREMENTS'),
                              const SizedBox(height: 12),
                              _buildFilterScroll(_state.filters.take(3).toList()),
                              const SizedBox(height: 24),

                              _buildFilterHeader('SPECIFICATIONS'),
                              const SizedBox(height: 12),
                              _buildFilterScroll(_state.filters.skip(3).toList()),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Submit Button ─────────────────────────────────
                      ScrollReveal(
                        delay: 0.2,
                        child: _PremiumCTA(
                          onPressed: _isLoading ? null : _generateStack,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A89FF)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromptInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF141418),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF24242A)),
          ),
          child: TextField(
            controller: _promptController,
            maxLines: 3,
            minLines: 1,
            enabled: !_isLoading,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'What do you need AI tools for?',
              hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 15),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'High-fidelity prompt build. Use chips below to refine.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 9,
        color: Colors.white24,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildFilterScroll(List<FilterConfig> filters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: filters.map((f) => _FilterPill(
          config: f,
          enabled: !_isLoading,
          currentValue: _state.selections[f.label],
          onChanged: (val) => _onSelectionChanged(f, val),
        )).toList(),
      ),
    );
  }
}

// ── Results Widget ────────────────────────────────────────────────────────────

class _ResultsSheet extends StatelessWidget {
  final AssistantResponse response;
  const _ResultsSheet({required this.response});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1C1C22), width: 1.5)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Generated AI Stack', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 32),
            
            if (response.topPick != null) ...[
              _RecommendationCard(rec: response.topPick!, isTop: true),
              const SizedBox(height: 24),
            ],
            
            if (response.alternatives.isNotEmpty) ...[
              Text('ALTERNATIVES', style: GoogleFonts.ibmPlexMono(fontSize: 10, color: Colors.white24, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...response.alternatives.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecommendationCard(rec: a),
              )),
            ],
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14141C),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF24242A))),
              ),
              child: Text('Close Stack', style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  final bool isTop;
  const _RecommendationCard({required this.rec, this.isTop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isTop ? const Color(0xFF00D4AA).withOpacity(0.05) : const Color(0xFF0C0C10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isTop ? const Color(0xFF00D4AA).withOpacity(0.3) : const Color(0xFF1C1C22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rec.toolName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const Spacer(),
              if (isTop)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF00D4AA).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('TOP PICK', style: GoogleFonts.ibmPlexMono(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF00D4AA))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(rec.reason, style: GoogleFonts.inter(fontSize: 14, color: Colors.white54, height: 1.5)),
        ],
      ),
    );
  }
}

// ── Reusable Filter Pill (Updated with enabled state) ──────────────────────────

class _FilterPill extends StatelessWidget {
  final FilterConfig config;
  final dynamic currentValue;
  final Function(dynamic) onChanged;
  final bool enabled;

  const _FilterPill({required this.config, required this.currentValue, required this.onChanged, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    bool active = currentValue != null && (currentValue is! List || (currentValue as List).isNotEmpty);
    String label = currentValue == null ? config.label 
                   : (currentValue is List ? '${config.label} (${currentValue.length})' : currentValue.toString());

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: enabled ? () => _showSheet(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4A89FF).withOpacity(0.1) : const Color(0xFF141418),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? const Color(0xFF4A89FF).withOpacity(0.4) : const Color(0xFF24242A)),
          ),
          child: Opacity(
            opacity: enabled ? 1.0 : 0.4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(config.icon, size: 14, color: active ? const Color(0xFF4A89FF) : Colors.white24),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? Colors.white : Colors.white38)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: active ? const Color(0xFF4A89FF) : Colors.white10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => _FilterSheet(config: config, initialValue: currentValue, onSave: onChanged),
    );
  }
}

// ── (Keeping _FilterSheet and _PremiumCTA from previous turns) ────────────────

class _FilterSheet extends StatefulWidget {
  final FilterConfig config;
  final dynamic initialValue;
  final Function(dynamic) onSave;

  const _FilterSheet({
    required this.config,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late dynamic _tempValue;

  @override
  void initState() {
    super.initState();
    if (widget.config.type == SelectionType.multi) {
      _tempValue = List<String>.from(widget.initialValue ?? []);
    } else {
      _tempValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.config.label,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (widget.config.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.config.description!,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
                        ),
                      ),
                  ],
                ),
                if (widget.config.type == SelectionType.multi)
                  TextButton(
                    onPressed: () => setState(() => (_tempValue as List).clear()),
                    child: Text('Clear All', style: GoogleFonts.inter(color: const Color(0xFF4A89FF))),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.config.options.map((opt) {
                    final isSelected = widget.config.type == SelectionType.multi
                        ? (_tempValue as List).contains(opt)
                        : _tempValue == opt;
                        
                    return ChoiceChip(
                      label: Text(opt),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (widget.config.type == SelectionType.multi) {
                            if (selected) {
                              (_tempValue as List).add(opt);
                            } else {
                              (_tempValue as List).remove(opt);
                            }
                          } else {
                            _tempValue = selected ? opt : null;
                          }
                        });
                        if (widget.config.type != SelectionType.multi) {
                          widget.onSave(_tempValue);
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: const Color(0xFF14141C),
                      selectedColor: const Color(0xFF4A89FF).withOpacity(0.2),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF4A89FF) : Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF4A89FF) : const Color(0xFF222230),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
              ),
            ),
            if (widget.config.type == SelectionType.multi) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(_tempValue);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A89FF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Apply Selection', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PremiumCTA extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  const _PremiumCTA({required this.onPressed, required this.isLoading});

  @override
  State<_PremiumCTA> createState() => _PremiumCTAState();
}

class _PremiumCTAState extends State<_PremiumCTA> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    bool enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: enabled 
                ? const LinearGradient(colors: [Color(0xFF4A89FF), Color(0xFF00D4AA)])
                : null,
            color: enabled ? null : Colors.white12,
            borderRadius: BorderRadius.circular(20),
            boxShadow: enabled ? [
              BoxShadow(
                color: const Color(0xFF4A89FF).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ] : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    'Generate Custom Stack',
                    style: GoogleFonts.inter(
                      color: enabled ? Colors.white : Colors.white24,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
