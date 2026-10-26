import Foundation

protocol TimerService: Sendable {
    func countdown(from seconds: Int) -> AsyncStream<Int>
}

struct SystemTimerService: TimerService {
    func countdown(from seconds: Int) -> AsyncStream<Int> {
        AsyncStream { continuation in
            let task = Task {
                let endDate = Date().addingTimeInterval(TimeInterval(seconds))
                var lastValue = seconds

                continuation.yield(lastValue)

                while !Task.isCancelled && lastValue > 0 {
                    try? await Task.sleep(for: .milliseconds(200))
                    guard !Task.isCancelled else { break }

                    let nextValue = max(
                        0,
                        Int(ceil(endDate.timeIntervalSinceNow))
                    )

                    if nextValue != lastValue {
                        lastValue = nextValue
                        continuation.yield(nextValue)
                    }
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
