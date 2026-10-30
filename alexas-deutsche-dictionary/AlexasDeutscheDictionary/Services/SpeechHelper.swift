import AVFoundation
import Foundation

enum SpeechHelper {
    private static let synthesizer = AVSpeechSynthesizer()

    static func speakGerman(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
            ?? AVSpeechSynthesisVoice(language: "de-AT")
            ?? AVSpeechSynthesisVoice(language: "de-CH")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        synthesizer.speak(utterance)
    }
}
