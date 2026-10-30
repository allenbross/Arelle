import Foundation

enum ReviewGrade: String, Codable {
    case again
    case hard
    case good
    case easy
}

struct WordProgress: Codable, Hashable {
    var entryId: String
    var repetitions: Int
    var intervalDays: Double
    var ease: Double
    var dueAt: Date
    var lastReviewedAt: Date?
    var lapses: Int

    static func fresh(entryId: String, dueAt: Date = .distantPast) -> WordProgress {
        WordProgress(
            entryId: entryId,
            repetitions: 0,
            intervalDays: 0,
            ease: 2.5,
            dueAt: dueAt,
            lastReviewedAt: nil,
            lapses: 0
        )
    }

    var isDue: Bool {
        dueAt <= Date()
    }

    /// Lightweight SM-2-style scheduling for vocabulary drills.
    mutating func apply(_ grade: ReviewGrade, now: Date = Date()) {
        lastReviewedAt = now

        switch grade {
        case .again:
            repetitions = 0
            lapses += 1
            intervalDays = 0
            dueAt = now.addingTimeInterval(10 * 60) // 10 minutes
            ease = max(1.3, ease - 0.2)

        case .hard:
            if repetitions == 0 {
                intervalDays = 0.5
            } else {
                intervalDays = max(1, intervalDays * 1.2)
            }
            repetitions += 1
            ease = max(1.3, ease - 0.15)
            dueAt = now.addingTimeInterval(intervalDays * 86_400)

        case .good:
            if repetitions == 0 {
                intervalDays = 1
            } else if repetitions == 1 {
                intervalDays = 3
            } else {
                intervalDays = intervalDays * ease
            }
            repetitions += 1
            dueAt = now.addingTimeInterval(intervalDays * 86_400)

        case .easy:
            if repetitions == 0 {
                intervalDays = 3
            } else if repetitions == 1 {
                intervalDays = 6
            } else {
                intervalDays = intervalDays * ease * 1.3
            }
            repetitions += 1
            ease = min(3.0, ease + 0.15)
            dueAt = now.addingTimeInterval(intervalDays * 86_400)
        }
    }

    var masteryLabel: String {
        if repetitions == 0 { return "New" }
        if intervalDays < 3 { return "Learning" }
        if intervalDays < 14 { return "Familiar" }
        return "Mastered"
    }
}

struct StudyStats: Equatable {
    var dueCount: Int
    var newCount: Int
    var learningCount: Int
    var masteredCount: Int
    var streakDays: Int
    var reviewsToday: Int
}
