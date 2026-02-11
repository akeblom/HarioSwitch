import Foundation
import SwiftData

@Model
final class Recipe {
    var name: String
    var coffeeGrams: Double
    var waterML: Double
    var isFavorite: Bool

    @Relationship(deleteRule: .cascade, inverse: \BrewStep.recipe)
    var steps: [BrewStep]

    var sortedSteps: [BrewStep] {
        steps.sorted { $0.sortIndex < $1.sortIndex }
    }

    var totalDurationSeconds: Int {
        steps.reduce(0) { $0 + $1.durationSeconds }
    }

    var ratioString: String {
        guard coffeeGrams > 0 else { return "–" }
        let ratio = waterML / coffeeGrams
        return "1:\(String(format: "%.1f", ratio))"
    }

    var formattedTotalDuration: String {
        let minutes = totalDurationSeconds / 60
        let seconds = totalDurationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    init(name: String, coffeeGrams: Double, waterML: Double, steps: [BrewStep] = [], isFavorite: Bool = false) {
        self.name = name
        self.coffeeGrams = coffeeGrams
        self.waterML = waterML
        self.steps = steps
        self.isFavorite = isFavorite
    }
}
