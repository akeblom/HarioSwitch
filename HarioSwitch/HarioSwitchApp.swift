import SwiftUI
import SwiftData

@main
struct HarioSwitchApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
        }
        .modelContainer(for: Recipe.self) { result in
            if case .success(let container) = result {
                DefaultRecipes.seedIfNeeded(context: container.mainContext)
            }
        }
    }
}
