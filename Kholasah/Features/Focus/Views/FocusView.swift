import SwiftUI

struct FocusView: View {
    let viewModel: FocusViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PomodoroView(viewModel: viewModel)

                NavigationLink {
                    MusicView()
                } label: {
                    Label("Focus Music", systemImage: "music.note")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Focus")
    }
}
