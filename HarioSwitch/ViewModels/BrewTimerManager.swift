import Foundation

@Observable
final class BrewTimerManager {
    struct StepSnapshot {
        let sortIndex: Int
        let durationSeconds: Int
        let actionType: ActionType
        let switchPosition: SwitchPosition
        let waterML: Double?
        let cumulativeWaterML: Double?

        var formattedDuration: String {
            let minutes = durationSeconds / 60
            let seconds = durationSeconds % 60
            if minutes > 0 {
                return String(format: "%d:%02d", minutes, seconds)
            }
            return "\(seconds)s"
        }
    }

    let steps: [StepSnapshot]
    let totalDuration: Int

    private(set) var currentStepIndex: Int = 0
    private(set) var elapsedInStep: Int = 0
    private(set) var totalElapsed: Int = 0
    private(set) var isRunning: Bool = false
    private(set) var isFinished: Bool = false

    private var timer: Timer?

    var currentStep: StepSnapshot? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var remainingInStep: Int {
        guard let step = currentStep else { return 0 }
        return max(0, step.durationSeconds - elapsedInStep)
    }

    var stepProgress: Double {
        guard let step = currentStep, step.durationSeconds > 0 else { return 0 }
        return Double(elapsedInStep) / Double(step.durationSeconds)
    }

    var overallProgress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(totalElapsed) / Double(totalDuration)
    }

    var upcomingSteps: [StepSnapshot] {
        guard currentStepIndex + 1 < steps.count else { return [] }
        return Array(steps[(currentStepIndex + 1)...])
    }

    init(steps: [BrewStep]) {
        let sorted = steps.sorted { $0.sortIndex < $1.sortIndex }
        var runningTotal: Double = 0
        self.steps = sorted.map { step in
            if let water = step.waterML {
                runningTotal += water
            }
            return StepSnapshot(
                sortIndex: step.sortIndex,
                durationSeconds: step.durationSeconds,
                actionType: step.actionType,
                switchPosition: step.switchPosition,
                waterML: step.waterML,
                cumulativeWaterML: step.waterML != nil ? runningTotal : nil
            )
        }
        self.totalDuration = self.steps.reduce(0) { $0 + $1.durationSeconds }
    }

    func start() {
        guard !isFinished, !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func togglePlayPause() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func skipToNextStep() {
        guard !isFinished else { return }
        let remaining = remainingInStep
        totalElapsed += remaining
        elapsedInStep = 0
        currentStepIndex += 1

        if currentStepIndex >= steps.count {
            finish()
        }
    }

    func reset() {
        pause()
        currentStepIndex = 0
        elapsedInStep = 0
        totalElapsed = 0
        isFinished = false
    }

    private func tick() {
        guard !isFinished, currentStepIndex < steps.count else { return }

        elapsedInStep += 1
        totalElapsed += 1

        if elapsedInStep >= steps[currentStepIndex].durationSeconds {
            elapsedInStep = 0
            currentStepIndex += 1

            if currentStepIndex >= steps.count {
                finish()
            }
        }
    }

    private func finish() {
        isFinished = true
        pause()
    }

    deinit {
        timer?.invalidate()
    }
}
