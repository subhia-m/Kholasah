import SwiftUI

struct CourseCard: View {
    let title: String
    let instructor: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primary)

            if !instructor.isEmpty {
                Label(instructor, systemImage: "person")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
