import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var store: DictionaryStore

    var body: some View {
        ZStack {
            AtmosphereBackground()

            if store.favorites.isEmpty {
                VStack(spacing: 12) {
                    Text("No favorites yet")
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(Brand.ink)
                    Text("Open any word and tap the star to save it here for later study.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Brand.ink.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                List {
                    ForEach(store.favorites) { entry in
                        NavigationLink {
                            EntryDetailView(entry: entry)
                        } label: {
                            EntryRow(entry: entry, isFavorite: true)
                        }
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.toggleFavorite(entry)
                            } label: {
                                Label("Remove", systemImage: "star.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
}
