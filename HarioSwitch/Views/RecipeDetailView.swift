import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var recipe: Recipe
    private let isNew: Bool

    @State private var editingStep: BrewStep?
    @State private var showingStepEditor = false
    @State private var showingBrewTimer = false

    init(recipe: Recipe?) {
        if let recipe {
            self.recipe = recipe
            self.isNew = false
        } else {
            let newRecipe = Recipe(name: "", coffeeGrams: 20, waterML: 300)
            self.recipe = newRecipe
            self.isNew = true
        }
    }

    var body: some View {
        Form {
            Section("Recipe Info") {
                TextField("Recipe Name", text: $recipe.name)
                HStack {
                    Text("Coffee")
                    Spacer()
                    TextField("Grams", value: $recipe.coffeeGrams, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("g")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Water")
                    Spacer()
                    TextField("mL", value: $recipe.waterML, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("ml")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Ratio")
                    Spacer()
                    Text(recipe.ratioString)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                ForEach(recipe.sortedSteps) { step in
                    Button {
                        editingStep = step
                        showingStepEditor = true
                    } label: {
                        StepRowView(step: step)
                    }
                    .tint(.primary)
                }
                .onDelete(perform: deleteSteps)
                .onMove(perform: moveSteps)

                Button {
                    editingStep = nil
                    showingStepEditor = true
                } label: {
                    Label("Add Step", systemImage: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            } header: {
                HStack {
                    Text("Steps")
                    Spacer()
                    Text(recipe.formattedTotalDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !recipe.steps.isEmpty {
                Section {
                    Button {
                        showingBrewTimer = true
                    } label: {
                        HStack(spacing: 10) {
                            Spacer()
                            Image(systemName: "play.fill")
                                .font(.body)
                            Text("Start Brew")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .foregroundStyle(.white)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.accentColor.gradient)
                            .padding(.vertical, 2)
                            .padding(.horizontal, -4)
                    )
                }
            }
        }
        .navigationTitle(isNew ? "New Recipe" : recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        modelContext.delete(recipe)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                    .disabled(recipe.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            if !isNew {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .onAppear {
            if isNew {
                modelContext.insert(recipe)
            }
        }
        .sheet(isPresented: $showingStepEditor) {
            NavigationStack {
                StepEditorView(recipe: recipe, step: editingStep)
            }
        }
        .fullScreenCover(isPresented: $showingBrewTimer) {
            BrewTimerView(recipe: recipe)
        }
    }

    private func deleteSteps(at offsets: IndexSet) {
        let sorted = recipe.sortedSteps
        for index in offsets {
            let step = sorted[index]
            recipe.steps.removeAll { $0.id == step.id }
            modelContext.delete(step)
        }
        reindexSteps()
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        var sorted = recipe.sortedSteps
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, step) in sorted.enumerated() {
            step.sortIndex = index
        }
    }

    private func reindexSteps() {
        for (index, step) in recipe.sortedSteps.enumerated() {
            step.sortIndex = index
        }
    }
}

struct StepRowView: View {
    let step: BrewStep

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(step.actionType.color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: step.actionType.systemImage)
                    .font(.body)
                    .foregroundStyle(step.actionType.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(step.actionType.label)
                        .font(.body.weight(.medium))
                    if let water = step.waterML {
                        Text("(\(water, specifier: "%.0f")ml)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(step.formattedDuration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: step.switchPosition.systemImage)
                    .font(.caption)
                Text(step.switchPosition.label)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(step.switchPosition == .open ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
            .foregroundStyle(step.switchPosition == .open ? .green : .red)
            .clipShape(Capsule())
        }
    }
}

#Preview("Existing Recipe") {
    NavigationStack {
        RecipeDetailView(recipe: previewRecipe)
    }
    .modelContainer(previewContainer)
}

#Preview("New Recipe") {
    NavigationStack {
        RecipeDetailView(recipe: nil)
    }
    .modelContainer(previewContainer)
}
