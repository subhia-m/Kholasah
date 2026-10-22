import Foundation
import Observation

@MainActor
@Observable
final class FocusViewModel {
    private(set) var remainingSeconds = 25 * 60
    private(set) var isRunning = false

    @ObservationIgnored
    private let timerService: any TimerService

    @ObservationIgnored
    private var timerTask: Task<Void, Never>?

    init(timerService: any TimerService) {
        self.timerService = timerService
    }

    deinit {
        timerTask?.cancel()
    }

    func toggleTimer() {
        isRunning ? pause() : start()
    }

    func reset() {
        pause()
        remainingSeconds = 25 * 60
    }

    private func start() {
        guard remainingSeconds > 0 else { return }
        isRunning = true
        timerTask = Task { [weak self, timerService] in
            for await _ in timerService.ticks(every: .seconds(1)) {
                guard let self, self.isRunning else { break }
                self.remainingSeconds -= 1
                if self.remainingSeconds == 0 {
                    self.pause()
                    break
                }
            }
        }
    }

    private func pause() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
}
