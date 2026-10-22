import SwiftUI

struct ProgressCard: View {
    let completedCount: Int
    let totalCount: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Progress")
                .font(AppTypography.title)

            ProgressView(value: progress)

            Text("\(completedCount) of \(totalCount) tasks completed")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding()
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
