import SwiftUI

struct OnboardingView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image(.pic2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text("خُلاصة")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColors.primary)

                    Text("Kholasah")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColors.primary)
                }

                Text("Organize your courses, focus sessions, and study plan in one place.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                PrimaryButton(title: "Get Started") {
                    viewModel.finish()
                }
                .padding()
            }
        }
    }
}
#Preview{
    OnboardingView(viewModel: OnboardingViewModel())
}
