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
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(ActionType.allCases, id: \.self) { type in
                        Button {
                            withAnimation(.snappy(duration: 0.2)) {
                                actionType = type
                            }
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(actionType == type ? type.color.opacity(0.15) : Color(.systemGray6))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: type.systemImage)
                                        .font(.body)
                                        .foregroundStyle(actionType == type ? type.color : .secondary)
                                }
                                Text(type.label)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(actionType == type ? type.color : .secondary)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(actionType == type ? type.color.opacity(0.4) : .clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Switch Position") {
                HStack(spacing: 10) {
                    ForEach(SwitchPosition.allCases, id: \.self) { pos in
                        Button {
                            withAnimation(.snappy(duration: 0.2)) {
                                switchPosition = pos
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: pos.systemImage)
                                    .font(.subheadline)
                                Text(pos.label)
                                    .font(.subheadline.weight(.medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                switchPosition == pos
                                    ? (pos == .open ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                                    : Color(.systemGray6)
                            )
                            .foregroundStyle(
                                switchPosition == pos
                                    ? (pos == .open ? .green : .red)
                                    : .secondary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        switchPosition == pos
                                            ? (pos == .open ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                            : .clear,
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
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
                            .font(.body.monospacedDigit())
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

#Preview("New Step") {
    NavigationStack {
        StepEditorView(recipe: previewRecipe, step: nil)
    }
    .modelContainer(previewContainer)
}

#Preview("Edit Step") {
    NavigationStack {
        StepEditorView(recipe: previewRecipe, step: previewRecipe.sortedSteps.first!)
    }
    .modelContainer(previewContainer)
}
