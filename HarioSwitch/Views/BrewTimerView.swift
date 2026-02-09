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
                VStack(spacing: 8) {
                    Text("Step \(manager.currentStepIndex + 1) of \(manager.steps.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Label(step.actionType.label, systemImage: step.actionType.systemImage)
                            .font(.title2.bold())
                            .foregroundStyle(step.actionType == .pour ? .blue : .orange)
                        
                        if let water = step.waterML {
                          Label("\(water, specifier: "%.0f") ml", systemImage: "drop.fill")
                            .font(.title3)
                            .foregroundStyle(.cyan)
                        }
                      
                        HStack(spacing: 4) {
                            Image(systemName: step.switchPosition.systemImage)
                            Text(step.switchPosition.label)
                        }
                        .font(.subheadline.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(step.switchPosition == .open ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
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
                .stroke(Color(.systemGray4), lineWidth: 12)

            Circle()
                .trim(from: 0, to: 1 - manager.stepProgress)
                .stroke(
                    manager.currentStep?.actionType == .pour ? Color.blue : Color.orange,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: manager.stepProgress)

            VStack(spacing: 4) {
                Text(formatTime(manager.remainingInStep))
                    .font(.system(size: 56, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())

                Text("remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 220, height: 220)
    }

    // MARK: - Overall Progress

    private var overallProgressSection: some View {
        VStack(spacing: 4) {
            ProgressView(value: manager.overallProgress)
                .tint(.primary)

            HStack {
                Text(formatTime(manager.totalElapsed))
                Spacer()
                Text(formatTime(manager.totalDuration))
            }
            .font(.caption)
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
                    .font(.title2)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .tint(.primary)

            Button {
                manager.togglePlayPause()
            } label: {
                Image(systemName: manager.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 64, height: 64)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }

            Button {
                manager.skipToNextStep()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Up Next")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)

                    ForEach(Array(manager.upcomingSteps.enumerated()), id: \.offset) { _, step in
                        HStack(spacing: 10) {
                            Image(systemName: step.actionType.systemImage)
                                .foregroundStyle(step.actionType == .pour ? .blue : .orange)
                                .frame(width: 22)

                            Text(step.actionType.label)
                                .font(.subheadline)

                            HStack(spacing: 2) {
                                Image(systemName: step.switchPosition.systemImage)
                                Text(step.switchPosition.label)
                            }
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(step.switchPosition == .open ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .foregroundStyle(step.switchPosition == .open ? .green : .red)
                            .clipShape(Capsule())

                            Spacer()

                            if let water = step.waterML {
                                Text("\(water, specifier: "%.0f")ml")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                            }

                            Text(step.formattedDuration)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Brew Complete Overlay

    private var brewCompleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)

                Text("Brew Complete!")
                    .font(.title.bold())

                Text("Total time: \(formatTime(manager.totalElapsed))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(40)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
