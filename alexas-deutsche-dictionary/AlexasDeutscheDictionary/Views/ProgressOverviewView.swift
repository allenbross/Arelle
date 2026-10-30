import SwiftUI

struct ProgressOverviewView: View {
    @EnvironmentObject private var store: LearningStore

    private var stats: StudyStats { store.stats }

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        Text("Progress")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundStyle(Brand.ink)
                            .padding(.top, 8)

                        Text("Spaced repetition keeps hard words coming back until they stick.")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Brand.ink.opacity(0.65))

                        masteryBars

                        VStack(alignment: .leading, spacing: 12) {
                            metricRow(title: "Day streak", value: "\(stats.streakDays)")
                            metricRow(title: "Reviews today", value: "\(stats.reviewsToday)")
                            metricRow(title: "Words in lexicon", value: "\(store.entries.count)")
                            metricRow(title: "Favorites", value: "\(store.favorites.count)")
                        }

                        NavigationLink {
                            FlashcardSessionView(deck: .due)
                        } label: {
                            Text("Review due words")
                                .font(.system(.body, design: .serif).weight(.semibold))
                                .foregroundStyle(Brand.paper)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Brand.heroWash)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var masteryBars: some View {
        let total = max(store.entries.count, 1)
        return VStack(alignment: .leading, spacing: 14) {
            bar(label: "New", count: stats.newCount, total: total, color: Brand.ink.opacity(0.25))
            bar(label: "Learning", count: stats.learningCount, total: total, color: Brand.amber)
            bar(label: "Mastered", count: stats.masteredCount, total: total, color: Brand.spruce)
        }
    }

    private func bar(label: String, count: Int, total: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(.subheadline, design: .serif).weight(.medium))
                    .foregroundStyle(Brand.ink)
                Spacer()
                Text("\(count)")
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
                    .foregroundStyle(Brand.ink.opacity(0.55))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Brand.ink.opacity(0.06))
                        .frame(height: 8)
                    Rectangle()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(total), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Brand.ink.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(.body, design: .serif).weight(.semibold))
                .foregroundStyle(Brand.ink)
        }
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Brand.ink.opacity(0.08))
                .frame(height: 1)
        }
    }
}
