import SwiftUI

@main
struct AlexasDeutscheDictionaryApp: App {
    @StateObject private var store = DictionaryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
