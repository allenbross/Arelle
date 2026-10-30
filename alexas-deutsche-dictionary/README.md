# Alexa’s Deutsche Dictionary

iPhone dictionary app for learning German: search German ↔ English entries, see gender/plural/examples, and save favorites for later study.

## Open in Xcode

1. On a Mac with Xcode 15+, open:

   `AlexasDeutscheDictionary.xcodeproj`

2. Select an iPhone simulator (or your device).
3. Press **Run** (⌘R).

Requires **iOS 17+**.

## What’s in the MVP

- Branded home + search for German or English
- Entry detail: article, plural, part of speech, meaning, example sentence
- Favorites (on-device, via `AppStorage`)
- Bundled starter lexicon (~120 high-frequency A1–A2 words) — replace/extend `Resources/dictionary.json` with your own licensed data later

## Project layout

```
alexas-deutsche-dictionary/
├── AlexasDeutscheDictionary.xcodeproj
├── AlexasDeutscheDictionary/
│   ├── AlexasDeutscheDictionaryApp.swift
│   ├── ContentView.swift
│   ├── Models/
│   ├── Views/
│   ├── Services/
│   └── Resources/dictionary.json
└── README.md
```

## App Store naming note

“Alexa” is associated with Amazon’s voice assistant. Before App Store submission, confirm the name does not conflict with Apple’s trademark review or Amazon’s marks; a personal/family name pairing (e.g. this title) is often fine for private use, but public distribution may need legal review.

## Next ideas

- Import Anki/Quizlet-style flashcard decks
- Text-to-speech pronunciation (`AVSpeechSynthesizer`)
- Offline CEFR-tagged word lists (A1→B2)
- Widget for “word of the day”
