import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: LearningStore
    @State private var appear = false
    @State private var selectedDeck: StudyDeck = .due

    private var stats: StudyStats { store.stats }

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        hero
                            .padding(.top, 8)

                        statsRow

                        practiceActions

                        deckPicker

                        Text("Open Words to look up articles, plurals, and examples anytime.")
                            .font(.system(.footnote, design: .serif))
                            .foregroundStyle(Brand.ink.opacity(0.5))
                            .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 22)
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
        VStack(alignment: .leading, spacing: 12) {
            Text(Brand.shortName)
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundStyle(Brand.ink)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 16)

            Text("German Words")
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(Brand.spruce)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)

            Text("Learn vocabulary with spaced flashcards and quick quizzes — then look words up when you need them.")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Brand.ink.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(appear ? 1 : 0)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statBlock(value: "\(stats.dueCount)", label: "Due")
            statBlock(value: "\(stats.streakDays)", label: "Streak")
            statBlock(value: "\(stats.reviewsToday)", label: "Today")
            statBlock(value: "\(stats.masteredCount)", label: "Mastered")
        }
        .opacity(appear ? 1 : 0)
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .serif).weight(.bold))
                .foregroundStyle(Brand.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(Brand.ink.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var practiceActions: some View {
        VStack(spacing: 12) {
            NavigationLink {
                FlashcardSessionView(deck: selectedDeck)
            } label: {
                Label("Study flashcards", systemImage: "rectangle.on.rectangle.angled")
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .foregroundStyle(Brand.paper)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Brand.heroWash)
            }
            .buttonStyle(.plain)
            .disabled(store.deckCount(selectedDeck) == 0 && selectedDeck != .due)
            .opacity(store.deckCount(selectedDeck) == 0 && selectedDeck != .due ? 0.45 : 1)

            NavigationLink {
                QuizSessionView(deck: selectedDeck)
            } label: {
                HStack {
                    Text("Take a quiz")
                        .font(.system(.body, design: .serif).weight(.semibold))
                        .foregroundStyle(Brand.ink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Brand.spruce)
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
    }

    private var deckPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Study deck")
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.ink.opacity(0.55))
                .textCase(.uppercase)
                .tracking(1.2)

            ForEach(StudyDeck.allCases) { deck in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedDeck = deck
                    }
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(deck.title)
                                .font(.system(.body, design: .serif).weight(.semibold))
                                .foregroundStyle(Brand.ink)
                            Text(deck.subtitle)
                                .font(.caption)
                                .foregroundStyle(Brand.ink.opacity(0.55))
                        }
                        Spacer()
                        Text("\(store.deckCount(deck))")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(selectedDeck == deck ? Brand.spruce : Brand.ink.opacity(0.35))
                    }
                    .padding(.vertical, 8)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Brand.ink.opacity(selectedDeck == deck ? 0.18 : 0.06))
                            .frame(height: selectedDeck == deck ? 2 : 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
