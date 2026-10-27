// MARK: - شرح الملف
// يدير حالات مؤقت التركيز والوقت المتبقي والتقدم، ويملك مشغل الصوت المستخدم في قسم التركيز.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum PomodoroTimerState: Equatable {
    case idle
    case running
    case paused
    case completed
}

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class FocusViewModel {
    // مشغل الصوت المشترك الذي تنعكس حالته على الواجهة.
    let audioPlayer = FocusAudioPlayer()
    // المدة الكاملة لجلسة التركيز بالثواني.
    let totalSeconds: Int

    // الثواني المتبقية في المؤقت.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    private(set) var remainingSeconds: Int
    // الحالة الحالية للمؤقت.
    private(set) var timerState = PomodoroTimerState.idle

    // نسبة التقدم التي تستخدمها الواجهة.
    var progress: Double {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard totalSeconds > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored
    // مصدر قيم العد التنازلي غير المتزامن.
    private let timerService: any TimerService

    @ObservationIgnored
    // مرجع مهمة العد التنازلي لإمكانية إلغائها.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    private var timerTask: Task<Void, Never>?

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(
        timerService: any TimerService,
        totalSeconds: Int = 25 * 60
    ) {
        self.timerService = timerService
        self.totalSeconds = totalSeconds
        remainingSeconds = totalSeconds
    }

    // تنظيف الموارد عند تحرير نسخة الكائن.
    deinit {
        timerTask?.cancel()
    }

    // يختار البدء أو الإيقاف المؤقت أو الاستئناف بحسب حالة المؤقت.
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

    // يلغي العد الحالي ويعيد المؤقت إلى مدته الأصلية وحالة الانتظار.
    func reset() {
        cancelTimer()
        remainingSeconds = totalSeconds
        timerState = .idle
    }

    // يبدأ جلسة عد جديدة من المدة الكاملة.
    func start() {
        cancelTimer()
        remainingSeconds = totalSeconds
        runCountdown()
    }

    // يلغي مهمة العد الحالية ويحفظ الثواني المتبقية ليتيح الاستئناف.
    func pause() {
        guard timerState == .running else { return }
        cancelTimer()
        timerState = .paused
    }

    // يستأنف المؤقت من الوقت المتبقي إذا كان متوقفًا مؤقتًا.
    func resume() {
        guard timerState == .paused, remainingSeconds > 0 else { return }
        runCountdown()
    }

    // يستقبل الثواني من التدفق ويحدث الواجهة حتى الاكتمال أو الإلغاء.
    private func runCountdown() {
        guard remainingSeconds > 0 else {
            timerState = .completed
            return
        }

        timerState = .running
        // مرجع weak لا يحتفظ بالكائن بقوة عند إنشاء المهمة؛ guard let يفك المرجع أثناء التنفيذ.
        timerTask = Task { [weak self, timerService] in
            guard let self else { return }

            // ينتظر قيم التدفق واحدة تلو الأخرى دون حجز خيط التنفيذ أثناء الانتظار.
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

    // يلغي مهمة العد ويزيل مرجعها لمنع استمرار جلسة قديمة.
    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
