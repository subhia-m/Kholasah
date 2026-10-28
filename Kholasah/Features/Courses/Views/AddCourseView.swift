import SwiftUI

struct AddCourseWelcomeView: View {
    let onAddCourse: () -> Void
//بوابتك الخاصة عشان تقولي للشاشة اللي برا: "ترى المستخدم ضغط الزر الفلاني، وش تبغيني أسوي الحين؟".
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
            ZStack {
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
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
                    dependencies.appState.hasSkippedFirstCourseSetup = true
                } label: {
                    Text("Skip")
                        .font(AppTypography.footnote)
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
                .font(AppTypography.displayTitle)
                .foregroundStyle(Color.titleBrown)

            // يرتب العناصر أفقيًا.
            HStack(spacing: 10) {
                Text("FIRST COURSE")
                    .font(AppTypography.displayTitle)
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
                .font(AppTypography.title)
                .foregroundStyle(Color.titleBrown)
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
                    .font(AppTypography.subheadlineEmphasized)
                    .italic()
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
                    .offset(x: -28)
            }
        }
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
