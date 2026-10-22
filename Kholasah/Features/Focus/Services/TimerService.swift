import Foundation

protocol TimerService: Sendable {
    func ticks(every interval: Duration) -> AsyncStream<Void>
}

struct SystemTimerService: TimerService {
    func ticks(every interval: Duration) -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: interval)
                    guard !Task.isCancelled else { break }
                    continuation.yield()
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
