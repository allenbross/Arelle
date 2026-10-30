import Foundation
import SwiftUI

@MainActor
final class DictionaryStore: ObservableObject {
    @Published private(set) var entries: [DictionaryEntry] = []
    @Published var searchText: String = ""
    @AppStorage("favoriteEntryIds") private var favoriteIdsRaw: String = ""

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

    init() {
        load()
    }

    func load() {
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
