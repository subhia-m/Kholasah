import SwiftUI

struct PomodoroView: View {
    let viewModel: FocusViewModel
    @State private var note = ""

    private var formattedTime: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 34) {
            PomodoroTimerDial(formattedTime: formattedTime)

            PomodoroTimerControls(
                isRunning: viewModel.isRunning,
                onToggle: viewModel.toggleTimer,
                onReset: viewModel.reset
            )

            PomodoroNoteEditor(note: $note)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct PomodoroTimerDial: View {
    let formattedTime: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(0.72), lineWidth: 1)
                .frame(width: 292, height: 292)

            Circle()
                .stroke(.primary.opacity(0.72), lineWidth: 1)
                .frame(width: 236, height: 236)

            Text(formattedTime)
                .font(.system(size: 62, weight: .regular, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppColors.burgundy)
                .minimumScaleFactor(0.7)
                .accessibilityLabel("Time remaining")
                .accessibilityValue(formattedTime)
        }
        .frame(height: 310)
    }
}

private struct PomodoroTimerControls: View {
    let isRunning: Bool
    let onToggle: () -> Void
    let onReset: () -> Void

    var body: some View {
        Button(isRunning ? "Pause Timer" : "Start Timer", action: onToggle)
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(width: 210)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.white, AppColors.lightPage.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(.white, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
            .contextMenu {
                Button("Reset Timer", systemImage: "arrow.counterclockwise", action: onReset)
            }
    }
}

private struct PomodoroNoteEditor: View {
    @Binding var note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Write a Note")
                .font(.caption)
                .foregroundStyle(AppColors.burgundy)

            HStack(spacing: 10) {
                TextField("Write a note…", text: $note)
                    .textFieldStyle(.plain)

                Image(systemName: "pencil")
                    .foregroundStyle(AppColors.burgundy)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.neutralGray, lineWidth: 1)
            }
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    PomodoroView(viewModel: AppDependencies().focusViewModel)
        .padding(.horizontal, 12)
        .background(AppColors.lightPage)
}
