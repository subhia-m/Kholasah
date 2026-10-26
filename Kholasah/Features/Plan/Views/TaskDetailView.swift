import SwiftUI

struct TaskDetailView: View {
    let task: StudyTask

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PlanTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                PlanTopBar(title: "Task Details", onBack: { dismiss() })

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        titleCard
                        details
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                task.isCompleted ? "Completed" : "Upcoming Task",
                systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle"
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(PlanTheme.deepClay)

            Text(task.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(PlanTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private var details: some View {
        if let concept = task.concept, !concept.isEmpty {
            detailCard(title: "Concept", systemImage: "book.pages", text: concept)
        }

        if let explanation = task.explanation, !explanation.isEmpty {
            detailCard(
                title: "Explanation",
                systemImage: "text.book.closed",
                text: explanation
            )
        }

        if !task.keyPoints.isEmpty {
            keyPointsCard
        }

        if let durationMinutes = task.durationMinutes {
            detailCard(
                title: "Study Duration",
                systemImage: "clock",
                text: "\(durationMinutes) minutes"
            )
        }

        if let dueDate = task.dueDate {
            detailCard(
                title: "Study Time",
                systemImage: "calendar",
                text: dueDate.formatted(date: .abbreviated, time: .shortened)
            )
        }

        if let reviewPrompt = task.reviewPrompt, !reviewPrompt.isEmpty {
            detailCard(
                title: "Review Question",
                systemImage: "questionmark.bubble",
                text: reviewPrompt
            )
        }

        if let reminderMessage = task.reminderMessage, !reminderMessage.isEmpty {
            detailCard(
                title: "Encouragement",
                systemImage: "sparkles",
                text: reminderMessage
            )
        }
    }

    private var keyPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Key Points", systemImage: "list.bullet")
                .font(.headline)
                .foregroundStyle(PlanTheme.deepClay)

            ForEach(task.keyPoints, id: \.self) { point in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(PlanTheme.deepClay)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)

                    Text(point)
                        .font(.body)
                        .foregroundStyle(PlanTheme.text)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }

    private func detailCard(title: LocalizedStringKey, systemImage: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(PlanTheme.deepClay)

            Text(text)
                .font(.body)
                .foregroundStyle(PlanTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: StudyTask(
                title: "Review Swift functions",
                dueDate: .now,
                durationMinutes: 30,
                concept: "Functions, parameters, and return values",
                explanation: "Functions group reusable behavior and can receive values through parameters.",
                keyPoints: ["Use parameters for input", "Use return values for output"],
                reviewPrompt: "Explain the difference between a parameter and an argument.",
                reminderMessage: "You are close—one focused session to finish this concept."
            )
        )
    }
}
