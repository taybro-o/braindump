# BrainDump — Flutter Flashcard App

## Project Map

```
braindump/
├── pubspec.yaml
└── lib/
    ├── main.dart                  # App entry point + Material 3 theme
    ├── models/
    │   └── flash_card.dart        # FlashCard data model + FormatType enum
    ├── data/
    │   └── mock_cards.dart        # Static List<FlashCard> for development
    ├── screens/
    │   ├── home_screen.dart       # Card list + "Review All" button
    │   └── review_screen.dart     # Swipeable PageView review session
    └── widgets/
        ├── card_list_tile.dart    # Single card row for HomeScreen ListView
        └── review_card.dart       # Interactive card for ReviewScreen PageView
```

---

## Data Model Contract

### `FlashCard` fields

| Field        | Type                    | Description                                      |
|--------------|-------------------------|--------------------------------------------------|
| `subject`    | `String`                | Broad category, e.g. "Computer Science"          |
| `topic`      | `String`                | Unit within subject, e.g. "Binary Trees"         |
| `formatType` | `FormatType` (enum)     | `.flashcard` or `.mcq`                           |
| `content`    | `Map<String, dynamic>`  | Format-specific payload (see key contracts below)|

### `content` key contracts

**FormatType.flashcard**
```dart
{
  'question': String,   // question text
  'answer':   String,   // answer text shown after reveal
}
```

**FormatType.mcq**
```dart
{
  'question':      String,         // question text
  'options':       List<String>,   // option strings (include letter prefix e.g. 'A. ...')
  'correct_index': int,            // 0-based index of the correct option
}
```

---

## Key Implementation Notes (for AI agents)

### Navigation flow
```
HomeScreen
  ├── Taps CardListTile  → ReviewScreen(deck, initialIndex: tappedIndex)
  └── Taps "Review All"  → ReviewScreen(deck, initialIndex: 0)
```

### ReviewScreen state
- `_currentIndex` tracks the active page; updated via `PageController.onPageChanged`.
- `PageController` is created in `initState` and disposed in `dispose`.
- Progress bar value = `(_currentIndex + 1) / deck.length`.

### ReviewCard state (local, resets on page leave)
- **Flashcard**: `_answerRevealed` bool toggles answer panel.
- **MCQ**: `_selectedIndex` (nullable int) — null = no pick; once set, all options lock and feedback shows.
- To persist state across swipes: add `AutomaticKeepAliveClientMixin` to `_ReviewCardState`.

### Theming
- Material 3 with `ColorScheme.fromSeed` — change `seedColor` in `main.dart` to rebrand.
- Dark mode supported via `darkTheme` + `ThemeMode.system`.

---

## Extending the app

| Goal                             | Where to change                                      |
|----------------------------------|------------------------------------------------------|
| Add a new format type            | 1. Add value to `FormatType` enum in `flash_card.dart` 2. Add rendering branch in `review_card.dart` |
| Wire real data                   | Replace `mockCards` in screens with a repository/provider call |
| Add per-card progress tracking   | Add `isCompleted` / `score` fields to `FlashCard`; persist with Hive or SQLite |
| Add subject filter on HomeScreen | Group `mockCards` by `subject`; render section headers in `ListView` |
| Persist MCQ answer across swipes | Add `AutomaticKeepAliveClientMixin` to `_ReviewCardState` |
