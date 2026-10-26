import SwiftUI

struct MusicPlayerView: View {
    let title: LocalizedStringKey
    let artworkName: String

    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            AppColors.lightPage
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MusicPlayerHeader(onBack: dismiss.callAsFunction)
                    .padding(.bottom, 40)

                MusicArtworkPlaceholder(
                    title: title,
                    imageName: artworkName
                )
                .padding(.horizontal, 30)

                Spacer(minLength: 40)

                MusicPlaybackControls(isPlaying: $isPlaying)
                    .padding(.horizontal, 52)

                Spacer(minLength: 64)
            }
            .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MusicPlayerHeader: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text("Focus")
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(AppColors.burgundy)

            HStack {
                Button("Back", systemImage: "chevron.backward", action: onBack)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(AppColors.darkPage.opacity(0.45))
                    }

                Spacer()
            }
        }
        .padding(.horizontal, 18)
    }
}

private struct MusicArtworkPlaceholder: View {
    let title: LocalizedStringKey
    let imageName: String

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
        }
        .aspectRatio(0.76, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
        .accessibilityLabel(title)
    }
}

private struct MusicPlaybackControls: View {
    @Binding var isPlaying: Bool

    var body: some View {
        VStack(spacing: 34) {
            Capsule()
                .fill(.primary)
                .frame(height: 4)

            HStack {
                Button("Previous", systemImage: "backward.end.fill") {
                    // Audio navigation will be connected through AudioService.
                }
                .accessibilityLabel("Previous sound")

                Spacer()

                Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                    isPlaying.toggle()
                }
                .font(.system(size: 36))
                .accessibilityLabel(isPlaying ? "Pause sound" : "Play sound")

                Spacer()

                Button("Next", systemImage: "forward.end.fill") {
                    // Audio navigation will be connected through AudioService.
                }
                .accessibilityLabel("Next sound")
            }
            .labelStyle(.iconOnly)
            .font(.system(size: 25))
            .foregroundStyle(AppColors.burgundy)
        }
    }
}

#Preview {
    NavigationStack {
        MusicPlayerView(
            title: "Sound",
            artworkName: "khobar"
        )
    }
}
