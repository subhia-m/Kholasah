import SwiftUI

struct PomodoroView: View {
    let viewModel: FocusViewModel

    private var formattedTime: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 28) {
            Text(formattedTime)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppColors.primary)
                .accessibilityLabel("Time remaining")
                .accessibilityValue(formattedTime)

            HStack {
                Button(viewModel.isRunning ? "Pause" : "Start") {
                    viewModel.toggleTimer()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)

                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 20))
    }
}
