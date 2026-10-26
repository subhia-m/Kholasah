import SwiftUI

struct AddCourseView: View {
    let viewModel: CoursesViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var instructor = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Course Details") {
                    TextField("Course title", text: $title)
                    TextField("Instructor (optional)", text: $instructor)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearError()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addCourse()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addCourse() {
        if viewModel.addCourse(title: title, instructor: instructor) {
            dismiss()
        }
    }
}

struct AddCourseWelcomeView: View {
    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()

            WelcomeHeroView()
        }
    }
}

private struct WelcomeHeroView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width * 0.62) // Restored correct multiplier width
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    HStack {
                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(Color.titleBrown)
                                .frame(width: 48, height: 48)
                                .background(.clear, in: Circle())
                                .overlay {
                                    Circle()
                                        .stroke(Color.titleBrown.opacity(0.08), lineWidth: 1)
                                }
                        }
                        .accessibilityLabel("Continue")
                    }
                    .padding(.top, 24)
                    .padding(.trailing, 25)

                    WelcomeTitleView()
                        .padding(.top, 34)

                    FirstCoursePromptView()
                        .padding(.top, 54)

                    Spacer()

                    QuoteView()
                        .padding(.leading, 138)
                        .padding(.trailing, 12)
                        .padding(.bottom, 80)
                }
            }
        }
    }
}

private struct WelcomeTitleView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome to")
                .font(.system(size: 45, weight: .bold))

            HStack(alignment: .bottom, spacing: 2) {
                Text("Kholasah")
                    .font(.system(size: 45, weight: .bold))

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(.bottom, 1)
            }
        }
        .foregroundStyle(Color.titleBrown)
        .minimumScaleFactor(0.6)
        .lineLimit(1)
    }
}

private struct FirstCoursePromptView: View {
    var body: some View {
        VStack(spacing: 31) {
            Text("Add your first course!")
                .font(.system(size: 21, weight: .regular, design: .rounded))
                .foregroundStyle(Color.titleBrown)

            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundStyle(Color.titleBrown)
                    .frame(width: 72, height: 72)
                    .background(Color.titleBrown.opacity(0.12), in: Circle())
            }
            .accessibilityLabel("Add your first course")
        }
    }
}

private struct QuoteView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.quoteBrown.opacity(0.89))
                .frame(height: 70)

            HStack(spacing: 8) {
                Image("date")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 66, height: 66)
                    .rotationEffect(.degrees(5))
                    .offset(x: -22, y: 19)

                Text("“ motivation quote here ”")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .italic()
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
                    .offset(x: -28)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Motivation quote")
    }
}

private extension Color {
    static let backgroundCream = Color(red: 242 / 255, green: 238 / 255, blue: 234 / 255)
    static let quoteBrown = Color(red: 72 / 255, green: 9 / 255, blue: 2 / 255)
    static let titleBrown = Color(red: 100 / 255, green: 25 / 255, blue: 14 / 255)
}

#Preview {
    AddCourseWelcomeView()
}
