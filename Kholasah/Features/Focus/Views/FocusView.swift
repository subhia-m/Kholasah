import SwiftUI

struct FocusView: View {
    let viewModel: FocusViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode = FocusMode.sound

    var body: some View {
        VStack(spacing: 20) {
            header
            modePicker

            Group {
                switch selectedMode {
                case .sound:
                    MusicView(audioPlayer: viewModel.audioPlayer)
                case .pomodoro:
                    ScrollView {
                        PomodoroView(viewModel: viewModel)
                            .padding(.horizontal, 24)
                            .padding(.top, 22)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, 8)
        .background(AppColors.lightPage.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            Text("Focus")
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(AppColors.burgundy)

            HStack {
                Button("Back", systemImage: "chevron.backward") {
                    dismiss()
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(AppColors.lightPage, in: Circle())
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .padding(.horizontal, 18)
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            modeButton(.sound)
            modeButton(.pomodoro)
        }
        .padding(3)
        .background(AppColors.darkPage.opacity(0.55), in: Capsule())
        .padding(.horizontal, 18)
    }

    private func modeButton(_ mode: FocusMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMode = mode
            }
        } label: {
            Text(mode.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedMode == mode ? Color.white : Color.clear,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedMode == mode ? .isSelected : [])
    }
}

private enum FocusMode {
    case sound
    case pomodoro

    var title: LocalizedStringKey {
        switch self {
        case .sound:
            "Sound"
        case .pomodoro:
            "Pomodoro"
        }
    }
}

#Preview {
    NavigationStack {
        FocusView(viewModel: AppDependencies().focusViewModel)
    }
}
