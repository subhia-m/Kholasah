import Foundation
import Observation

enum PomodoroTimerState: Equatable {
    case idle
    case running
    case paused
    case completed
}

@MainActor
@Observable
final class FocusViewModel {
    let audioPlayer = FocusAudioPlayer()
    let totalSeconds: Int

    private(set) var remainingSeconds: Int
    private(set) var timerState = PomodoroTimerState.idle

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    @ObservationIgnored
    private let timerService: any TimerService

    @ObservationIgnored
    private var timerTask: Task<Void, Never>?

    init(
        timerService: any TimerService,
        totalSeconds: Int = 25 * 60
    ) {
        self.timerService = timerService
        self.totalSeconds = totalSeconds
        remainingSeconds = totalSeconds
    }

    deinit {
        timerTask?.cancel()
    }

    func toggleTimer() {
        switch timerState {
        case .idle, .completed:
            start()
        case .running:
            pause()
        case .paused:
            resume()
        }
    }

    func reset() {
        cancelTimer()
        remainingSeconds = totalSeconds
        timerState = .idle
    }

    func start() {
        cancelTimer()
        remainingSeconds = totalSeconds
        runCountdown()
    }

    func pause() {
        guard timerState == .running else { return }
        cancelTimer()
        timerState = .paused
    }

    func resume() {
        guard timerState == .paused, remainingSeconds > 0 else { return }
        runCountdown()
    }

    private func runCountdown() {
        guard remainingSeconds > 0 else {
            timerState = .completed
            return
        }

        timerState = .running
        timerTask = Task { [weak self, timerService] in
            guard let self else { return }

            for await seconds in timerService.countdown(from: remainingSeconds) {
                guard !Task.isCancelled else { break }
                self.remainingSeconds = seconds

                if seconds == 0 {
                    self.timerState = .completed
                    self.timerTask = nil
                    break
                }
            }
        }
    }

    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
