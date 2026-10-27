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
                MusicPlayerHeader {
                    audioPlayer.pause()
                    dismiss()
                }
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
                    onNext: audioPlayer.next,
                    onReplay: audioPlayer.replay,
                    audioPlayer: audioPlayer
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
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")
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
            // Scaled artwork can extend beyond its clipped layout for hit testing.
            .allowsHitTesting(false)
            .accessibilityLabel(title)
    }
}

private struct MusicPlaybackControls: View {
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onReplay: () -> Void
    @Bindable var audioPlayer: FocusAudioPlayer

    var body: some View {
        VStack(spacing: 34) {
            VStack(spacing: 4) {
                Slider(value: $audioPlayer.playbackPosition, in: 0...max(audioPlayer.duration, 1)) {
                    Text("Playback position")
                }
                .tint(.primary)
                .disabled(audioPlayer.duration <= 0)

                HStack {
                    Text(Self.timeString(audioPlayer.currentTime))
                    Spacer()
                    Text(Self.timeString(audioPlayer.duration))
                }
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.primary)
            }
            .environment(\.layoutDirection, .leftToRight)

            ZStack {
                HStack(spacing: 20) {
                    Button("Previous", systemImage: "backward.end.fill") {
                        onPrevious()
                    }
                    .accessibilityLabel("Previous sound")

                    Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                        onPlayPause()
                    }
                    .font(.system(size: 36))
                    .accessibilityLabel(isPlaying ? "Pause sound" : "Play sound")

                    Button("Next", systemImage: "forward.end.fill") {
                        onNext()
                    }
                    .accessibilityLabel("Next sound")
                }

                HStack {
                    Spacer()

                    Button("Replay", systemImage: "arrow.counterclockwise", action: onReplay)
                        .accessibilityLabel("Replay sound")
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .labelStyle(.iconOnly)
            .font(.system(size: 25))
            .foregroundStyle(AppColors.burgundy)
        }
    }

    private static func timeString(_ time: TimeInterval) -> String {
        let seconds = Int(max(0, time))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
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
