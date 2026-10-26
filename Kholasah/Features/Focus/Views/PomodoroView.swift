import SwiftUI

struct PomodoroView: View {
    let viewModel: FocusViewModel
    @State private var note = ""

    var body: some View {
        VStack(spacing: 34) {
            PomodoroDial(
                remainingSeconds: viewModel.remainingSeconds,
                progress: viewModel.progress
            )

            PomodoroTimerControls(
                timerState: viewModel.timerState,
                onToggle: viewModel.toggleTimer,
                onReset: viewModel.reset
            )

            PomodoroNoteEditor(note: $note)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct PomodoroDial: View {
    let remainingSeconds: Int
    let progress: Double

    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.black.opacity(0.12), lineWidth: 5)

            ForEach(0..<60, id: \.self) { index in
                Capsule()
                    .fill(
                        index.isMultiple(of: 5)
                            ? AppColors.date
                            : .black.opacity(0.18)
                    )
                    .frame(
                        width: index.isMultiple(of: 5) ? 3 : 2,
                        height: index.isMultiple(of: 5) ? 13 : 6
                    )
                    .offset(y: -137)
                    .rotationEffect(.degrees(Double(index) * 6))
            }

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.date,
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(AppColors.date)
                .frame(width: 22, height: 22)
                .shadow(color: AppColors.date.opacity(0.4), radius: 7)
                .offset(y: -150)
                .rotationEffect(.degrees(progress * 360))

            VStack(spacing: 20) {
                Text("\(remainingSeconds) SEC")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(formattedTime)
                    .font(.system(size: 58, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.burgundy)
            }
        }
        .frame(width: 310, height: 310)
            .animation(.linear(duration: 0.2), value: progress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time remaining")
            .accessibilityValue(formattedTime)
    }
}

private struct PomodoroTimerControls: View {
    let timerState: PomodoroTimerState
    let onToggle: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(primaryButtonTitle, action: onToggle)
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(width: 170)
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

            Button("Reset Timer", systemImage: "arrow.counterclockwise", action: onReset)
                .labelStyle(.iconOnly)
                .font(.headline)
                .foregroundStyle(AppColors.burgundy)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.7), in: Circle())
                .accessibilityLabel("Reset Timer")
        }
    }

    private var primaryButtonTitle: LocalizedStringKey {
        switch timerState {
        case .idle:
            "Start Timer"
        case .running:
            "Pause Timer"
        case .paused:
            "Resume Timer"
        case .completed:
            "Start Again"
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
