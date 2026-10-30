import SwiftUI

struct EntryDetailView: View {
    @EnvironmentObject private var store: DictionaryStore
    let entry: DictionaryEntry
    @State private var appeared = false

    var body: some View {
        ZStack {
            AtmosphereBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    metaRow
                    meaningBlock
                    exampleBlock
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        store.toggleFavorite(entry)
                    }
                } label: {
                    Image(systemName: store.isFavorite(entry) ? "star.fill" : "star")
                        .foregroundStyle(store.isFavorite(entry) ? Brand.amber : Brand.spruce)
                        .symbolEffect(.bounce, value: store.isFavorite(entry))
                }
                .accessibilityLabel(store.isFavorite(entry) ? "Remove from favorites" : "Add to favorites")
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.displayHeadword)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(Brand.ink)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)

            Text(entry.partOfSpeechLabel.uppercased())
                .font(.system(.caption, design: .serif).weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(Brand.spruce)
                .opacity(appeared ? 1 : 0)
        }
    }

    private var metaRow: some View {
        HStack(spacing: 24) {
            if let plural = entry.plural {
                metaItem(title: "Plural", value: plural)
            }
            metaItem(title: "Level", value: entry.cefr)
        }
        .opacity(appeared ? 1 : 0)
    }

    private func metaItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Brand.ink.opacity(0.5))
            Text(value)
                .font(.system(.body, design: .serif).weight(.medium))
                .foregroundStyle(Brand.ink)
        }
    }

    private var meaningBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meaning")
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.ink.opacity(0.55))
            Text(entry.en)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Brand.ink)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var exampleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Example")
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.ink.opacity(0.55))
            Text(entry.exampleDe)
                .font(.system(.body, design: .serif).weight(.medium))
                .foregroundStyle(Brand.ink)
            Text(entry.exampleEn)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Brand.ink.opacity(0.65))
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }
}
