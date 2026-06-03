// lib/screens/card_form_screen.dart
//
// SCREEN — CardFormScreen
// ───────────────────────
// Dialog/Screen for creating a new FlashCard or editing an existing one.
// Validates fields and saves them to MongoDB via DatabaseService.

import 'package:flutter/material.dart';
import '../models/flash_card.dart';
import '../services/database_service.dart';

class CardFormScreen extends StatefulWidget {
  final FlashCard? card;

  const CardFormScreen({super.key, this.card});

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();

  late String _subject;
  late String _topic;
  late FormatType _formatType;

  // Flashcard-specific inputs
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  // MCQ-specific inputs
  late List<TextEditingController> _optionControllers;
  late int _correctIndex;

  bool _isSaving = false;
  bool get _isEditMode => widget.card != null;

  @override
  void initState() {
    super.initState();
    final card = widget.card;

    _subject = card?.subject ?? '';
    _topic = card?.topic ?? '';
    _formatType = card?.formatType ?? FormatType.flashcard;

    _questionController = TextEditingController(text: card?.question ?? '');
    _answerController = TextEditingController(text: card?.answer ?? '');

    // MCQ setup
    final existingOptions = card?.options ?? [];
    _optionControllers = List.generate(4, (index) {
      String initialVal = '';
      if (existingOptions.length > index) {
        initialVal = existingOptions[index];
      } else {
        // Pre-fill prefixes for standard options
        initialVal = '${String.fromCharCode(65 + index)}. '; // A. , B. etc.
      }
      return TextEditingController(text: initialVal);
    });

    _correctIndex = card?.correctIndex ?? 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ── Action: Save ───────────────────────────────────────────────────────────

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    // Build the content payload based on FormatType
    Map<String, dynamic> contentPayload = {};
    if (_formatType == FormatType.flashcard) {
      contentPayload = {
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
      };
    } else {
      contentPayload = {
        'question': _questionController.text.trim(),
        'options': _optionControllers.map((c) => c.text.trim()).toList(),
        'correct_index': _correctIndex,
      };
    }

    final savedCard = FlashCard(
      id: widget.card?.id, // Keep the same ID if editing
      subject: _subject.trim(),
      topic: _topic.trim(),
      formatType: _formatType,
      content: contentPayload,
    );

    try {
      if (_isEditMode) {
        await _dbService.updateCard(savedCard);
      } else {
        await _dbService.addCard(savedCard);
      }
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Card updated in MongoDB!' : 'Card added to MongoDB!',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Database Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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
        title: Text(
          _isEditMode ? 'Edit Flashcard' : 'New Flashcard',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: _isSaving
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Saving to MongoDB Atlas...',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Metadata Card (Subject & Topic) ────────────────────────
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    color: cs.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Metadata',
                            style: tt.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _subject,
                            decoration: const InputDecoration(
                              labelText: 'Subject',
                              hintText: 'e.g., Computer Science, Mathematics',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.school_rounded),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Subject is required'
                                : null,
                            onSaved: (val) => _subject = val!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _topic,
                            decoration: const InputDecoration(
                              labelText: 'Topic',
                              hintText: 'e.g., Binary Trees, Operating Systems',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.topic_rounded),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Topic is required'
                                : null,
                            onSaved: (val) => _topic = val!,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Format Selector ────────────────────────────────────────
                  DropdownButtonFormField<FormatType>(
                    value: _formatType,
                    decoration: const InputDecoration(
                      labelText: 'Format Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: FormatType.flashcard,
                        child: Text('Classic Flashcard'),
                      ),
                      DropdownMenuItem(
                        value: FormatType.mcq,
                        child: Text('Multiple Choice (MCQ)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _formatType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Question Input (Common to both formats) ────────────────
                  TextFormField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      hintText: 'Write the review question here...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Question is required'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Format-Specific Input Panels ───────────────────────────
                  if (_formatType == FormatType.flashcard)
                    _buildFlashcardPanel(cs, tt)
                  else
                    _buildMcqPanel(cs, tt),

                  const SizedBox(height: 32),

                  // ── Save CTA Button ────────────────────────────────────────
                  FilledButton.icon(
                    onPressed: _saveForm,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_isEditMode ? 'Update Card' : 'Save to MongoDB'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Helper Panels ──────────────────────────────────────────────────────────

  Widget _buildFlashcardPanel(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _answerController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Correct Answer',
            hintText: 'Provide the detailed correct answer...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (val) =>
              _formatType == FormatType.flashcard && (val == null || val.trim().isEmpty)
                  ? 'Answer is required for flashcards'
                  : null,
        ),
      ],
    );
  }

  Widget _buildMcqPanel(ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MCQ Options & Correct Answer',
              style: tt.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Options inputs
            ...List.generate(4, (index) {
              final label = String.fromCharCode(65 + index); // A, B, C, D
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Option $label',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (val) =>
                      _formatType == FormatType.mcq && (val == null || val.trim().isEmpty)
                          ? 'Option $label is required'
                          : null,
                ),
              );
            }),
            const SizedBox(height: 8),
            // Correct option index selection
            DropdownButtonFormField<int>(
              value: _correctIndex,
              decoration: const InputDecoration(
                labelText: 'Correct Option',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.check_circle_outline_rounded),
              ),
              items: List.generate(4, (index) {
                final label = String.fromCharCode(65 + index); // A, B, C, D
                return DropdownMenuItem(
                  value: index,
                  child: Text('Option $label'),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _correctIndex = val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
