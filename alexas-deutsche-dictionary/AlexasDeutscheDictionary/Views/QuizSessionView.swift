import SwiftUI

struct QuizSessionView: View {
    @EnvironmentObject private var store: LearningStore
    @Environment(\.dismiss) private var dismiss

    let deck: StudyDeck
    private let questionLimit = 12

    @State private var questions: [QuizQuestion] = []
    @State private var index = 0
    @State private var selectedId: String?
    @State private var score = 0
    @State private var finished = false
    @State private var reveal = false

    private var current: QuizQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    var body: some View {
        ZStack {
            AtmosphereBackground()

            if finished {
                summary
            } else if let question = current {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Question \(index + 1) of \(questions.count)")
                        .font(.system(.subheadline, design: .serif).weight(.medium))
                        .foregroundStyle(Brand.ink.opacity(0.55))

                    Text(question.prompt)
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(Brand.ink)

                    Text(question.promptDetail)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Brand.ink.opacity(0.6))

                    VStack(spacing: 12) {
                        ForEach(question.choices) { choice in
                            choiceButton(choice, question: question)
                        }
                    }

                    Spacer(minLength: 0)

                    if reveal {
                        Button {
                            advance()
                        } label: {
                            Text(index + 1 >= questions.count ? "See results" : "Next")
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
                .padding(.top, 8)
            } else {
                Text("Not enough words for a quiz yet.")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Brand.ink.opacity(0.65))
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: buildQuiz)
    }

    private func choiceButton(_ choice: DictionaryEntry, question: QuizQuestion) -> some View {
        let isSelected = selectedId == choice.id
        let isCorrect = choice.id == question.answer.id
        let showState = reveal && (isSelected || isCorrect)

        return Button {
            guard !reveal else { return }
            selectedId = choice.id
            reveal = true
            if isCorrect {
                score += 1
                store.recordReview(entryId: question.answer.id, grade: .good)
            } else {
                store.recordReview(entryId: question.answer.id, grade: .again)
            }
        } label: {
            HStack {
                Text(choice.en)
                    .font(.system(.body, design: .serif).weight(.medium))
                    .foregroundStyle(Brand.ink)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showState {
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .foregroundStyle(isCorrect ? Brand.spruce : Color(red: 0.62, green: 0.28, blue: 0.24))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 4)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Brand.ink.opacity(0.08))
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(reveal)
        .opacity(reveal && !isSelected && !isCorrect ? 0.45 : 1)
    }

    private var summary: some View {
        VStack(spacing: 16) {
            Text("Quiz done")
                .font(.system(.title, design: .serif).weight(.bold))
                .foregroundStyle(Brand.ink)
            Text("\(score) of \(questions.count) correct")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Brand.spruce)
            Text(scoreMessage)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Brand.ink.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

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

    private var scoreMessage: String {
        let ratio = questions.isEmpty ? 0 : Double(score) / Double(questions.count)
        if ratio >= 0.85 { return "Strong recall — try a harder deck next." }
        if ratio >= 0.6 { return "Solid work. Review the misses with flashcards." }
        return "Keep going — short daily sessions beat long cramming."
    }

    private func buildQuiz() {
        var pool = store.entries(for: deck)
        if pool.count < 4 {
            pool = store.entries(for: .all)
        }
        guard pool.count >= 4 else {
            finished = true
            return
        }
        let prompts = Array(pool.shuffled().prefix(questionLimit))
        questions = prompts.map { answer in
            let distractors = Array(pool.filter { $0.id != answer.id }.shuffled().prefix(3))
            var choices = distractors + [answer]
            choices.shuffle()
            return QuizQuestion(
                id: answer.id,
                prompt: answer.displayHeadword,
                promptDetail: "Choose the English meaning",
                answer: answer,
                choices: choices
            )
        }
        index = 0
        score = 0
        selectedId = nil
        reveal = false
        finished = questions.isEmpty
    }

    private func advance() {
        if index + 1 >= questions.count {
            finished = true
            return
        }
        index += 1
        selectedId = nil
        reveal = false
    }
}

private struct QuizQuestion: Identifiable {
    let id: String
    let prompt: String
    let promptDetail: String
    let answer: DictionaryEntry
    let choices: [DictionaryEntry]
}
