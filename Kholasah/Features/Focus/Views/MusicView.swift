import SwiftUI

struct MusicView: View {
    private let sounds = [
        FocusSound(id: "night", title: "Night", assetName: "sandHouse"),
        FocusSound(id: "palms", title: "Palms", assetName: "khobar"),
        FocusSound(id: "rain", title: "Rain", assetName: "car"),
        FocusSound(id: "desert", title: "Desert", assetName: "mountain")
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible())
                ],
                spacing: 18
            ) {
                ForEach(sounds) { sound in
                    NavigationLink {
                        MusicPlayerView(
                            title: sound.title,
                            artworkName: sound.assetName
                        )
                    } label: {
                        FocusSoundCard(
                            title: sound.title,
                            imageName: sound.assetName
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
    }
}

private struct FocusSound: Identifiable {
    let id: String
    let title: LocalizedStringKey
    let assetName: String
}

