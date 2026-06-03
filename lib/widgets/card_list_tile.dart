// lib/widgets/card_list_tile.dart
//
// WIDGET — CardListTile
// ─────────────────────
// Renders a single FlashCard as a list row on the HomeScreen.
//
// Tapping the tile navigates to ReviewScreen with `startIndex` set to
// this card's position in the full deck.
//
// Includes a popup menu button for Edit and Delete actions on MongoDB.

import 'package:flutter/material.dart';
import '../models/flash_card.dart';
import '../screens/review_screen.dart';
import '../screens/card_form_screen.dart';
import '../services/database_service.dart';

class CardListTile extends StatelessWidget {
  final FlashCard card;

  /// Position of this card in the overall deck — passed to ReviewScreen
  final int deckIndex;

  /// The complete deck — ReviewScreen needs the full list for PageView
  final List<FlashCard> deck;

  /// Callback to reload the list on HomeScreen after database operations
  final VoidCallback? onRefresh;

  const CardListTile({
    super.key,
    required this.card,
    required this.deckIndex,
    required this.deck,
    this.onRefresh,
  });

  // ── Format badge colour ────────────────────────────────────────────────────

  Color _badgeColor(FormatType type, ColorScheme cs) =>
      type == FormatType.flashcard ? cs.primaryContainer : cs.tertiaryContainer;

  Color _badgeTextColor(FormatType type, ColorScheme cs) =>
      type == FormatType.flashcard
          ? cs.onPrimaryContainer
          : cs.onTertiaryContainer;

  String _badgeLabel(FormatType type) =>
      type == FormatType.flashcard ? 'Flashcard' : 'MCQ';

  // ── Actions: Edit & Delete ──────────────────────────────────────────────────

  void _editCard(BuildContext context) async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CardFormScreen(card: card)),
    );
    if (success == true) {
      onRefresh?.call();
    }
  }

  void _confirmDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Flashcard?'),
        content: const Text(
          'Are you sure you want to permanently delete this card from MongoDB Atlas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx); // close dialog
              try {
                if (card.id != null) {
                  await DatabaseService().deleteCard(card.id!);
                  onRefresh?.call();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Card deleted successfully from MongoDB.'),
                        backgroundColor: cs.error,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (errCtx) => AlertDialog(
                      title: const Text('Error Deleting Card'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(errCtx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurfaceVariant),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) {
        if (value == 'edit') {
          _editCard(context);
        } else if (value == 'delete') {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 18, color: cs.error),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: cs.error)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewScreen(
                deck: deck,
                initialIndex: deckIndex,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject + format badge + actions row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.subject,
                      style: tt.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Format type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _badgeColor(card.formatType, cs),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _badgeLabel(card.formatType),
                      style: tt.labelSmall?.copyWith(
                        color: _badgeTextColor(card.formatType, cs),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Action Menu
                  _buildActionsMenu(context),
                ],
              ),
              const SizedBox(height: 6),
              // Topic
              Text(
                card.topic,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              // Question preview (single line, clipped)
              Text(
                card.question,
                style: tt.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
