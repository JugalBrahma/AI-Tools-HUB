import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/features/ai_assistant/models/assistant_models.dart';
import 'package:toolshub/features/home/widgets/animated_background.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AssistantState _state = AssistantState();
  
  bool _isExpanded = false;

  void _onChipSelected(SuggestionChipData chip) {
    setState(() {
      final currentText = _controller.text;
      final snippet = chip.promptSnippet ?? chip.label;
      if (currentText.isEmpty) {
        _controller.text = snippet;
      } else {
        _controller.text = '$currentText $snippet';
      }
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _onFilterSelected(FilterOption filter, String value) {
    setState(() {
      filter.selectedValue = value;
      final filterTag = '${filter.label}: $value';
      if (!_state.activeFilters.contains(filterTag)) {
        _state.activeFilters.add(filterTag);
      }
    });
  }

  void _removeFilter(String filterTag) {
    setState(() {
      _state.activeFilters.remove(filterTag);
      // Reset the actual model value
      final label = filterTag.split(':').first;
      final filter = _state.smartFilters.firstWhere((f) => f.label == label);
      filter.selectedValue = null;
    });
  }

  void _sendPrompt() {
    if (_controller.text.trim().isEmpty && _state.activeFilters.isEmpty) return;
    
    // Mock action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analyzing your requirements for "${_controller.text}"...'),
        backgroundColor: const Color(0xFF4A89FF),
      ),
    );
    
    setState(() {
      _controller.clear();
      _state.activeFilters.clear();
      for (var f in _state.smartFilters) { f.selectedValue = null; }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: AnimatedGridBackground(
        child: Column(
          children: [
            // ── Top Header ──────────────────────────────────────────────
            const _AssistantHeader(),

            // ── Main Content Area ────────────────────────────────────────
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_state.activeFilters.isNotEmpty)
                          _ActiveFiltersRow(
                            filters: _state.activeFilters,
                            onRemove: _removeFilter,
                          ),
                        const SizedBox(height: 24),
                        
                        // Suggestion Grid (shown when not many filters)
                        if (_state.activeFilters.length < 3)
                          _SuggestionGrid(
                            onChipTap: _onChipSelected,
                          ),
                        
                        const SizedBox(height: 120), // Spacer for bottom input
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Guided Input Bar ────────────────────────────────────────
            _BottomInputSection(
              controller: _controller,
              focusNode: _focusNode,
              state: _state,
              onSend: _sendPrompt,
              onFilterSelect: _onFilterSelected,
              bottomInset: bottomInset,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Center(
        child: Column(
          children: [
            ScrollReveal(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A89FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4A89FF).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF4A89FF)),
                    const SizedBox(width: 8),
                    Text(
                      'AI ASSISTANT',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A89FF),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Find your perfect stack.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell me what you’re building or choose a category below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionGrid extends StatelessWidget {
  final Function(SuggestionChipData) onChipTap;
  const _SuggestionGrid({required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'QUICK START',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              color: Colors.white24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestionChips.map((chip) => _IntentChip(
            chip: chip,
            onTap: () => onChipTap(chip),
          )).toList(),
        ),
      ],
    );
  }
}

class _IntentChip extends StatefulWidget {
  final SuggestionChipData chip;
  final VoidCallback onTap;
  const _IntentChip({required this.chip, required this.onTap});

  @override
  State<_IntentChip> createState() => _IntentChipState();
}

class _IntentChipState extends State<_IntentChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFF14141A) : const Color(0xFF0D0D12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovering ? const Color(0xFF2A2A35) : const Color(0xFF1C1C22),
            ),
          ),
          child: Text(
            widget.chip.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _hovering ? Colors.white : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  final List<String> filters;
  final Function(String) onRemove;
  const _ActiveFiltersRow({required this.filters, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Text(f),
            labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4A89FF)),
            backgroundColor: const Color(0xFF4A89FF).withOpacity(0.08),
            side: const BorderSide(color: Color(0xFF4A89FF), width: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF4A89FF)),
            onDeleted: () => onRemove(f),
          ),
        )).toList(),
      ),
    );
  }
}

class _BottomInputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AssistantState state;
  final VoidCallback onSend;
  final Function(FilterOption, String) onFilterSelect;
  final double bottomInset;

  const _BottomInputSection({
    required this.controller,
    required this.focusNode,
    required this.state,
    required this.onSend,
    required this.onFilterSelect,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Smart Filter Row ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF15151A))),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                ...state.smartFilters.take(3).map((f) => _FilterButton(
                  filter: f,
                  onSelect: (val) => onFilterSelect(f, val),
                )),
                _FilterButton(
                  filter: FilterOption(label: 'More', icon: Icons.tune_rounded, options: []),
                  isMore: true,
                  onSelect: (_) {},
                ),
              ],
            ),
          ),
        ),

        // ── Prompt Bar ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF1E1E26), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.mic_none_rounded, color: Colors.white24, size: 22),
                  onPressed: () {}, // Mic placeholder
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: 4,
                    minLines: 1,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'What do you need an AI tool for?',
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 8),
                  child: _SendButton(onTap: onSend),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final FilterOption filter;
  final Function(String) onSelect;
  final bool isMore;

  const _FilterButton({
    required this.filter,
    required this.onSelect,
    this.isMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _showOptions(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: filter.selectedValue != null 
                ? const Color(0xFF4A89FF).withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: filter.selectedValue != null 
                  ? const Color(0xFF4A89FF).withOpacity(0.3) 
                  : const Color(0xFF1E1E26),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon, 
                size: 14, 
                color: filter.selectedValue != null ? const Color(0xFF4A89FF) : Colors.white38
              ),
              const SizedBox(width: 8),
              Text(
                filter.selectedValue ?? filter.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: filter.selectedValue != null ? Colors.white : Colors.white38,
                ),
              ),
              if (!isMore) ...[
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white10),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    if (isMore) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select ${filter.label}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: filter.options.map((opt) => ChoiceChip(
                label: Text(opt),
                selected: filter.selectedValue == opt,
                onSelected: (selected) {
                  if (selected) onSelect(opt);
                  Navigator.pop(context);
                },
                backgroundColor: const Color(0xFF14141C),
                selectedColor: const Color(0xFF4A89FF).withOpacity(0.2),
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: filter.selectedValue == opt ? const Color(0xFF4A89FF) : Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: filter.selectedValue == opt ? const Color(0xFF4A89FF) : const Color(0xFF222230),
                  ),
                ),
                showCheckmark: false,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF4A89FF),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A89FF).withOpacity(_hovering ? 0.4 : 0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
