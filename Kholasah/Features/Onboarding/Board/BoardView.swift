// MARK: - شرح الملف
// لوحة المهام اليومية والتقويم؛ تدير النوافذ والبطاقات التحفيزية وتوقيت ظهورها.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct BoardView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: BoardViewModel
    // إعداد توقيت ظهور الرسالة.
    var timing = BoardMessageTiming()
    // خيار عرض البطاقات لأغراض المعاينة.
    var previewCards = false
    // حالة المشهد: نشط أو غير نشط أو في الخلفية.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.scenePhase) private var scenePhase
    // تفضيل المستخدم لتقليل الحركة.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // يتحكم في ظهور بطاقة الاستمرارية.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var showingStreak = false
    // يتحكم في ظهور بطاقة التحفيز.
    @State private var showingMessage = false
    // يتحكم في ظهور نافذة إضافة مهمة.
    @State private var showingAdd = false
    // المهمة المحددة لعرض تفاصيلها.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    @State private var selectedTask: StudyTask?
    // هل اللوحة ظاهرة حاليًا؟
    @State private var isVisible = false

    // يسمح بتوقيت الرسالة فقط عندما تكون اللوحة ظاهرة والمشهد نشطًا وخارج وضع معاينة البطاقات.
    private var running: Bool { isVisible && scenePhase == .active && !previewCards }
    // الحركة المستخدمة، أو nil إذا طلب المستخدم تقليل الحركة.
    private var animation: Animation? { reduceMotion ? nil : .easeInOut(duration: 0.25) }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
        ScrollView {
            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 16) {
                // يرتب العناصر أفقيًا.
                HStack {
                    // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                    Button {
                        withAnimation(animation) { showingStreak = true }
                    } label: {
                        Label("\(viewModel.streak.count) Day Streak", systemImage: "flame")
                            .font(AppTypography.subheadline)
                            // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .foregroundStyle(.white)
                            .background(AppColors.primary, in: Capsule())
                    }
                    Spacer()
                    BoardDateDecoration()
                        // يضبط مساحة تخطيط العنصر ومحاذاته.
                        .frame(width: 78, height: 78)
                        .accessibilityHidden(true)
                }
                ZStack {
                    Text("Today’s Tasks")
                        .font(AppTypography.screenTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Spacer()
                        Button { showingAdd = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add task")
                    }
                }
                VStack(spacing: 14) {
                    BoardTaskList(tasks: viewModel.tasks, toggle: viewModel.toggle) { selectedTask = $0 }
                    BoardCalendarView(viewModel: viewModel)
                    BoardQuotesView()
                        .padding(.top, 10)
                }
                .overlay(alignment: .top) {
                    VStack(spacing: 10) {
                        if showingMessage {
                            BoardMotivationCard {
                                withAnimation(animation) { showingMessage = false }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        if showingStreak {
                            BoardStreakCard(streak: viewModel.streak, calendar: viewModel.calendar) {
                                withAnimation(animation) { showingStreak = false }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 48)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        // Keep the scrolling viewport above the shared floating tab bar.
        .padding(.bottom, 64)
        .font(AppTypography.body)
        .foregroundStyle(PlanTheme.text)
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        // يعرض نافذة فوق الشاشة اعتمادًا على حالة العرض أو العنصر المحدد.
        .sheet(isPresented: $showingAdd) {
            BoardAddTaskView(date: viewModel.selectedDate, onSave: viewModel.add)
        }
        .sheet(item: $selectedTask) { task in
            BoardTaskDetailView(viewModel: viewModel, taskID: task.id)
        }
        // ينفذ الإجراء عند ظهور الواجهة.
        .onAppear {
            viewModel.prepareForDisplay()
            isVisible = true
            if previewCards { showingStreak = true; showingMessage = true }
        }
        // ينفذ الإجراء عند اختفاء الواجهة.
        .onDisappear {
            isVisible = false
            showingMessage = false
        }
        // ينفذ الإجراء عند تغير القيمة المراقبة.
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { showingMessage = false }
        }
        // يبدأ عملًا غير متزامن مرتبطًا بعمر العرض؛ تغيير id يعيد تشغيله عند استخدامه.
        // تغيير مفتاح المهمة يلغي الانتظار السابق؛ إغلاق الرسالة يبدأ انتظارًا جديدًا قبل إظهارها مرة أخرى.
        .task(id: running && !showingMessage) {
            // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
            guard running, !showingMessage else { return }
            // يجمع عمليات قد ترمي أخطاء؛ يعالج catch الخطأ بدل إيقاف مسار التطبيق دون معالجة.
            do {
                // One delay while hidden. Closing X starts a fresh delay; while visible
                // there is no timer and no automatic dismissal or duplicate message.
                try await Task.sleep(for: timing.interval)
                try Task.checkCancellation()
                guard running else { return }
                withAnimation(animation) { showingMessage = true }
            } catch {
                // SwiftUI cancels this single task when Board leaves or becomes inactive.
            }
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview("Board — Basic") {
    BoardPreview(cards: false)
}

#Preview("Board — Notifications") {
    BoardPreview(cards: true)
}

private struct BoardPreview: View {
    // خيار إظهار بطاقات اللوحة في المعاينة.
    let cards: Bool
    // الحاوية المشتركة للخدمات ونماذج العرض.
    @State private var dependencies = AppDependencies(
        storageService: UserDefaultsStorageService(),
        courseRepository: InMemoryCourseRepository(),
        taskRepository: InMemoryTaskRepository(tasks: BoardViewModel.preview().repository.tasks),
        studyPlanRepository: InMemoryStudyPlanRepository(),
        timerService: SystemTimerService()
    )

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        MainTabView(dependencies: dependencies, boardPreviewCards: cards)
    }
}
