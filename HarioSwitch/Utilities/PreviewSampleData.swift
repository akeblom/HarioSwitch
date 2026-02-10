import SwiftData
import SwiftUI

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)

    let recipe = Recipe(name: "Kasuya Devil Switch", coffeeGrams: 20, waterML: 280, steps: [
        BrewStep(sortIndex: 0, durationSeconds: 30, actionType: .bloom, switchPosition: .open, waterML: 50),
        BrewStep(sortIndex: 1, durationSeconds: 30, actionType: .pour, switchPosition: .open, waterML: 70),
        BrewStep(sortIndex: 2, durationSeconds: 15, actionType: .pour, switchPosition: .closed, waterML: 160),
        BrewStep(sortIndex: 3, durationSeconds: 30, actionType: .steep, switchPosition: .closed),
        BrewStep(sortIndex: 4, durationSeconds: 90, actionType: .drain, switchPosition: .open),
    ])
    container.mainContext.insert(recipe)

    let recipe2 = Recipe(name: "Basic Immersion", coffeeGrams: 20, waterML: 240, steps: [
        BrewStep(sortIndex: 0, durationSeconds: 15, actionType: .pour, switchPosition: .closed, waterML: 240),
        BrewStep(sortIndex: 1, durationSeconds: 120, actionType: .steep, switchPosition: .closed),
        BrewStep(sortIndex: 2, durationSeconds: 60, actionType: .drain, switchPosition: .open),
    ])
    container.mainContext.insert(recipe2)

    return container
}()

@MainActor
let previewRecipe: Recipe = {
    let descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.name == "Kasuya Devil Switch" })
    return try! previewContainer.mainContext.fetch(descriptor).first!
}()
