// lib/widgets/review_card.dart
//
// WIDGET — ReviewCard
// ────────────────────
// Renders the full interactive view for a single FlashCard inside a PageView.
//
// FormatType.flashcard — shows question; "Reveal" button flips to show answer.
// FormatType.mcq       — shows question + option buttons; tapping an option
//                        highlights correct (green) / wrong (red) immediately.
//
// State is LOCAL — each card resets when the user pages away because PageView
// by default disposes off-screen pages. To persist per-card state across swipes,
// wrap with AutomaticKeepAliveClientMixin or store state in the parent.

import 'package:flutter/material.dart';
import '../models/flash_card.dart';

class ReviewCard extends StatefulWidget {
  final FlashCard card;

  const ReviewCard({super.key, required this.card});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  // ── Local state ────────────────────────────────────────────────────────────

  /// Flashcard: whether the answer side is visible
  bool _answerRevealed = false;

  /// MCQ: null = no selection yet; otherwise the tapped option index
  int? _selectedIndex;

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get _isCorrect =>
      _selectedIndex != null &&
      _selectedIndex == widget.card.correctIndex;

  Color _optionColor(int index, ColorScheme cs) {
    if (_selectedIndex == null) return cs.surfaceContainerHighest;
    if (index == widget.card.correctIndex) return cs.primaryContainer;
    if (index == _selectedIndex) return cs.errorContainer;
    return cs.surfaceContainerHighest;
  }

  Color _optionTextColor(int index, ColorScheme cs) {
    if (_selectedIndex == null) return cs.onSurface;
    if (index == widget.card.correctIndex) return cs.onPrimaryContainer;
    if (index == _selectedIndex) return cs.onErrorContainer;
    return cs.onSurfaceVariant;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: subject / topic ──────────────────────────────────────
          Text(
            widget.card.subject.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.card.topic,
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // ── Question ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.card.question,
              style: tt.titleLarge,
            ),
          ),
          const SizedBox(height: 24),

          // ── Format-specific content ───────────────────────────────────────
          if (widget.card.formatType == FormatType.flashcard)
            _buildFlashcardSection(cs, tt)
          else
            _buildMcqSection(cs, tt),
        ],
      ),
    );
  }

  // ── Flashcard section ──────────────────────────────────────────────────────

  Widget _buildFlashcardSection(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_answerRevealed)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answer',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.card.answer,
                  style: tt.bodyLarge?.copyWith(color: cs.onPrimaryContainer),
                ),
              ],
            ),
          )
        else
          FilledButton.tonal(
            onPressed: () => setState(() => _answerRevealed = true),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reveal Answer'),
          ),
      ],
    );
  }

  // ── MCQ section ────────────────────────────────────────────────────────────

  Widget _buildMcqSection(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(widget.card.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _optionColor(i, cs),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline.withOpacity(0.3)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                // Disable tapping after a selection is made
                onTap: _selectedIndex != null
                    ? null
                    : () => setState(() => _selectedIndex = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Text(
                    widget.card.options[i],
                    style: tt.bodyLarge?.copyWith(
                      color: _optionTextColor(i, cs),
                      fontWeight: _selectedIndex != null &&
                              i == widget.card.correctIndex
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // Result feedback
        if (_selectedIndex != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect ? cs.primary : cs.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCorrect ? 'Correct!' : 'Wrong — see highlighted answer',
                  style: TextStyle(
                    color: _isCorrect ? cs.primary : cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
