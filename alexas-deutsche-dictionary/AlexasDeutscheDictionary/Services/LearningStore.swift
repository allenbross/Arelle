import Foundation
import SwiftUI

enum StudyDeck: String, CaseIterable, Identifiable {
    case due
    case new
    case favorites
    case a1
    case a2
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .due: return "Due today"
        case .new: return "New words"
        case .favorites: return "Favorites"
        case .a1: return "A1 starter"
        case .a2: return "A2 stretch"
        case .all: return "Full lexicon"
        }
    }

    var subtitle: String {
        switch self {
        case .due: return "Words waiting for review"
        case .new: return "Never studied yet"
        case .favorites: return "Your starred list"
        case .a1: return "Beginner core"
        case .a2: return "Elementary extras"
        case .all: return "Every bundled word"
        }
    }
}

@MainActor
final class LearningStore: ObservableObject {
    @Published private(set) var entries: [DictionaryEntry] = []
    @Published private(set) var progressById: [String: WordProgress] = [:]
    @Published var searchText: String = ""

    @AppStorage("favoriteEntryIds") private var favoriteIdsRaw: String = ""
    @AppStorage("studyStreakDays") private var streakDays: Int = 0
    @AppStorage("lastStudyDayKey") private var lastStudyDayKey: String = ""
    @AppStorage("reviewsTodayCount") private var reviewsTodayCount: Int = 0
    @AppStorage("reviewsTodayKey") private var reviewsTodayKey: String = ""
    @AppStorage("wordProgressJSON") private var wordProgressJSON: String = "{}"

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var favoriteIds: Set<String> {
        get {
            Set(favoriteIdsRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
        }
        set {
            favoriteIdsRaw = newValue.sorted().joined(separator: ",")
        }
    }

    var favorites: [DictionaryEntry] {
        entries.filter { favoriteIds.contains($0.id) }
            .sorted { $0.de.localizedCaseInsensitiveCompare($1.de) == .orderedAscending }
    }

    var filteredEntries: [DictionaryEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return entries.sorted { $0.de.localizedCaseInsensitiveCompare($1.de) == .orderedAscending }
        }
        return entries.filter { entry in
            entry.de.localizedCaseInsensitiveContains(query)
                || entry.en.localizedCaseInsensitiveContains(query)
                || (entry.article?.localizedCaseInsensitiveContains(query) ?? false)
                || entry.displayHeadword.localizedCaseInsensitiveContains(query)
        }
        .sorted { lhs, rhs in
            rank(lhs, query: query) < rank(rhs, query: query)
        }
    }

    var stats: StudyStats {
        refreshDailyCountersIfNeeded()
        var due = 0
        var newCount = 0
        var learning = 0
        var mastered = 0
        for entry in entries {
            let item = progress(for: entry.id)
            if item.repetitions == 0 {
                newCount += 1
            } else if item.intervalDays < 14 {
                learning += 1
            } else {
                mastered += 1
            }
            if item.isDue { due += 1 }
        }
        return StudyStats(
            dueCount: due,
            newCount: newCount,
            learningCount: learning,
            masteredCount: mastered,
            streakDays: streakDays,
            reviewsToday: reviewsTodayCount
        )
    }

    init() {
        loadEntries()
        loadProgress()
        refreshDailyCountersIfNeeded()
    }

    func progress(for entryId: String) -> WordProgress {
        progressById[entryId] ?? .fresh(entryId: entryId)
    }

    func isFavorite(_ entry: DictionaryEntry) -> Bool {
        favoriteIds.contains(entry.id)
    }

    func toggleFavorite(_ entry: DictionaryEntry) {
        var ids = favoriteIds
        if ids.contains(entry.id) {
            ids.remove(entry.id)
        } else {
            ids.insert(entry.id)
        }
        objectWillChange.send()
        favoriteIds = ids
    }

    func deckCount(_ deck: StudyDeck) -> Int {
        entries(for: deck).count
    }

    func entries(for deck: StudyDeck) -> [DictionaryEntry] {
        switch deck {
        case .due:
            return entries.filter { progress(for: $0.id).isDue }
                .sorted { progress(for: $0.id).dueAt < progress(for: $1.id).dueAt }
        case .new:
            return entries.filter { progress(for: $0.id).repetitions == 0 }
                .sorted { $0.de.localizedCaseInsensitiveCompare($1.de) == .orderedAscending }
        case .favorites:
            return favorites
        case .a1:
            return entries.filter { $0.cefr == "A1" }
                .sorted { $0.de.localizedCaseInsensitiveCompare($1.de) == .orderedAscending }
        case .a2:
            return entries.filter { $0.cefr == "A2" }
                .sorted { $0.de.localizedCaseInsensitiveCompare($1.de) == .orderedAscending }
        case .all:
            return entries.sorted { $0.de.localizedCaseInsensitiveCompare($1.de) == .orderedAscending }
        }
    }

    func recordReview(entryId: String, grade: ReviewGrade) {
        refreshDailyCountersIfNeeded()
        var item = progress(for: entryId)
        item.apply(grade)
        progressById[entryId] = item
        reviewsTodayCount += 1
        markStudiedToday()
        persistProgress()
        objectWillChange.send()
    }

    private func loadEntries() {
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json") else {
            entries = []
            return
        }
        do {
            let data = try Data(contentsOf: url)
            entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        } catch {
            entries = []
        }
    }

    private func loadProgress() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = wordProgressJSON.data(using: .utf8),
              let decoded = try? decoder.decode([String: WordProgress].self, from: data) else {
            progressById = [:]
            return
        }
        progressById = decoded
    }

    private func persistProgress() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(progressById),
              let json = String(data: data, encoding: .utf8) else { return }
        wordProgressJSON = json
    }

    private func refreshDailyCountersIfNeeded() {
        let today = dayFormatter.string(from: Date())
        if reviewsTodayKey != today {
            reviewsTodayKey = today
            reviewsTodayCount = 0
        }
        guard !lastStudyDayKey.isEmpty, lastStudyDayKey != today else { return }
        let calendar = Calendar.current
        guard let last = dayFormatter.date(from: lastStudyDayKey) else { return }
        let gap = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: last),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0
        if gap > 1 {
            streakDays = 0
        }
    }

    private func markStudiedToday() {
        let today = dayFormatter.string(from: Date())
        if lastStudyDayKey == today { return }

        let calendar = Calendar.current
        if let last = dayFormatter.date(from: lastStudyDayKey),
           let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())),
           calendar.isDate(last, inSameDayAs: yesterday) {
            streakDays += 1
        } else {
            streakDays = 1
        }
        lastStudyDayKey = today
    }

    private func rank(_ entry: DictionaryEntry, query: String) -> Int {
        if entry.de.compare(query, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame {
            return 0
        }
        if entry.de.lowercased().hasPrefix(query.lowercased()) {
            return 1
        }
        if entry.en.lowercased().hasPrefix(query.lowercased()) {
            return 2
        }
        return 3
    }
}
