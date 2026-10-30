import SwiftUI

struct EntryRow: View {
    let entry: DictionaryEntry
    var isFavorite: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.displayHeadword)
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .foregroundStyle(Brand.ink)
                Text(entry.en)
                    .font(.subheadline)
                    .foregroundStyle(Brand.ink.opacity(0.62))
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.cefr)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Brand.spruce)
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Brand.amber)
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.displayHeadword), \(entry.en), level \(entry.cefr)")
    }
}
