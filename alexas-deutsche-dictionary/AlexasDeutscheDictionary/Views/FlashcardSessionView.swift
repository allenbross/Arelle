import SwiftUI

struct FlashcardSessionView: View {
    @EnvironmentObject private var store: LearningStore
    @Environment(\.dismiss) private var dismiss

    let deck: StudyDeck
    private let sessionLimit = 20

    @State private var queue: [DictionaryEntry] = []
    @State private var index = 0
    @State private var showAnswer = false
    @State private var reviewed = 0
    @State private var finished = false
    @State private var cardAppear = false

    private var current: DictionaryEntry? {
        guard index < queue.count else { return nil }
        return queue[index]
    }

    var body: some View {
        ZStack {
            AtmosphereBackground()

            if finished || current == nil {
                sessionComplete
            } else if let entry = current {
                VStack(spacing: 20) {
                    progressHeader

                    flashcard(entry)
                        .frame(maxHeight: .infinity)

                    if showAnswer {
                        gradeRow(for: entry)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        Button {
                            withAnimation(.easeOut(duration: 0.28)) {
                                showAnswer = true
                            }
                        } label: {
                            Text("Show meaning")
                                .font(.system(.body, design: .serif).weight(.semibold))
                                .foregroundStyle(Brand.paper)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Brand.heroWash)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: startSession)
    }

    private var progressHeader: some View {
        HStack {
            Text("\(min(index + 1, queue.count)) / \(queue.count)")
                .font(.system(.subheadline, design: .serif).weight(.medium))
                .foregroundStyle(Brand.ink.opacity(0.55))
            Spacer()
            Text("\(reviewed) reviewed")
                .font(.caption)
                .foregroundStyle(Brand.spruce)
        }
    }

    private func flashcard(_ entry: DictionaryEntry) -> some View {
        VStack(spacing: 18) {
            Text(entry.cefr)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Brand.spruce)
                .tracking(1.2)

            Text(entry.displayHeadword)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(Brand.ink)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)

            Button {
                SpeechHelper.speakGerman(entry.displayHeadword)
            } label: {
                Label("Hear it", systemImage: "speaker.wave.2.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Brand.spruce)
            }
            .buttonStyle(.plain)

            if showAnswer {
                VStack(spacing: 10) {
                    Text(entry.en)
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Brand.ink)
                        .multilineTextAlignment(.center)

                    Text(entry.exampleDe)
                        .font(.system(.body, design: .serif).weight(.medium))
                        .foregroundStyle(Brand.ink.opacity(0.85))
                        .multilineTextAlignment(.center)

                    Text(entry.exampleEn)
                        .font(.system(.callout, design: .serif))
                        .italic()
                        .foregroundStyle(Brand.ink.opacity(0.55))
                        .multilineTextAlignment(.center)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Text("Think of the English meaning")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Brand.ink.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .opacity(cardAppear ? 1 : 0)
        .offset(y: cardAppear ? 0 : 12)
    }

    private func gradeRow(for entry: DictionaryEntry) -> some View {
        HStack(spacing: 10) {
            gradeButton("Again", color: Color(red: 0.62, green: 0.28, blue: 0.24)) {
                grade(entry, .again)
            }
            gradeButton("Hard", color: Brand.amber) {
                grade(entry, .hard)
            }
            gradeButton("Good", color: Brand.spruce) {
                grade(entry, .good)
            }
            gradeButton("Easy", color: Brand.spruceDeep) {
                grade(entry, .easy)
            }
        }
    }

    private func gradeButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.paper)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color)
        }
        .buttonStyle(.plain)
    }

    private var sessionComplete: some View {
        VStack(spacing: 16) {
            Text("Session complete")
                .font(.system(.title, design: .serif).weight(.bold))
                .foregroundStyle(Brand.ink)
            Text(reviewed == 0
                 ? "No cards in this deck right now."
                 : "You reviewed \(reviewed) word\(reviewed == 1 ? "" : "s"). Keep the streak going.")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Brand.ink.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                dismiss()
            } label: {
                Text("Back to Learn")
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .foregroundStyle(Brand.paper)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Brand.heroWash)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.top, 8)
        }
    }

    private func startSession() {
        var cards = store.entries(for: deck)
        if deck == .due && cards.isEmpty {
            cards = Array(store.entries(for: .new).prefix(sessionLimit))
        }
        queue = Array(cards.prefix(sessionLimit))
        index = 0
        showAnswer = false
        reviewed = 0
        finished = queue.isEmpty
        withAnimation(.easeOut(duration: 0.45)) {
            cardAppear = true
        }
    }

    private func grade(_ entry: DictionaryEntry, _ grade: ReviewGrade) {
        store.recordReview(entryId: entry.id, grade: grade)
        reviewed += 1
        cardAppear = false
        showAnswer = false

        if index + 1 >= queue.count {
            finished = true
            return
        }
        index += 1
        withAnimation(.easeOut(duration: 0.35)) {
            cardAppear = true
        }
    }
}
