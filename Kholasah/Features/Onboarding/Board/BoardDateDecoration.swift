import SwiftUI

/// Uses the existing single-date asset to compose the three-date header decoration.
struct BoardDateDecoration: View {
    var body: some View {
        ZStack {
            Image("date").resizable().scaledToFit()
                .frame(width: 47, height: 47)
                .rotationEffect(.degrees(70))
                .offset(x: 8, y: -20)
            Image("date").resizable().scaledToFit()
                .frame(width: 47, height: 52)
                .rotationEffect(.degrees(-15))
                .offset(x: -15, y: 10)
            Image("date").resizable().scaledToFit()
                .frame(width: 47, height: 52)
                .rotationEffect(.degrees(85))
                .offset(x: 17, y: 11)
        }
    }
}
