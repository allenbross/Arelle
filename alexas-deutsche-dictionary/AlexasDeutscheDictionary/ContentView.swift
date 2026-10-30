import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DictionaryStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
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
        .environmentObject(DictionaryStore())
}
