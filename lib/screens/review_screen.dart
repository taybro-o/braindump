// lib/screens/review_screen.dart
//
// SCREEN — ReviewScreen
// ──────────────────────
// Swipeable full-screen card review using PageView.
//
// Constructor args:
//   deck         — the List<FlashCard> to review (passed from HomeScreen)
//   initialIndex — which card to open first (0 = start, N = tapped card)
//
// Layout per page:
//   • Progress indicator at top (current / total)
//   • ReviewCard widget (handles flashcard flip OR mcq interaction)
//   • Previous / Next navigation buttons at the bottom
//
// PageController is disposed in the State's dispose() — no leak.

import 'package:flutter/material.dart';
import '../models/flash_card.dart';
import '../widgets/review_card.dart';

class ReviewScreen extends StatefulWidget {
  final List<FlashCard> deck;
  final int initialIndex;

  const ReviewScreen({
    super.key,
    required this.deck,
    this.initialIndex = 0,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final total = widget.deck.length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Review',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        // Progress text on the right
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / $total',
                style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Linear progress bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ((_currentIndex + 1) / total).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ),

          // ── PageView — swipe between cards ───────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) =>
                  setState(() => _currentIndex = index),
              itemBuilder: (_, index) => SingleChildScrollView(
                // Scroll within a page if content overflows (long MCQ options)
                child: ReviewCard(card: widget.deck[index]),
              ),
            ),
          ),

          // ── Bottom navigation row ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button (hidden on first card)
                  _currentIndex > 0
                      ? OutlinedButton.icon(
                          onPressed: () => _goToPage(_currentIndex - 1),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Prev'),
                        )
                      : const SizedBox(width: 100), // placeholder to keep layout

                  // Dot indicators
                  Row(
                    children: List.generate(
                      total.clamp(0, 7), // show max 7 dots to avoid overflow
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _currentIndex ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentIndex
                              ? cs.primary
                              : cs.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Done button
                  _currentIndex < total - 1
                      ? FilledButton.icon(
                          onPressed: () => _goToPage(_currentIndex + 1),
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 18),
                          label: const Text('Next'),
                        )
                      : FilledButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Done'),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
