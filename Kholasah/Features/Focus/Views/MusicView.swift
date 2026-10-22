import SwiftUI

struct MusicView: View {
    var body: some View {
        ContentUnavailableView(
            "Focus Music",
            systemImage: "music.note",
            description: Text("Audio playback will be connected through AudioService in a future iteration.")
        )
        .navigationTitle("Music")
    }
}
