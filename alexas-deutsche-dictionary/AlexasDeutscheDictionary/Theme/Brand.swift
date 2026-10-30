import SwiftUI

enum Brand {
    static let name = "Alexa’s Deutsche Dictionary"
    static let shortName = "Alexa’s"

    /// Alpine mist → spruce ink — academic German feel without cream or purple defaults.
    static let ink = Color(red: 0.12, green: 0.18, blue: 0.20)
    static let spruce = Color(red: 0.14, green: 0.38, blue: 0.34)
    static let spruceDeep = Color(red: 0.08, green: 0.26, blue: 0.24)
    static let mist = Color(red: 0.88, green: 0.93, blue: 0.94)
    static let sky = Color(red: 0.72, green: 0.84, blue: 0.88)
    static let amber = Color(red: 0.78, green: 0.48, blue: 0.18)
    static let paper = Color(red: 0.96, green: 0.97, blue: 0.97)

    static var atmosphere: LinearGradient {
        LinearGradient(
            colors: [
                sky.opacity(0.95),
                mist,
                paper
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroWash: LinearGradient {
        LinearGradient(
            colors: [spruceDeep, spruce, spruce.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
