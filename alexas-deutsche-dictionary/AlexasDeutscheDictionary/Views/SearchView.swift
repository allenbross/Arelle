import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: LearningStore
    @FocusState private var searchFocused: Bool

    var body: some View {
        ZStack {
            AtmosphereBackground()

            List {
                Section {
                    ForEach(store.filteredEntries) { entry in
                        NavigationLink {
                            EntryDetailView(entry: entry)
                        } label: {
                            EntryRow(entry: entry, isFavorite: store.isFavorite(entry))
                        }
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text(store.searchText.isEmpty
                         ? "\(store.entries.count) words"
                         : "\(store.filteredEntries.count) matches")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Brand.ink.opacity(0.55))
                        .textCase(nil)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .searchable(
                text: $store.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "German or English"
            )
            .focused($searchFocused)
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            searchFocused = true
        }
    }
}
