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
    let onAddCourse: () -> Void

    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()

            WelcomeHeroView(onAddCourse: onAddCourse)
        }
    }
}

private struct WelcomeHeroView: View {
    let onAddCourse: () -> Void

    var body: some View {
        GeometryReader { proxy in
            // Root ZStack to handle visual layers correctly inside GeometryReader
            ZStack {
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width * 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .ignoresSafeArea(edges: .bottom)
                    .offset(x: -150, y: 102)
                    .opacity(0.6)

                Button(action: onAddCourse) {
                    Image(systemName: "plus")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundStyle(Color.white)
                        .frame(width: 72, height: 72)
                        .background(Color.neutralGray.opacity(0.8), in: Circle())
                }
                
                VStack(spacing: 0) {
                    WelcomeTitleView()
                        .padding(.top, 58)

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

struct FirstCourseSetupView: View {
    let dependencies: AppDependencies
    @State private var showingCourseDetails = false

    var body: some View {
        NavigationStack {
            AddCourseWelcomeView {
                showingCourseDetails = true
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dependencies.appState.completeFirstCourseSetup()
                } label: {
                    Text("Skip")
                        .font(.footnote)
                        .foregroundStyle(AppColors.brown.opacity(0.7))
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Continue to Board, Focus, and Courses without adding a course")
                .padding(.trailing, 20)
                .padding(.top, 4)
            }
            .navigationDestination(isPresented: $showingCourseDetails) {
                CourseView(
                    coursesViewModel: dependencies.coursesViewModel,
                    planViewModel: dependencies.planViewModel
                ) { _ in
                    dependencies.appState.completeFirstCourseSetup()
                }
            }
        }
    }
}

private struct WelcomeTitleView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("ADD YOUR")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.titleBrown)

            HStack(spacing: 10) {
                Text("FIRST COURSE")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.titleBrown)

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
        }
        .multilineTextAlignment(.center)
    }
}

private struct FirstCoursePromptView: View {
    var body: some View {
        VStack(spacing: 31) {
            Text("Add your first course!")
                .font(.system(size: 21, weight: .regular, design: .rounded))
                .foregroundStyle(Color.titleBrown)
        }
        .accessibilityLabel("Add your first course")
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
    static let neutralGray = Color(red: 151 / 255, green: 151 / 255, blue: 151 / 255)
}

#Preview {
    AddCourseWelcomeView(onAddCourse: {})
}
