// lib/models/flash_card.dart
//
// DATA MODEL — FlashCard
// ──────────────────────
// Represents a single review card. Two format types are supported:
//
//   FormatType.flashcard → content map requires keys: 'question', 'answer'
//   FormatType.mcq       → content map requires keys: 'question', 'options' (List<String>), 'correct_index' (int)
//
// The `content` field is intentionally dynamic so new formats can be added
// without changing the model's shape — just document the new key contract here.

enum FormatType { flashcard, mcq }

class FlashCard {
  /// Unique identifier (corresponds to MongoDB _id)
  final String? id;

  /// Broad category, e.g. "Computer Science", "Mathematics"
  final String subject;

  /// Specific unit within the subject, e.g. "Binary Trees", "Calculus I"
  final String topic;

  /// Determines how the review UI renders this card
  final FormatType formatType;

  /// Flexible payload — see key contracts in the file-level comment above
  final Map<String, dynamic> content;

  const FlashCard({
    this.id,
    required this.subject,
    required this.topic,
    required this.formatType,
    required this.content,
  });

  // ── Serialization / Deserialization ────────────────────────────────────────

  /// Constructs a FlashCard from a Map (retrieved from MongoDB document)
  factory FlashCard.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    String? idStr;
    if (rawId != null) {
      if (rawId is String) {
        idStr = rawId;
      } else {
        // Safe cast for mongo_dart's ObjectId
        try {
          idStr = (rawId as dynamic).toHexString();
        } catch (_) {
          idStr = rawId.toString();
        }
      }
    }

    final formatStr = map['formatType'] as String? ?? 'flashcard';
    final formatType = FormatType.values.firstWhere(
      (e) => e.name == formatStr,
      orElse: () => FormatType.flashcard,
    );

    return FlashCard(
      id: idStr,
      subject: map['subject'] as String? ?? '',
      topic: map['topic'] as String? ?? '',
      formatType: formatType,
      content: Map<String, dynamic>.from(map['content'] as Map? ?? {}),
    );
  }

  /// Converts the FlashCard to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'subject': subject,
      'topic': topic,
      'formatType': formatType.name,
      'content': content,
    };
  }

  // ── Convenience getters ────────────────────────────────────────────────────

  /// Safe getter for the question text present in both formats
  String get question => content['question'] as String? ?? '';

  /// Flashcard only — the answer text
  String get answer => content['answer'] as String? ?? '';

  /// MCQ only — list of option strings
  List<String> get options =>
      (content['options'] as List?)?.map((e) => e.toString()).toList() ?? [];

  /// MCQ only — zero-based index of the correct option
  int get correctIndex => content['correct_index'] as int? ?? 0;
}
