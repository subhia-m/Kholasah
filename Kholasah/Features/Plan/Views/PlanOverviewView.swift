// MARK:
import SwiftUI

// MARK: - Overview page

struct PlanOverviewView: View {
    var courseTitle: String = "Swift Basics"
    @Binding var selection: PlanScreenTab
    var onBack: (() -> Void)? = nil
    var tasks: [StudyTask] = []
    var reminders: [PlanReminderItem] = []
    var daysDone: Int = 0                    // NEW
    var daysTotal: Int = 0                   // NEW

    var body: some View {
        PlanPageScaffold(title: courseTitle, selection: $selection, onBack: onBack) {
            PlanOverviewContent(tasks: tasks,
                                reminders: reminders,
                                daysDone: daysDone,          // NEW
                                daysTotal: daysTotal)        // NEW
        }
    }
}

// MARK: - Overview tab content

private struct PlanOverviewContent: View {
    var tasks: [StudyTask] = []
    var reminders: [PlanReminderItem] = []
    // Passed in by CourseFlowView, worked out from the due dates of the course's tasks.
    var daysDone: Int = 0
    var daysTotal: Int = 0

    // MARK: Derived data

    private var tasksDone: Int { tasks.filter(\.isCompleted).count }

    private var taskProgress: Double {
        tasks.isEmpty ? 0 : Double(tasksDone) / Double(tasks.count)
    }

    private var dayProgress: Double {
        daysTotal == 0 ? 0 : Double(daysDone) / Double(daysTotal)
    }

    private var nextReminder: PlanReminderItem? {
        reminders
            .filter { $0.isOn && $0.date >= Date() }
            .min { $0.date < $1.date }
    }

    private var newestOpenTask: StudyTask? {
        tasks.last { !$0.isCompleted }
    }

    // MARK: Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                // Upcoming reminder
                header(systemImage: "bell", title: "Upcoming Reminder:")
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                    //PlanPalmLeaf().padding(6)

                    if let reminder = nextReminder {
                        VStack(spacing: 4) {
                            Text(reminder.title)
                                .font(AppTypography.headline)
                            Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                                .font(AppTypography.caption)
                                .opacity(0.7)
                        }
                        .foregroundStyle(PlanTheme.text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        emptyLabel("No upcoming reminders", color: PlanTheme.text)
                    }
                }
                .frame(height: 120)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                // New task
                header(systemImage: "list.clipboard", title: "New Task:")
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PlanTheme.mauve)
                    if let task = newestOpenTask {
                        Text(task.title)
                            .font(AppTypography.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                    } else {
                        emptyLabel("No tasks yet", color: .white)
                    }
                }
                .frame(height: 120)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                // Course progress
                header(systemImage: "chart.bar", title: "Course Progress :")
                HStack {
                    Spacer()

                    VStack(spacing: 10) {
                        ZStack {
                            ring(progress: taskProgress)
                            VStack(spacing: 0) {
                                Text("\(tasksDone)")
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 14, height: 1)
                                Text("\(tasks.count)")
                            }
                            .font(AppTypography.caption)
                            .foregroundStyle(.white)
                        }
                        Text("\(tasksDone) / \(tasks.count) Tasks")
                            .font(AppTypography.caption)
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    VStack(spacing: 10) {
                        ZStack {
                            ring(progress: dayProgress)
                            Image(systemName: "stopwatch")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                        Text("\(daysDone) / \(daysTotal) Days")
                            .font(AppTypography.caption)
                            .foregroundStyle(.white)
                    }

                    Spacer()
                }
                .padding(.vertical, 90)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PlanTheme.progressBrown)
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Course progress")
                .accessibilityValue("\(tasksDone) of \(tasks.count) tasks, \(daysDone) of \(daysTotal) days")
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 16)
        }
    }

    // MARK: Helpers

    private func header(systemImage: String, title: String) -> some View {
        Label {
            Text(title).font(AppTypography.captionEmphasized)
        } icon: {
            Image(systemName: systemImage).font(.system(size: 14))
        }
        .foregroundStyle(PlanTheme.text)
    }

    private func emptyLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppTypography.subheadline)
            .foregroundStyle(color.opacity(0.6))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func ring(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    NavigationStack {
        CourseFlowView(course: Course(title: "Swift Basics"), showsBackButton: true, startingAt: .overview)
    }
}
