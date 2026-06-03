// lib/screens/home_screen.dart
//
// SCREEN — HomeScreen
// ────────────────────
// Entry screen. Shows:
//   • App bar with deck count chip
//   • MongoDB Connection status indicators
//   • "Review All" button → opens ReviewScreen at index 0
//   • Vertical ListView of CardListTile widgets (one per card)
//   • Floating Action Button to add new cards (Create)
//
// Data source: MongoDB Atlas via DatabaseService

import 'package:flutter/material.dart';
import '../models/flash_card.dart';
import '../services/database_service.dart';
import '../screens/review_screen.dart';
import '../screens/card_form_screen.dart';
import '../widgets/card_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbService = DatabaseService();
  List<FlashCard> _deck = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cards = await _dbService.getCards();
      setState(() {
        _deck = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Navigation Flow ────────────────────────────────────────────────────────

  void _navigateToAddCard() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CardFormScreen()),
    );
    if (success == true) {
      _fetchCards();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'BrainDump',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 10),
            // Card count badge (only show if connected and not loading)
            if (!_isLoading && _errorMessage == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_deck.length} cards',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          // Review All CTA (Only active if we have cards)
          if (!_isLoading && _errorMessage == null && _deck.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(deck: _deck, initialIndex: 0),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Review All'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),

      // ── Body Layout ────────────────────────────────────────────────────────
      body: _buildBody(cs, tt),

      // ── Add Card FAB ───────────────────────────────────────────────────────
      floatingActionButton: !_isLoading && _dbService.isConnected
          ? FloatingActionButton(
              onPressed: _navigateToAddCard,
              tooltip: 'Add Flashcard',
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Connecting to MongoDB Atlas...',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off_rounded, color: cs.error, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'MongoDB Atlas Error',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchCards,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    if (_deck.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCards,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.style_outlined,
                    size: 80,
                    color: cs.onSurfaceVariant.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Flashcards Found',
                    style: tt.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add cards to get started or pull to refresh.',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _navigateToAddCard,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create First Card'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCards,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _deck.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) => CardListTile(
          card: _deck[index],
          deckIndex: index,
          deck: _deck,
          onRefresh: _fetchCards,
        ),
      ),
    );
  }
}
