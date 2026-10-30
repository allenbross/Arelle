import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LearningStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Learn", systemImage: "book.closed")
                }

            ProgressOverviewView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Words", systemImage: "magnifyingglass")
            }

            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "star")
            }
        }
        .tint(Brand.spruce)
    }
}

#Preview {
    ContentView()
        .environmentObject(LearningStore())
}
