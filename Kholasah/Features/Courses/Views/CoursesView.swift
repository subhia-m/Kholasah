import SwiftUI

// MARK: - Local model and styles (private to this file)

private struct CoursesListItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var subtitle: String = ""
    var progress: Double = 0
    var styleIndex: Int
}

private let courseCardStyles: [(background: Color, foreground: Color)] = [
    (PlanTheme.deepClay, Color(planHex: "#FFF7F0")),
    (Color.white,        PlanTheme.text),
    (PlanTheme.mauve,    Color(planHex: "#FFF7F0"))
]

// MARK: - My Courses screen

struct CoursesView: View {
    /// Passed in by MainTabView. Not used yet: the list below is local sample data
    /// until we connect it to CoursesViewModel.
    var viewModel: CoursesViewModel? = nil
    var planViewModel: PlanViewModel? = nil

    @State private var courses: [CoursesListItem] = [
        CoursesListItem(title: "English", progress: 0.45, styleIndex: 0),
        CoursesListItem(title: "UI Design", progress: 0.60, styleIndex: 1),
        CoursesListItem(title: "Swift Skills",
                        subtitle: "Learn iOS development with Swift",
                        progress: 0.20, styleIndex: 2)
    ]
    @State private var expandedID: UUID?
    @State private var selectedCourse: CoursesListItem?
    @State private var showingAddSheet = false

    var body: some View {
        // No NavigationStack here: MainTabView already provides one.
        ZStack(alignment: .bottomTrailing) {
            PlanTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                PlanTopBar(title: "My Courses")
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: -28) {
                        ForEach(Array(courses.enumerated()), id: \.element.id) { index, course in
                            StackedCourseCard(
                                course: course,
                                isExpanded: expandedID == course.id
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

            PlanAddButton(label: "Add course") { showingAddSheet = true }
                .padding(.trailing, 28)
                .padding(.bottom, 16)
        }
        .navigationDestination(item: $selectedCourse) { course in
            PlanView(courseTitle: course.title, viewModel: planViewModel, showsBackButton: true)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddSheet) {
            NewCourseSheet { title, subtitle in
                let item = CoursesListItem(
                    title: title,
                    subtitle: subtitle,
                    styleIndex: courses.count % courseCardStyles.count
                )
                withAnimation {
                    courses.append(item)
                    expandedID = item.id
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if expandedID == nil { expandedID = courses.last?.id }
        }
    }
}

// MARK: - Card

private struct StackedCourseCard: View {
    let course: CoursesListItem
    let isExpanded: Bool

    private var style: (background: Color, foreground: Color) {
        courseCardStyles[course.styleIndex % courseCardStyles.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(course.title)
                .font(.system(size: 22, weight: .regular, design: .serif))

            if isExpanded {
                if !course.subtitle.isEmpty {
                    Text(course.subtitle)
                        .font(.system(size: 13))
                        .padding(.top, 8)
                }

                ProgressView(value: course.progress)
                    .tint(style.foreground)
                    .padding(.top, 4)

                Text("\(Int(course.progress * 100))%")
                    .font(.system(size: 13, weight: .medium))

                Spacer(minLength: 0)
            }
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, isExpanded ? 16 : 40)   // the extra space is hidden by the next card's overlap
        .frame(maxWidth: .infinity, minHeight: isExpanded ? 230 : 0, alignment: .topLeading)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

// MARK: - Add course sheet

private struct NewCourseSheet: View {
    let onAdd: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var subtitle = ""
    @FocusState private var isFocused: Bool

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Course")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(PlanTheme.text)

            TextField("Course name", text: $title)
                .focused($isFocused)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            TextField("Short description (optional)", text: $subtitle)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .font(.system(size: 16))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button("Add") {
                    guard !trimmedTitle.isEmpty else { return }
                    onAdd(trimmedTitle,
                          subtitle.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(PlanTheme.deepClay))
                .opacity(trimmedTitle.isEmpty ? 0.4 : 1)
                .disabled(trimmedTitle.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .background(PlanTheme.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }
}

#Preview {
    NavigationStack {
        CoursesView()
    }
}
