import SwiftUI

struct MusicPlayerView: View {
    let title: LocalizedStringKey
    let artworkName: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var audioPlayer = FocusAudioPlayer()

    var body: some View {
        ZStack {
            AppColors.lightPage
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MusicPlayerHeader(onBack: dismiss.callAsFunction)
                    .padding(.bottom, 40)

                MusicArtworkPlaceholder(
                    title: title,
                    imageName: audioPlayer.artworkName
                )
                .padding(.horizontal, 30)

                Spacer(minLength: 40)

                MusicPlaybackControls(
                    isPlaying: audioPlayer.isPlaying,
                    onPlayPause: audioPlayer.togglePlayback,
                    onPrevious: audioPlayer.previous,
                    onNext: audioPlayer.next
                )
                    .padding(.horizontal, 52)

                Spacer(minLength: 64)
            }
            .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { audioPlayer.select(artworkName: artworkName) }
        .onDisappear { audioPlayer.pause() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { audioPlayer.pause() }
        }
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
        Color.clear
            .aspectRatio(3 / 4, contentMode: .fit)
            .overlay {
                Image(imageName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            }
            .accessibilityLabel(title)
    }
}

private struct MusicPlaybackControls: View {
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 34) {
            Capsule()
                .fill(.primary)
                .frame(height: 4)

            HStack {
                Button("Previous", systemImage: "backward.end.fill") {
                    onPrevious()
                }
                .accessibilityLabel("Previous sound")

                Spacer()

                Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                    onPlayPause()
                }
                .font(.system(size: 36))
                .accessibilityLabel(isPlaying ? "Pause sound" : "Play sound")

                Spacer()

                Button("Next", systemImage: "forward.end.fill") {
                    onNext()
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
