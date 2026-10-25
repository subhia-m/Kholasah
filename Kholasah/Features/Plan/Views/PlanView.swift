import SwiftUI

// MARK: - Theme (used only by the Plan and Courses screens)

extension Color {
    init(planHex hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

enum PlanTheme {
    static let background        = Color(planHex: "#F1EFEC")
    static let text              = Color(planHex: "#4A1B14")
    static let deepClay          = Color(planHex: "#703B2F")
    static let mauve             = Color(planHex: "#9A7B72")
    static let progressBrown     = Color(planHex: "#6E4840")
    static let controlBackground = Color(planHex: "#ECE8E3")
    static let chip              = Color(planHex: "#DEDAD6")
}

// MARK: - Shared building blocks

struct PlanTopBar: View {
    let title: String
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(PlanTheme.text)

            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(PlanTheme.text)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(PlanTheme.chip))
                    }
                    .accessibilityLabel("Back")
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

struct PlanAddButton: View {
    var label: String = "Add"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(PlanTheme.text)
                .frame(width: 36, height: 36)
                .background(Circle().fill(PlanTheme.chip))
        }
        .accessibilityLabel(label)
    }
}

struct PlanPalmLeaf: View {
    var body: some View {
        // Optional decoration: add an image named "palmLeaf" to Assets.
        Image("palmLeaf")
            .resizable()
            .scaledToFit()
            .frame(width: 40)
            .opacity(0.35)
            .allowsHitTesting(false)
    }
}

/// White card with a soft shadow and a palm leaf in the corner.
struct PlanCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
            PlanPalmLeaf().padding(8)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

// MARK: - Section switcher

enum PlanScreenTab: String, CaseIterable {
    case overview = "Overview"
    case plan = "Plan"
    case tasks = "Tasks"
    case reminders = "Reminders"
}

struct PlanSectionPicker: View {
    @Binding var selection: PlanScreenTab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PlanScreenTab.allCases, id: \.self) { tab in
                let isSelected = tab == selection
                Text(tab.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selection = tab
                        }
                    }
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(Capsule().fill(PlanTheme.controlBackground))
        .padding(.horizontal, 12)
    }
}

// MARK: - Plan tab placeholder

private struct PlanSchedulePlaceholder: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("palm")
                .resizable()
                .scaledToFit()
                .frame(height: 320)
                .opacity(0.15)
            Text("Your study plan will appear here")
                .font(.system(size: 15))
                .foregroundStyle(PlanTheme.text.opacity(0.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

// MARK: - PlanView (course screen)

struct PlanView: View {
    var courseTitle: String = "Swift Basics"
    /// Passed in by MainTabView. Not used yet: tasks and reminders are local
    /// until we connect them to PlanViewModel.
    var viewModel: PlanViewModel? = nil
    /// True when opened from a course card, false when it is the Plan tab's root screen.
    var showsBackButton: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var selection: PlanScreenTab = .overview
    @State private var tasks: [PlanTaskItem] = []
    @State private var reminders: [PlanReminderItem] = []

    var body: some View {
        ZStack {
            PlanTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                PlanTopBar(title: courseTitle,
                           onBack: showsBackButton ? { dismiss() } : nil)

                PlanSectionPicker(selection: $selection)
                    .padding(.bottom, 10)

                Divider()

                Group {
                    switch selection {
                    case .overview:
                        PlanOverviewView(tasks: tasks, reminders: reminders)
                    case .plan:
                        PlanSchedulePlaceholder()
                    case .tasks:
                        TasksView(tasks: $tasks)
                    case .reminders:
                        RemindersView(reminders: $reminders)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        PlanView()
    }
}
