// MARK: 

import SwiftUI

// MARK: - Card colors (cycled by position in the list)

private let courseCardStyles: [(background: Color, foreground: Color)] = [
    (PlanTheme.deepClay, Color(planHex: "#FFF7F0")),
    (Color.white,        PlanTheme.text),
    (PlanTheme.mauve,    Color(planHex: "#FFF7F0"))
]

// MARK: - My Courses screen

struct CoursesView: View {
    let viewModel: CoursesViewModel
    /// Pass `dependencies.planViewModel` from MainTabView so each course's tasks
    /// are shared with the rest of the app. Without it, tasks stay local to the screen.
    var planViewModel: PlanViewModel? = nil

    @State private var expandedID: Course.ID?
    @State private var selectedCourse: Course?
    @State private var showingCourseDetails = false

    // NEW: how many of this course's tasks are done, and how many there are in total.
    private func taskCounts(for course: Course) -> (done: Int, total: Int) {
        let courseTasks = planViewModel?.tasks.filter { $0.courseID == course.id } ?? []
        return (courseTasks.filter(\.isCompleted).count, courseTasks.count)
    }

    var body: some View {
        // No NavigationStack here: MainTabView already provides one.
        ZStack(alignment: .bottomTrailing) {
            PlanTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                PlanTopBar(title: "My Courses")
                    .padding(.top, 12)

                if viewModel.courses.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: -28) {
                            ForEach(Array(viewModel.courses.enumerated()), id: \.element.id) { index, course in
                                let counts = taskCounts(for: course)          // NEW
                                StackedCourseCard(
                                    course: course,
                                    styleIndex: index,
                                    isExpanded: expandedID == course.id,
                                    completedCount: counts.done,              // NEW
                                    totalCount: counts.total                  // NEW
                                )
                                .zIndex(Double(index))
                                .onTapGesture {
                                    if expandedID == course.id {
                                        selectedCourse = course          // second tap opens the course
                                    } else {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            expandedID = course.id       // first tap expands it
                                        }
                                    }
                                }
                                .accessibilityAddTraits(.isButton)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                }
            }

            PlanAddButton(label: "Add course") { showingCourseDetails = true }
                .padding(.trailing, 28)
                .padding(.bottom, 16)
        }
        .navigationDestination(item: $selectedCourse) { course in
            CourseFlowView(course: course,
                           viewModel: planViewModel,
                           showsBackButton: true,
                           startingAt: .overview)
        }
        .navigationDestination(isPresented: $showingCourseDetails) {
            CourseView(
                coursesViewModel: viewModel,
                planViewModel: planViewModel
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if expandedID == nil { expandedID = viewModel.courses.last?.id }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "book")
                .font(.system(size: 34))
            Text("No courses yet")
                .font(.system(size: 18, weight: .medium))
            Text("Tap + to add your first course.")
                .font(.system(size: 14))
                .opacity(0.6)
            Spacer()
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Card

private struct StackedCourseCard: View {
    let course: Course
    let styleIndex: Int
    let isExpanded: Bool
    let completedCount: Int          // NEW
    let totalCount: Int              // NEW

    private var style: (background: Color, foreground: Color) {
        courseCardStyles[styleIndex % courseCardStyles.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(course.title)
                .font(.system(size: 22, weight: .regular, design: .serif))

            if isExpanded {
                if !course.instructor.isEmpty {
                    Label(course.instructor, systemImage: "person")
                        .font(.system(size: 13))
                        .padding(.top, 8)
                }

                ProgressCard(
                    completedCount: completedCount,
                    totalCount: totalCount,
                    progress: totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount)
                )
                .foregroundStyle(PlanTheme.text)
                .padding(.top, 8)

                Spacer(minLength: 0)
            }
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, isExpanded ? 16 : 40)   // the extra space is hidden by the next card's overlap
        .frame(maxWidth: .infinity, minHeight: isExpanded ? 190 : 0, alignment: .topLeading)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

#Preview {

    MainTabView(dependencies: AppDependencies())
}
