import SwiftUI
import SwiftData

struct StepEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe
    let step: BrewStep?

    @State private var durationSeconds: Int
    @State private var actionType: ActionType
    @State private var switchPosition: SwitchPosition
    @State private var waterML: Double?

    private var isNew: Bool { step == nil }

    init(recipe: Recipe, step: BrewStep?) {
        self.recipe = recipe
        self.step = step
        _durationSeconds = State(initialValue: step?.durationSeconds ?? 30)
        _actionType = State(initialValue: step?.actionType ?? .pour)
        _switchPosition = State(initialValue: step?.switchPosition ?? .closed)
        _waterML = State(initialValue: step?.waterML)
    }

    var body: some View {
        Form {
            Section("Action") {
                Picker("Type", selection: $actionType) {
                    ForEach(ActionType.allCases, id: \.self) { type in
                        Label(type.label, systemImage: type.systemImage)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Switch Position") {
                Picker("Position", selection: $switchPosition) {
                    ForEach(SwitchPosition.allCases, id: \.self) { pos in
                        Text(pos.label).tag(pos)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Water") {
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("ml", value: $waterML, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("ml")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Duration") {
                Stepper(value: $durationSeconds, in: 5...600, step: 5) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(formattedDuration)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(isNew ? "Add Step" : "Edit Step")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                    dismiss()
                }
            }
        }
    }

    private var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)s"
    }

    private func save() {
        if let step {
            step.durationSeconds = durationSeconds
            step.actionType = actionType
            step.switchPosition = switchPosition
            step.waterML = waterML
        } else {
            let newStep = BrewStep(
                sortIndex: recipe.steps.count,
                durationSeconds: durationSeconds,
                actionType: actionType,
                switchPosition: switchPosition,
                waterML: waterML
            )
            recipe.steps.append(newStep)
        }
    }
}
