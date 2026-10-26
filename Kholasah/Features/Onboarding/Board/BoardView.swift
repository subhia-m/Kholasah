import SwiftUI

struct BoardView: View {
    let viewModel: BoardViewModel
    var timing = BoardMessageTiming()
    var previewCards = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingStreak = false
    @State private var showingMessage = false
    @State private var showingAdd = false
    @State private var selectedTask: StudyTask?
    @State private var isVisible = false

    private var running: Bool { isVisible && scenePhase == .active && !previewCards }
    private var animation: Animation? { reduceMotion ? nil : .easeInOut(duration: 0.25) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Button {
                        withAnimation(animation) { showingStreak.toggle() }
                    } label: {
                        Label("\(viewModel.streak.count) Day Streak", systemImage: "flame")
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .foregroundStyle(.white)
                            .background(AppColors.primary, in: Capsule())
                    }
                    Spacer()
                    BoardDateDecoration()
                        .frame(width: 78, height: 78)
                        .accessibilityHidden(true)
                }
                HStack(alignment: .center) {
                    Text(viewModel.calendar.isDateInToday(viewModel.selectedDate)
                         ? "Today’s Tasks"
                         : viewModel.selectedDate.formatted(.dateTime.month(.abbreviated).day().year().locale(Locale(identifier: "en_US"))))
                        .font(AppTypography.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add task")
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
        .sheet(isPresented: $showingAdd) {
            BoardAddTaskView(date: viewModel.selectedDate, onSave: viewModel.add)
        }
        .sheet(item: $selectedTask) { task in
            BoardTaskDetailView(viewModel: viewModel, taskID: task.id)
        }
        .onAppear {
            viewModel.prepareForDisplay()
            isVisible = true
            if previewCards { showingStreak = true; showingMessage = true }
        }
        .onDisappear {
            isVisible = false
            showingMessage = false
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { showingMessage = false }
        }
        .task(id: running) {
            guard running else { return }
            do {
                let clock = ContinuousClock()
                var nextAppearance = clock.now.advanced(by: timing.interval)
                try await clock.sleep(until: nextAppearance)
                while !Task.isCancelled {
                    withAnimation(animation) { showingMessage = true }
                    try await Task.sleep(for: timing.visible)
                    withAnimation(animation) { showingMessage = false }
                    nextAppearance = nextAppearance.advanced(by: timing.interval)
                    try await clock.sleep(until: nextAppearance)
                }
            } catch {
                // SwiftUI cancels this single task when Board leaves or becomes inactive.
            }
        }
    }
}

#Preview("Board — Basic") {
    BoardPreview(cards: false)
}

#Preview("Board — Notifications") {
    BoardPreview(cards: true)
}

private struct BoardPreview: View {
    let cards: Bool
    @State private var dependencies = AppDependencies(
        storageService: UserDefaultsStorageService(),
        courseRepository: InMemoryCourseRepository(),
        taskRepository: InMemoryTaskRepository(tasks: BoardViewModel.preview().repository.tasks),
        studyPlanRepository: InMemoryStudyPlanRepository(),
        timerService: SystemTimerService()
    )

    var body: some View {
        MainTabView(dependencies: dependencies, boardPreviewCards: cards)
    }
}
