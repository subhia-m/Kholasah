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
    static let background        = AppColors.background   // page background
    static let text              = AppColors.burgundy     // titles and body text
    static let deepClay          = AppColors.primary      // main buttons, checkmarks, first course card
    static let mauve             = AppColors.brown        // "New Task" box, third course card
    static let progressBrown     = AppColors.burgundy     // Course Progress box
    static let controlBackground = AppColors.darkPage     // switcher bar and text fields
    static let chip              = AppColors.darkPage     // round + / back buttons, Cancel buttons
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
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 48)   // keeps long names clear of the back button
                .accessibilityAddTraits(.isHeader)

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

// MARK: - Page scaffold (every page uses this: background, top bar, switcher, divider)

struct PlanPageScaffold<Content: View>: View {
    let title: String
    @Binding var selection: PlanScreenTab
    var onBack: (() -> Void)? = nil
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            PlanTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                PlanTopBar(title: title, onBack: onBack)

                PlanSectionPicker(selection: $selection)
                    .padding(.bottom, 10)

                Divider()

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Plan page (intentionally empty for now)

/// The "Plan" page. Empty until the team decides what goes here; it only shows
/// the palm backdrop from the design (invisible if the image isn't in Assets).
struct PlanView: View {
    var courseTitle: String = "Plan"
    /// Passed in by MainTabView.
    var viewModel: PlanViewModel? = nil
    var showsBackButton: Bool = false

    /// Set by CourseFlowView so the switcher can move between pages.
    /// When nil (for example MainTabView creates PlanView directly), the page
    /// wraps itself in a CourseFlowView so the switcher still works.
    var selection: Binding<PlanScreenTab>? = nil
    var onBack: (() -> Void)? = nil

    var body: some View {
        if let selection {
            PlanPageScaffold(title: courseTitle, selection: selection, onBack: onBack) {
                Image("palm")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 320)
                    .opacity(0.15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        } else {
            CourseFlowView(course: nil,
                           viewModel: viewModel,
                           showsBackButton: showsBackButton,
                           startingAt: .plan)
        }
    }
}

#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    NavigationStack {
        CourseFlowView(course: Course(title: "Swift Basics"), showsBackButton: true, startingAt: .plan)
    }
}
