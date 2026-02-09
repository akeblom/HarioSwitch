import Foundation
import SwiftData

@Model
final class BrewStep {
    var sortIndex: Int
    var durationSeconds: Int
    var actionTypeRaw: String
    var switchPositionRaw: String
    var waterML: Double?
    var recipe: Recipe?

    var actionType: ActionType {
        get { ActionType(rawValue: actionTypeRaw) ?? .pour }
        set { actionTypeRaw = newValue.rawValue }
    }

    var switchPosition: SwitchPosition {
        get { SwitchPosition(rawValue: switchPositionRaw) ?? .closed }
        set { switchPositionRaw = newValue.rawValue }
    }

    init(sortIndex: Int, durationSeconds: Int, actionType: ActionType, switchPosition: SwitchPosition, waterML: Double? = nil) {
        self.sortIndex = sortIndex
        self.durationSeconds = durationSeconds
        self.actionTypeRaw = actionType.rawValue
        self.switchPositionRaw = switchPosition.rawValue
        self.waterML = waterML
    }

    var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)s"
    }
}
