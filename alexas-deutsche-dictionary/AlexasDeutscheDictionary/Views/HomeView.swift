import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: DictionaryStore
    @State private var appear = false

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        hero
                            .padding(.top, 12)

                        featuredStrip

                        NavigationLink {
                            SearchView()
                        } label: {
                            Label("Search the dictionary", systemImage: "magnifyingglass")
                                .font(.system(.body, design: .serif).weight(.semibold))
                                .foregroundStyle(Brand.paper)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Brand.heroWash)
                        }
                        .buttonStyle(.plain)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 12)

                        NavigationLink {
                            FavoritesView()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Favorites")
                                        .font(.system(.headline, design: .serif))
                                        .foregroundStyle(Brand.ink)
                                    Text("\(store.favorites.count) saved words")
                                        .font(.subheadline)
                                        .foregroundStyle(Brand.ink.opacity(0.65))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Brand.spruce)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    appear = true
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(Brand.shortName)
                .font(.system(size: 42, weight: .bold, design: .serif))
                .foregroundStyle(Brand.ink)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 18)

            Text("Deutsche Dictionary")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(Brand.spruce)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 14)

            Text("Look up German words with articles, plurals, and everyday examples — built for clear study.")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Brand.ink.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(appear ? 1 : 0)
        }
    }

    private var featuredStrip: some View {
        let sample = Array(store.entries.prefix(6))
        return VStack(alignment: .leading, spacing: 12) {
            Text("Start here")
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.ink.opacity(0.55))
                .textCase(.uppercase)
                .tracking(1.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(sample.enumerated()), id: \.element.id) { index, entry in
                        NavigationLink {
                            EntryDetailView(entry: entry)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.displayHeadword)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(Brand.ink)
                                Text(entry.en)
                                    .font(.caption)
                                    .foregroundStyle(Brand.ink.opacity(0.6))
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                            .frame(width: 140, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .opacity(appear ? 1 : 0)
                        .offset(x: appear ? 0 : 20)
                        .animation(.easeOut(duration: 0.55).delay(0.05 * Double(index)), value: appear)
                    }
                }
            }
        }
    }
}
