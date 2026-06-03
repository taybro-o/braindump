// lib/data/mock_cards.dart
//
// MOCK DATA SOURCE
// ────────────────
// Returns a static list of FlashCard objects for development / UI preview.
// Replace this with a repository that reads from a local DB (e.g. Hive, SQLite)
// or a remote API when you're ready to wire up real data.

import '../models/flash_card.dart';

final List<FlashCard> mockCards = [
  // ── Flashcard format examples ──────────────────────────────────────────────

  const FlashCard(
    subject: 'Computer Science',
    topic: 'Data Structures',
    formatType: FormatType.flashcard,
    content: {
      'question': 'What is the time complexity of binary search?',
      'answer':
          'O(log n) — each comparison halves the remaining search space.',
    },
  ),

  const FlashCard(
    subject: 'Computer Science',
    topic: 'Operating Systems',
    formatType: FormatType.flashcard,
    content: {
      'question': 'What is a deadlock?',
      'answer':
          'A state where two or more processes are each waiting for a resource held by the other, causing all of them to block indefinitely.',
    },
  ),

  const FlashCard(
    subject: 'Mathematics',
    topic: 'Calculus',
    formatType: FormatType.flashcard,
    content: {
      'question': "What does the derivative f'(x) represent geometrically?",
      'answer': 'The slope of the tangent line to f(x) at the point x.',
    },
  ),

  // ── MCQ format examples ────────────────────────────────────────────────────

  const FlashCard(
    subject: 'Computer Science',
    topic: 'Networking',
    formatType: FormatType.mcq,
    content: {
      'question': 'Which layer of the OSI model handles routing between networks?',
      'options': [
        'A. Data Link Layer',
        'B. Transport Layer',
        'C. Network Layer',
        'D. Session Layer',
      ],
      'correct_index': 2, // C. Network Layer
    },
  ),

  const FlashCard(
    subject: 'Computer Science',
    topic: 'Assembly Language',
    formatType: FormatType.mcq,
    content: {
      'question': 'In x86 assembly, which flag is set when an arithmetic result is zero?',
      'options': [
        'A. Carry Flag (CF)',
        'B. Overflow Flag (OF)',
        'C. Sign Flag (SF)',
        'D. Zero Flag (ZF)',
      ],
      'correct_index': 3, // D. Zero Flag
    },
  ),

  const FlashCard(
    subject: 'Cryptography',
    topic: 'Symmetric Encryption',
    formatType: FormatType.mcq,
    content: {
      'question': 'Which algorithm uses a 128/192/256-bit key and replaced DES as the US standard?',
      'options': [
        'A. RSA',
        'B. AES',
        'C. SHA-256',
        'D. Blowfish',
      ],
      'correct_index': 1, // B. AES
    },
  ),

  const FlashCard(
    subject: 'Mathematics',
    topic: 'Linear Algebra',
    formatType: FormatType.flashcard,
    content: {
      'question': 'What condition must hold for a matrix to be invertible?',
      'answer': 'Its determinant must be non-zero (det(A) ≠ 0).',
    },
  ),
];
