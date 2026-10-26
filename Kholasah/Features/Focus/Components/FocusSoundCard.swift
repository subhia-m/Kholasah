import SwiftUI

struct FocusSoundCard: View {
    let title: LocalizedStringKey
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
        .frame(maxWidth: .infinity)
        .frame(height: 245)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
        .accessibilityLabel(title)
    }
}
