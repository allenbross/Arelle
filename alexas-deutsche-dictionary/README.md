# Alexa’s Deutsche Dictionary

iPhone **German word learning** app: spaced-repetition flashcards, quizzes, progress tracking, plus a searchable word reference.

## Open in Xcode

1. On a Mac with Xcode 15+, open:

   `AlexasDeutscheDictionary.xcodeproj`

2. Select an iPhone simulator (or your device).
3. Press **Run** (⌘R).

Requires **iOS 17+**.

## What you can do

- **Learn** — pick a deck (due, new, favorites, A1, A2, all) and study with flashcards or a quiz
- **Spaced repetition** — Again / Hard / Good / Easy scheduling saved on-device
- **Progress** — streak, reviews today, new / learning / mastered breakdown
- **Words** — look up German ↔ English with article, plural, examples
- **Favorites** — star words and drill them as their own deck
- **Pronunciation** — tap Hear / Pronounce for German speech (`AVSpeechSynthesizer`)

Bundled starter lexicon: ~131 high-frequency A1–A2 words in `Resources/dictionary.json` (replace with your own licensed data later).

## Tabs

| Tab | Purpose |
|---|---|
| Learn | Decks + flashcards + quiz |
| Progress | Mastery and streak |
| Words | Dictionary search |
| Favorites | Starred study list |

## Project layout

```
alexas-deutsche-dictionary/
├── AlexasDeutscheDictionary.xcodeproj
├── AlexasDeutscheDictionary/
│   ├── Models/          # DictionaryEntry, WordProgress
│   ├── Services/        # LearningStore, SpeechHelper
│   ├── Views/           # Learn, flashcards, quiz, progress, words
│   └── Resources/dictionary.json
└── README.md
```

## App Store naming note

“Alexa” is associated with Amazon’s voice assistant. Confirm naming before public App Store submission.
