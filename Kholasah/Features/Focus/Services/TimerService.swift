// MARK: - شرح الملف
// يوفر العد التنازلي كتدفق غير متزامن من الثواني؛ يعتمد على وقت النهاية بدل إنقاص رقم مع كل انتظار.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// protocol عقد يحدد المتطلبات؛ النوع المطابق له يقدم التنفيذ الفعلي.
protocol TimerService: Sendable {
    // يعيد AsyncStream يرسل الثواني المتبقية؛ إلغاء المستهلك ينهي مهمة إنتاج القيم.
    func countdown(from seconds: Int) -> AsyncStream<Int>
}

struct SystemTimerService: TimerService {
    // يعيد AsyncStream يرسل الثواني المتبقية؛ إلغاء المستهلك ينهي مهمة إنتاج القيم.
    func countdown(from seconds: Int) -> AsyncStream<Int> {
        AsyncStream { continuation in
            let task = Task {
                // حساب الباقي من موعد النهاية يقلل تراكم الانحراف الناتج عن تأخر الاستيقاظ.
                let endDate = Date().addingTimeInterval(TimeInterval(seconds))
                var lastValue = seconds

                continuation.yield(lastValue)

                while !Task.isCancelled && lastValue > 0 {
                    try? await Task.sleep(for: .milliseconds(200))
                    // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
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

            // عند انتهاء استهلاك التدفق نلغي مهمة الإنتاج حتى لا يبقى مؤقت يعمل دون مستهلك.
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
