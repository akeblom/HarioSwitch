import Foundation

enum SwitchPosition: String, Codable, CaseIterable {
    case open
    case closed

    var label: String {
        switch self {
        case .open: "Open"
        case .closed: "Closed"
        }
    }

    var systemImage: String {
        switch self {
        case .open: "lock.open"
        case .closed: "lock"
        }
    }
}
