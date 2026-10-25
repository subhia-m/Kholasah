import SwiftUI

struct MusicView: View {
    @State private var selectedSoundID: String?

    private let sounds = [
        FocusSound(id: "night", title: "Night", color: AppColors.burgundy),
        FocusSound(id: "palms", title: "Palms", color: AppColors.darkPage),
        FocusSound(id: "rain", title: "Rain", color: AppColors.brown),
        FocusSound(id: "desert", title: "Desert", color: AppColors.sand)
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
                    FocusSoundCard(
                        title: sound.title,
                        backgroundColor: sound.color,
                        isSelected: selectedSoundID == sound.id
                    ) {
                        selectedSoundID = sound.id
                    }
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
    let color: Color
}
