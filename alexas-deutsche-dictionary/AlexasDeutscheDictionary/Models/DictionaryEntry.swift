import Foundation

struct DictionaryEntry: Identifiable, Codable, Hashable {
    let id: String
    let de: String
    let article: String?
    let plural: String?
    let pos: String
    let en: String
    let exampleDe: String
    let exampleEn: String
    let cefr: String

    var displayHeadword: String {
        if let article, !article.isEmpty {
            return "\(article) \(de)"
        }
        return de
    }

    var partOfSpeechLabel: String {
        switch pos {
        case "noun": return "Noun"
        case "verb": return "Verb"
        case "adjective": return "Adjective"
        case "adverb": return "Adverb"
        case "interjection": return "Expression"
        default: return pos.capitalized
        }
    }
}
