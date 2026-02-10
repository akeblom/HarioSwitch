import Foundation
import SwiftUI

enum ActionType: String, Codable, CaseIterable {
    case bloom
    case pour
    case steep
    case drain

    var label: String {
        switch self {
        case .bloom: "Bloom"
        case .pour: "Pour"
        case .steep: "Steep"
        case .drain: "Drain"
        }
    }

    var systemImage: String {
        switch self {
        case .bloom: "drop.degreesign"
        case .pour: "arrow.down.to.line"
        case .steep: "timer"
        case .drain: "arrow.down.right"
        }
    }

    var color: Color {
        switch self {
        case .bloom: .purple
        case .pour: .blue
        case .steep: .orange
        case .drain: .green
        }
    }
}
