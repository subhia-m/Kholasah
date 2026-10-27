import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct CourseView: View {
    let coursesViewModel: CoursesViewModel
    let planViewModel: PlanViewModel?

    // MARK: - Form Data

    @State private var courseName = ""
    @State private var startDate = Date()
    @State private var endDate =
        Calendar.current.date(byAdding: .day, value: 6, to: .now) ?? .now
    @State private var motivationType = "Choose a type"
    @State private var goals = ""
    @State private var additionalGoals = ""

    // Upload states
    @State private var showFileImporter = false
    @State private var selectedFiles: [URL] = []
    @State private var dailyMinutes = 30
    @State private var remindersEnabled = true
    @State private var preferredStudyTime =
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: .now) ?? .now
    @State private var generatedCourse: Course?

    // Alert
    @State private var showAlert = false
    @State private var alertMessage = ""


    private let motivationTypes = [
        "bbbbb",
        "aaaaa",
        "ccccc",
        "ddddd",
        "Other"
    ]

    private var durationDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        return max((calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1, 1)
    }

    // MARK: - Colors

    private let backgroundColor = Color(
        red: 0.96, green: 0.94, blue: 0.92
    )

    private let darkBrown = Color(
        red: 0.31, green: 0.04, blue: 0.01
    )

    private let titleBrown = Color(
        red: 0.42, green: 0.10, blue: 0.06
    )

    private let labelOrange = Color(
        red: 0.73, green: 0.36, blue: 0.16
    )

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            GeometryReader { geometry in
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .offset(x: -150, y: 102)
                    .opacity(0.2)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                
                // MARK: Header
                
                Text("Add Course")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(titleBrown)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // MARK: Form
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        // Course Name
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Course Name:")
                            
                            TextField(
                                "Enter course name",
                                text: $courseName
                            )
                            .padding(.horizontal, 18)
                            .frame(height: 70)
                            .background(fieldBackground)
                            .textInputAutocapitalization(.words)
                        }
                        
                        // Start Date and End Date
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 0) {
                                fieldLabel("Start Date:")
                                
                                DatePicker(
                                    "Start Date",
                                    selection: $startDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 64,
                                    alignment: .leading
                                )
                                .padding(.leading, 12)
                                .background(fieldBackground)
                                .onChange(of: startDate) { _, newStartDate in
                                    if endDate < newStartDate {
                                        endDate = newStartDate
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                fieldLabel("End Date:")
                                
                                DatePicker(
                                    "End Date",
                                    selection: $endDate,
                                    in: startDate...,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 64,
                                    alignment: .leading
                                )
                                .padding(.leading, 12)
                                .background(fieldBackground)
                            }
                        }
                        
                        // Motivation Type
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Motivation Type:")
                            
                            Picker(
                                "Motivation Type",
                                selection: $motivationType
                            ) {
                                Text("Choose a type")
                                    .tag("Choose a type")
                                
                                ForEach(
                                    motivationTypes,
                                    id: \.self
                                ) { type in
                                    Text(type)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(darkBrown)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 70,
                                alignment: .leading
                            )
                            .padding(.horizontal, 18)
                            .background(fieldBackground)
                        }
                        
                        // Goals
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Goals:")
                            
                            TextField(
                                "What do you want to achieve?",
                                text: $goals,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 95,
                                alignment: .topLeading
                            )
                            .background(fieldBackground)
                        }
                        
                        // Tasks
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Tasks:")
                            
                            TextField(
                                "Add your tasks",
                                text: $additionalGoals,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 95,
                                alignment: .topLeading
                            )
                            .background(fieldBackground)
                        }
                        
                        // MARK: Course Materials
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Course Materials:")
                            
                            Button {
                                showFileImporter = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 21))
                                        .foregroundStyle(darkBrown)
                                    
                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {
                                        Text("Upload materials")
                                            .font(.system(size: 15))
                                            .foregroundStyle(darkBrown)
                                        
                                        Text(planViewModel?.importedMaterial?.fileName ?? "No file selected")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 62
                                )
                                .background(fieldBackground)
                            }
                            .buttonStyle(.plain)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            fieldLabel("Study Plan:")

                            Text("Plan duration: \(durationDays) days")

                            Stepper(
                                "Daily study: \(dailyMinutes) minutes",
                                value: $dailyMinutes,
                                in: 15...180,
                                step: 15
                            )

                            Toggle("Daily study reminders", isOn: $remindersEnabled)
                                .tint(titleBrown)

                            if remindersEnabled {
                                DatePicker(
                                    "Preferred study time",
                                    selection: $preferredStudyTime,
                                    displayedComponents: .hourAndMinute
                                )
                            }

                            if let planViewModel {
                                Text(planViewModel.aiAvailability.message)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(18)
                        .background(fieldBackground)
                        
                        
                        // MARK: Done Button
                        Button {
                            generatePlan()
                        } label: {
                            Text(planViewModel?.isGeneratingPlan == true ? "Creating plan…" : "Generate study plan")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(darkBrown)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 30)
                                )
                        }
                        .disabled(planViewModel?.isGeneratingPlan == true)
                        .padding(.top, 10)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        // MARK: File Importer
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [
                .pdf,
                .plainText
            ],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedFiles = urls
                guard let url = urls.first, let planViewModel else { return }
                Task {
                    await planViewModel.importStudyMaterial(from: url)
                }
            case .failure(let error):
                print("File selection failed: \(error)")
            }
        }
        // MARK: Alert
        .alert(
            "Course",
            isPresented: $showAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .navigationDestination(item: $generatedCourse) { course in
            CourseFlowView(
                course: course,
                viewModel: planViewModel,
                showsBackButton: true,
                startingAt: .plan
            )
        }
    }

    // MARK: - Reusable Components

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(.white.opacity(0.92))
            .shadow(
                color: Color.brown.opacity(0.13),
                radius: 10,
                x: 0,
                y: 6
            )
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(titleBrown)
            .padding(.leading, 10)
    }

    private func generatePlan() {
        let normalizedName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else {
            alertMessage = "Please enter a course name before continuing."
            showAlert = true
            return
        }
        guard let planViewModel else {
            alertMessage = "Plan generation is unavailable."
            showAlert = true
            return
        }
        guard planViewModel.importedMaterial != nil else {
            alertMessage = "Please upload a PDF or text file before generating the plan."
            showAlert = true
            return
        }
        guard let course = coursesViewModel.createCourse(title: normalizedName, instructor: "") else {
            alertMessage = coursesViewModel.errorMessage ?? "Unable to create the course."
            showAlert = true
            return
        }

        Task {
            await planViewModel.generateStudyPlan(
                courseID: course.id,
                durationDays: durationDays,
                dailyMinutes: dailyMinutes,
                remindersEnabled: remindersEnabled,
                preferredStudyTime: preferredStudyTime
            )

            if planViewModel.didSaveGeneratedPlan {
                generatedCourse = course
            } else {
                coursesViewModel.removeCourse(id: course.id)
                alertMessage = planViewModel.planGenerationError ?? "Unable to generate the study plan."
                showAlert = true
            }
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    NavigationStack {
        CourseView(
            coursesViewModel: dependencies.coursesViewModel,
            planViewModel: dependencies.planViewModel
        )
    }
}
