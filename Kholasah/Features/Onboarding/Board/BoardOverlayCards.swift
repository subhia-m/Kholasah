import SwiftUI

struct BoardStreakCard: View {
    let streak: BoardStreak
    let calendar: Calendar
    let close: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var flamePosition

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Text("Streak!").font(AppTypography.largeTitle)
                Spacer()
                BoardCloseButton(label: "Close streak", action: close)
            }
            HStack(spacing: 3) {
                ForEach(streak.week(calendar: calendar), id: \.self) { date in
                    VStack(spacing: 3) {
                        ZStack(alignment: .top) {
                            if streak.count > 0,
                               let last = streak.lastRecordedDay,
                               calendar.isDate(last, inSameDayAs: date) {
                                BoardFlame()
                                    .matchedGeometryEffect(id: "flame", in: flamePosition)
                            }
                            // Draw the fruit last: it masks the lower flame while remaining still.
                            Image("date").resizable().scaledToFit()
                                .frame(height: 34)
                                .padding(.top, 14)
                        }
                        .frame(height: 48)
                        Text(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US"))))
                            .font(.system(.caption2, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
                    .accessibilityValue(isLastDay(date) ? "Latest streak day" : "")
                }
            }
            .background {
                GeometryReader { geometry in
                    Path { path in
                        let inset = geometry.size.width / 14
                        path.move(to: CGPoint(x: inset, y: 31))
                        path.addLine(to: CGPoint(x: geometry.size.width - inset, y: 31))
                    }
                    .stroke(AppColors.date.opacity(0.7),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 5]))
                }
                .accessibilityHidden(true)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: streak.lastRecordedDay)
            Text("\(streak.count) DAY STREAK")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.date)
        }
        .padding(14)
        .boardFloatingCard()
    }

    private func isLastDay(_ date: Date) -> Bool {
        streak.count > 0 && streak.lastRecordedDay.map { calendar.isDate($0, inSameDayAs: date) } == true
    }
}

private struct BoardFlame: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    var body: some View {
        Image("fire").resizable().scaledToFit()
            .frame(width: 26, height: 30)
            .scaleEffect(pulsing ? 1.08 : 0.92, anchor: .bottom)
            .rotationEffect(.degrees(pulsing ? 4 : -4), anchor: .bottom)
            .onAppear { pulsing = !reduceMotion }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulsing)
            .accessibilityHidden(true)
    }
}

struct BoardMotivationCard: View {
    let close: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.max").font(.largeTitle)
            VStack(alignment: .leading, spacing: 3) {
                Text("Keep going!").font(AppTypography.title)
                Text("Every small step counts.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.date)
            }
            Spacer(minLength: 0)
            BoardCloseButton(label: "Dismiss encouragement", action: close)
        }
        .padding(12)
        .boardFloatingCard()
    }
}

struct BoardCloseButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark").frame(width: 32, height: 32)
        }
        .accessibilityLabel(label)
        .buttonStyle(.plain)
    }
}

private extension View {
    func boardFloatingCard() -> some View {
        foregroundStyle(AppColors.primary)
            .background(AppColors.card, in: RoundedRectangle(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26).stroke(PlanTheme.text.opacity(0.7), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
    }
}

struct BoardQuotesView: View {
    @State private var index = 0
    private let quotes = [
        "You are doing better than you think.",
        "Small steps make great progress.",
        "Your effort today shapes tomorrow.",
        "One task at a time. You’ve got this.",
        "Progress matters more than perfection."
    ]

    var body: some View {
        Button {
            index = (index + 1) % quotes.count
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bell.and.waves.left.and.right")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quotes").font(.subheadline.weight(.semibold))
                    Text("“\(quotes[index])”").font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
            }
            .padding(18)
            .foregroundStyle(.white)
            .boardCard(fill: Color(red: 153 / 255, green: 93 / 255, blue: 72 / 255))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Shows another quote")
    }
}
