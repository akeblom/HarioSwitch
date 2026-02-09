import Foundation

enum ActionType: String, Codable, CaseIterable {
    case pour
    case steep

    var label: String {
        switch self {
        case .pour: "Pour"
        case .steep: "Steep"
        }
    }

    var systemImage: String {
        switch self {
        case .pour: "arrow.down.to.line"
        case .steep: "timer"
        }
    }
}
