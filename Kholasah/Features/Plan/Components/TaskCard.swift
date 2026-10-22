import SwiftUI

struct TaskCard: View {
    let title: String
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? AppColors.primary : AppColors.secondaryText)
                Text(title)
                    .strikethrough(isCompleted)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isCompleted ? "Completed" : "Not completed")
    }
}
