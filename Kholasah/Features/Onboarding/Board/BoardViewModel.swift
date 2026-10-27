// MARK: - شرح الملف
// يربط اللوحة بمستودع المهام ويحسب أيام التقويم. يضيف حاليًا مهامًا تجريبية للشهور؛ قيمة الاستمرارية الافتراضية تجريبية وليست محسوبة من الإنجاز.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

/// Replace this fixture with the agreed streak calculation when it is available.
/// Calendar selection and task completion deliberately never update this value.
struct BoardStreak: Equatable {
    // عدد الأيام المسجل في الاستمرارية.
    var count: Int
    // آخر يوم مسجل للاستمرارية.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var lastRecordedDay: Date?
    nonisolated static var demo: BoardStreak { BoardStreak(count: 7, lastRecordedDay: .now) }

    // يحسب أيام الأسبوع المرتبطة بتاريخ الاستمرارية باستخدام التقويم.
    func week(calendar: Calendar, fallback: Date = .now) -> [Date] {
        let anchor = lastRecordedDay ?? fallback
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard let start = calendar.dateInterval(of: .weekOfYear, for: anchor)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
}

struct BoardMessageTiming {
    // Wait after opening Board or dismissing the previous encouragement.
    // المدة المنتظرة قبل إظهار بطاقة التحفيز.
    var interval: Duration = .seconds(30)
}

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
@Observable
final class BoardViewModel {
    let repository: any TaskRepository
    var selectedDate: Date
    // الشهر الذي يعرضه التقويم.
    var displayedMonth: Date {
        didSet {
            if demoDataEnabled { seedDisplayedMonth() }
        }
    }
    // بيانات الاستمرارية المعروضة.
    var streak: BoardStreak
    // التقويم المستخدم لحساب الأيام والشهور.
    let calendar: Calendar

    init(repository: any TaskRepository, today: Date = .now, streak: BoardStreak = .demo) {
        self.repository = repository
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 1
        self.calendar = calendar
        selectedDate = calendar.startOfDay(for: today)
        displayedMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        self.streak = streak
    }

    // المهام التي يستخدمها هذا الجزء من التطبيق.
    var tasks: [StudyTask] {
        repository.tasks.filter { task in
            guard let date = task.dueDate else { return false }
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
    }

    // تواريخ أيام الشهر المعروض.
    var monthDays: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: displayedMonth) }
    }

    // عدد الخانات الفارغة قبل أول يوم في شبكة الشهر.
    var leadingEmptyDays: Int {
        (calendar.component(.weekday, from: displayedMonth) - calendar.firstWeekday + 7) % 7
    }

    // ينقل الشهر المعروض بمقدار الإزاحة المطلوبة.
    func moveMonth(_ offset: Int) {
        // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
        if let next = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = next
        }
    }

    // يضيف مهمة بعنوان وموعد ومدة إلى المستودع المشترك.
    func add(title: String, date: Date, minutes: Int) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, minutes > 0 else { return }
        repository.add(StudyTask(title: title, dueDate: calendar.startOfDay(for: date), durationMinutes: minutes))
        selectedDate = calendar.startOfDay(for: date)
        displayedMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    // يبدل حالة إنجاز المهمة داخل المستودع المشترك.
    func toggle(_ task: StudyTask) {
        guard var current = repository.tasks.first(where: { $0.id == task.id }) else { return }
        current.isCompleted.toggle()
        repository.update(current)
    }

    // يمنع تكرار تهيئة اللوحة خلال عمر نموذج العرض.
    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored private var hasOpened = false

    // يهيئ اللوحة عند أول ظهور ويجهز البيانات التجريبية للشهر.
    func prepareForDisplay(today: Date = .now) {
        guard !hasOpened else { return }
        hasOpened = true
        selectedDate = calendar.startOfDay(for: today)
        displayedMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        // Previews use the same data generation without touching the app's saved markers.
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        seedDemoTasksIfNeeded(today: today, defaults: isPreview ? nil : .standard)
    }

    // هل أُتيح توليد بيانات اللوحة التجريبية؟
    @ObservationIgnored private var demoDataEnabled = false
    // تخزين علامات إنشاء البيانات التجريبية، ويمكن تعطيله للمعاينات.
    @ObservationIgnored private var demoDefaults: UserDefaults?
    // التاريخ المرجعي لتوزيع المهام التجريبية.
    @ObservationIgnored private var demoAnchor = Date.now
    // الشهور التي أُنشئت بياناتها التجريبية في هذه النسخة.
    @ObservationIgnored private var preparedMonths: Set<String> = []

    // يضبط التاريخ المرجعي للبيانات التجريبية ثم يجهز الشهر المعروض.
    func seedDemoTasksIfNeeded(today: Date = .now, defaults: UserDefaults? = .standard) {
        demoDefaults = defaults
        let anchorKey = "board.monthlyDemo.anchor.v2"
        if let saved = defaults?.object(forKey: anchorKey) as? Date {
            demoAnchor = saved
        } else {
            demoAnchor = calendar.startOfDay(for: today)
            defaults?.set(demoAnchor, forKey: anchorKey)
        }
        demoDataEnabled = true
        seedDisplayedMonth()
    }

    // ينشئ مهام الشهر التجريبية مرة واحدة مع التحقق من المعرّفات لمنع التكرار.
    private func seedDisplayedMonth() {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let year = components.year, let month = components.month else { return }
        let monthKey = String(format: "board.monthlyDemo.v2.%04d-%02d", year, month)
        // نفحص ذاكرة الجلسة وعلامة التخزين لتجنب إعادة توليد مهام الشهر.
        guard !preparedMonths.contains(monthKey), demoDefaults?.bool(forKey: monthKey) != true else { return }

        for date in monthDays {
            let day = calendar.component(.day, from: date)
            for (slot, sample) in demoTasks(for: date).enumerated() {
                // Full-date IDs recover safely from interrupted seeding without duplicates.
                guard let id = UUID(uuidString: String(
                    format: "B04D0002-0000-4000-8000-%04d%02d%02d%04d", year, month, day, slot
                )) else { continue }
                let alreadyExists = repository.tasks.contains { task in
                    task.id == id || (
                        task.dueDate.map { calendar.isDate($0, inSameDayAs: date) } == true &&
                        task.title == sample.title
                    )
                }
                guard !alreadyExists else { continue }
                repository.add(StudyTask(id: id, title: sample.title, dueDate: date,
                                         durationMinutes: sample.minutes))
            }
        }
        // Mark only after all tasks are saved; never rewrite completion or user-created tasks.
        // تُسجل علامة اكتمال التهيئة بعد إضافة المهام كلها حتى يمكن التعافي من توقف سابق.
        preparedMonths.insert(monthKey)
        demoDefaults?.set(true, forKey: monthKey)
    }

    // يحدد عناوين ومدد مهام تجريبية بحسب التاريخ؛ هذه البيانات ليست ناتجة عن الذكاء الاصطناعي.
    private func demoTasks(for date: Date) -> [(title: String, minutes: Int)] {
        let offset = calendar.dateComponents([.day], from: demoAnchor, to: date).day ?? 0
        switch offset {
        case 0:
            return [("Review notes", 25), ("Practice quiz", 15)]
        case 1:
            return [("Read chapter 3", 20), ("Watch a lesson", 30)]
        case 2:
            return [("Solve exercises", 40), ("Summarize chapter", 15)]
        default:
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            let variation = year * 372 + month * 31 + day
            let topics = [
                "Review vocabulary", "Practice problem solving", "Prepare flashcards",
                "Watch a lesson", "Write a summary", "Read study notes",
                "Complete a practice quiz", "Revise key concepts"
            ]
            return (0..<(1 + variation % 4)).map { slot in
                let topic = topics[(variation + slot * 3) % topics.count]
                let unit = day + slot + (month - 1) * 31
                return ("\(topic) — Unit \(unit)", 10 + ((variation + slot * 2) % 8) * 5)
            }
        }
    }

    // ينشئ نموذج عرض ببيانات تجريبية معزولة عن علامات التخزين المستخدمة في التطبيق.
    static func preview() -> BoardViewModel {
        let model = BoardViewModel(repository: InMemoryTaskRepository())
        model.seedDemoTasksIfNeeded(defaults: nil)
        return model
    }
}
