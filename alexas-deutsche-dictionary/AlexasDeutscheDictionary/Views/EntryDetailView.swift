import SwiftUI

struct EntryDetailView: View {
    @EnvironmentObject private var store: LearningStore
    let entry: DictionaryEntry
    @State private var appeared = false

    private var progress: WordProgress {
        store.progress(for: entry.id)
    }

    var body: some View {
        ZStack {
            AtmosphereBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    metaRow
                    meaningBlock
                    exampleBlock
                    studyActions
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

            Button {
                SpeechHelper.speakGerman(entry.displayHeadword)
            } label: {
                Label("Pronounce", systemImage: "speaker.wave.2.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Brand.spruce)
            }
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
        }
    }

    private var metaRow: some View {
        HStack(spacing: 24) {
            if let plural = entry.plural {
                metaItem(title: "Plural", value: plural)
            }
            metaItem(title: "Level", value: entry.cefr)
            metaItem(title: "Status", value: progress.masteryLabel)
        }
        .opacity(appeared ? 1 : 0)
    }

    private var studyActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick review")
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.ink.opacity(0.55))
            HStack(spacing: 10) {
                Button("Still learning") {
                    store.recordReview(entryId: entry.id, grade: .again)
                }
                .buttonStyle(QuickGradeStyle(color: Brand.amber))
                Button("I know it") {
                    store.recordReview(entryId: entry.id, grade: .good)
                }
                .buttonStyle(QuickGradeStyle(color: Brand.spruce))
            }
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

private struct QuickGradeStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .serif).weight(.semibold))
            .foregroundStyle(Brand.paper)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(configuration.isPressed ? 0.85 : 1))
    }
}
