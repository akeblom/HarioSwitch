import Foundation
import SwiftData

struct DefaultRecipes {
  static func seedIfNeeded(context: ModelContext) {
    let descriptor = FetchDescriptor<Recipe>()
    let count = (try? context.fetchCount(descriptor)) ?? 0
    guard count == 0 else { return }
    
    let basicImmersion = Recipe(name: "Basic Immersion", coffeeGrams: 20, waterML: 240, steps: [
      BrewStep(sortIndex: 0, durationSeconds: 15, actionType: .bloom, switchPosition: .closed, waterML: 240),
      BrewStep(sortIndex: 1, durationSeconds: 120, actionType: .steep, switchPosition: .closed),
      BrewStep(sortIndex: 2, durationSeconds: 60, actionType: .drain, switchPosition: .open),
    ])
    
    let sherrycipe = Recipe(name: "Sherrycipe", coffeeGrams: 16, waterML: 240, steps: [
      BrewStep(sortIndex: 0, durationSeconds: 30, actionType: .bloom, switchPosition: .open, waterML: 50),
      BrewStep(sortIndex: 1, durationSeconds: 30, actionType: .pour, switchPosition: .open, waterML: 100),
      BrewStep(sortIndex: 2, durationSeconds: 30, actionType: .pour, switchPosition: .closed, waterML: 90),
      BrewStep(sortIndex: 3, durationSeconds: 30, actionType: .drain, switchPosition: .open),
      
    ])

    let kasuyaDevilSwitch = Recipe(name: "Kasuya Devil Switch", coffeeGrams: 20, waterML: 280, steps: [
        BrewStep(sortIndex: 0, durationSeconds: 30, actionType: .pour, switchPosition: .open, waterML: 50),
        BrewStep(sortIndex: 1, durationSeconds: 30, actionType: .pour, switchPosition: .open, waterML: 70),
        BrewStep(sortIndex: 2, durationSeconds: 15, actionType: .pour, switchPosition: .closed, waterML: 160),
        BrewStep(sortIndex: 3, durationSeconds: 30, actionType: .steep, switchPosition: .closed),
        BrewStep(sortIndex: 4, durationSeconds: 90, actionType: .drain, switchPosition: .open),
    ])

    let hybridPourOver = Recipe(name: "Hybrid Pour Over", coffeeGrams: 20, waterML: 300, steps: [
        BrewStep(sortIndex: 0, durationSeconds: 30, actionType: .bloom, switchPosition: .closed, waterML: 60),
        BrewStep(sortIndex: 1, durationSeconds: 30, actionType: .steep, switchPosition: .closed),
        BrewStep(sortIndex: 2, durationSeconds: 30, actionType: .pour, switchPosition: .open, waterML: 120),
        BrewStep(sortIndex: 3, durationSeconds: 15, actionType: .pour, switchPosition: .closed, waterML: 120),
        BrewStep(sortIndex: 4, durationSeconds: 60, actionType: .steep, switchPosition: .closed),
        BrewStep(sortIndex: 5, durationSeconds: 60, actionType: .drain, switchPosition: .open),
    ])

    context.insert(basicImmersion)
    context.insert(kasuyaDevilSwitch)
    context.insert(hybridPourOver)
    context.insert(sherrycipe)
  }
}
