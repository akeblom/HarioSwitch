import SwiftUI

struct BrewTimerView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @State private var manager: BrewTimerManager

    init(recipe: Recipe) {
        self.recipe = recipe
        _manager = State(initialValue: BrewTimerManager(steps: recipe.sortedSteps))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    stepInfoSection
                    timerCircle
                    overallProgressSection
                    controlButtons
                    upcomingStepsList
                    Spacer(minLength: 0)
                }
                .padding()

                if manager.isFinished {
                    brewCompleteOverlay
                }
            }
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            manager.start()
        }
    }

    // MARK: - Step Info

    private var stepInfoSection: some View {
        Group {
            if let step = manager.currentStep {
                VStack(spacing: 10) {
                    Text("Step \(manager.currentStepIndex + 1) of \(manager.steps.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Label(step.actionType.label, systemImage: step.actionType.systemImage)
                            .font(.title2.bold())
                            .foregroundStyle(step.actionType.color)

                        if let target = step.cumulativeWaterML {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                Text("\(target, specifier: "%.0f") ml")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.cyan.opacity(0.12))
                            .foregroundStyle(.cyan)
                            .clipShape(Capsule())
                        }

                        HStack(spacing: 4) {
                            Image(systemName: step.switchPosition.systemImage)
                            Text(step.switchPosition.label)
                        }
                        .font(.subheadline.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(step.switchPosition == .open ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                        .foregroundStyle(step.switchPosition == .open ? .green : .red)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Timer Circle

    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)

            Circle()
                .trim(from: 0, to: 1 - manager.stepProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            (manager.currentStep?.actionType.color ?? .blue).opacity(0.6),
                            (manager.currentStep?.actionType.color ?? .blue)
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: manager.stepProgress)

            VStack(spacing: 6) {
                Text(formatTime(manager.remainingInStep))
                    .font(.system(size: 52, weight: .thin, design: .rounded))
                    .contentTransition(.numericText())
                    .monospacedDigit()

                Text("remaining")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
        }
        .frame(width: 230, height: 230)
    }

    // MARK: - Overall Progress

    private var overallProgressSection: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    Capsule()
                        .fill(Color.primary.opacity(0.6))
                        .frame(width: max(0, geo.size.width * manager.overallProgress))
                        .animation(.linear(duration: 1), value: manager.overallProgress)
                }
            }
            .frame(height: 6)

            HStack {
                Text(formatTime(manager.totalElapsed))
                Spacer()
                Text(formatTime(manager.totalDuration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 32) {
            Button {
                manager.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .tint(.primary)

            Button {
                manager.togglePlayPause()
            } label: {
                Image(systemName: manager.isRunning ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .frame(width: 68, height: 68)
                    .background(
                        Circle()
                            .fill(Color.accentColor.gradient)
                    )
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(color: .accentColor.opacity(0.3), radius: 8, y: 4)
            }

            Button {
                manager.skipToNextStep()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title3)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .tint(.primary)
            .disabled(manager.isFinished)
        }
    }

    // MARK: - Upcoming Steps

    private var upcomingStepsList: some View {
        Group {
            if !manager.upcomingSteps.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Up Next")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)

                    ForEach(Array(manager.upcomingSteps.enumerated()), id: \.offset) { _, step in
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(step.actionType.color.opacity(0.1))
                                    .frame(width: 28, height: 28)
                                Image(systemName: step.actionType.systemImage)
                                    .font(.caption)
                                    .foregroundStyle(step.actionType.color)
                            }

                            Text(step.actionType.label)
                                .font(.subheadline)

                            HStack(spacing: 2) {
                                Image(systemName: step.switchPosition.systemImage)
                                Text(step.switchPosition.label)
                            }
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(step.switchPosition == .open ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .foregroundStyle(step.switchPosition == .open ? .green : .red)
                            .clipShape(Capsule())

                            Spacer()

                            if let target = step.cumulativeWaterML {
                                Text("\(target, specifier: "%.0f")ml")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                            }

                            Text(step.formattedDuration)
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    // MARK: - Brew Complete Overlay

    private var brewCompleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.green)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(spacing: 6) {
                    Text("Brew Complete")
                        .font(.title2.bold())

                    Text("Total time: \(formatTime(manager.totalElapsed))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(28)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            .padding(36)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    BrewTimerView(recipe: previewRecipe)
        .modelContainer(previewContainer)
}
