import SwiftUI
import UniformTypeIdentifiers

struct StudyMaterialImportView: View {
    let viewModel: PlanViewModel
    var courseID: Course.ID? = nil

    @State private var isFileImporterPresented = false
    @State private var durationDays = 7
    @State private var dailyMinutes = 30
    @State private var remindersEnabled = false
    @State private var preferredStudyTime =
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: .now) ?? .now

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StudyMaterialIntroduction()

                StudyMaterialDropZone(
                    selectedFileName: viewModel.importedMaterial?.fileName,
                    pageCount: viewModel.importedMaterial?.pageCount,
                    isImporting: viewModel.isImportingMaterial,
                    onChooseFile: { isFileImporterPresented = true },
                    onRemoveFile: viewModel.removeImportedMaterial
                )

                if let material = viewModel.importedMaterial {
                    ExtractedTextPreview(text: material.text)

                    AIPlanControls(
                        durationDays: $durationDays,
                        dailyMinutes: $dailyMinutes,
                        remindersEnabled: $remindersEnabled,
                        preferredStudyTime: $preferredStudyTime,
                        availability: viewModel.aiAvailability,
                        isGenerating: viewModel.isGeneratingPlan
                    ) {
                        Task {
                            await viewModel.generateStudyPlan(
                                courseID: courseID,
                                durationDays: durationDays,
                                dailyMinutes: dailyMinutes,
                                remindersEnabled: remindersEnabled,
                                preferredStudyTime: preferredStudyTime
                            )
                        }
                    }
                }

                if let draft = viewModel.generatedPlanDraft {
                    GeneratedPlanDraftView(
                        draft: draft,
                        didSave: viewModel.didSaveGeneratedPlan
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
        .scrollIndicators(.hidden)
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf, .plainText]
        ) { result in
            handleImportResult(result)
        }
        .alert(
            "Unable to Import File",
            isPresented: Binding(
                get: { viewModel.materialImportError != nil },
                set: { if !$0 { viewModel.materialImportError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.materialImportError ?? "")
        }
        .alert(
            "Unable to Schedule Reminders",
            isPresented: Binding(
                get: { viewModel.notificationError != nil },
                set: { if !$0 { viewModel.notificationError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.notificationError ?? "")
        }
        .alert(
            "Unable to Generate Plan",
            isPresented: Binding(
                get: { viewModel.planGenerationError != nil },
                set: { if !$0 { viewModel.planGenerationError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.planGenerationError ?? "")
        }
    }

    private func handleImportResult(_ result: Result<URL, any Error>) {
        switch result {
        case .success(let url):
            Task {
                await viewModel.importStudyMaterial(from: url)
            }
        case .failure(let error):
            viewModel.materialImportError = error.localizedDescription
        }
    }
}

private struct StudyMaterialIntroduction: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(PlanTheme.deepClay)
                .accessibilityHidden(true)

            Text("Create Your Study Plan")
                .font(.title2.weight(.semibold))
                .foregroundStyle(PlanTheme.text)

            Text("Upload your study material. Later, Kholasah will use it to create tasks, reviews, and reminders.")
                .font(.subheadline)
                .foregroundStyle(PlanTheme.text.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
}

private struct StudyMaterialDropZone: View {
    let selectedFileName: String?
    let pageCount: Int?
    let isImporting: Bool
    let onChooseFile: () -> Void
    let onRemoveFile: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: selectedFileName == nil ? "doc.badge.plus" : "doc.text.fill")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(PlanTheme.deepClay)
                .accessibilityHidden(true)

            if isImporting {
                ProgressView("Reading PDF…")
                    .tint(PlanTheme.deepClay)
            } else if let selectedFileName {
                Text(selectedFileName)
                    .font(.headline)
                    .foregroundStyle(PlanTheme.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("\(pageCount ?? 0) pages • Text extracted")
                    .font(.caption)
                    .foregroundStyle(PlanTheme.text.opacity(0.6))
            } else {
                Text("Choose Study Material")
                    .font(.headline)
                    .foregroundStyle(PlanTheme.text)

                Text("PDF or TXT")
                    .font(.caption)
                    .foregroundStyle(PlanTheme.text.opacity(0.6))
            }

            Button(
                selectedFileName == nil ? "Select File" : "Choose Another File",
                action: onChooseFile
            )
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(PlanTheme.deepClay, in: Capsule())
            .disabled(isImporting)

            if selectedFileName != nil {
                Button("Remove File", role: .destructive, action: onRemoveFile)
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    PlanTheme.mauve,
                    style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                )
        }
        .accessibilityElement(children: .contain)
    }
}

private struct ExtractedTextPreview: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Extracted Text Preview", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundStyle(PlanTheme.text)

            Text(text)
                .font(.caption)
                .foregroundStyle(PlanTheme.text.opacity(0.75))
                .lineLimit(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct AIPlanControls: View {
    @Binding var durationDays: Int
    @Binding var dailyMinutes: Int
    @Binding var remindersEnabled: Bool
    @Binding var preferredStudyTime: Date
    let availability: AIModelAvailability
    let isGenerating: Bool
    let onGenerate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("AI Study Plan", systemImage: "apple.intelligence")
                .font(.headline)
                .foregroundStyle(PlanTheme.text)

            Stepper("Plan duration: \(durationDays) days", value: $durationDays, in: 1...30)
            Stepper("Daily study: \(dailyMinutes) minutes", value: $dailyMinutes, in: 15...180, step: 15)

            Toggle("Daily study reminders", isOn: $remindersEnabled)
                .tint(PlanTheme.deepClay)

            if remindersEnabled {
                DatePicker(
                    "Preferred study time",
                    selection: $preferredStudyTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(availability == .available ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)

                Text(availability.message)
                    .font(.caption)
                    .foregroundStyle(PlanTheme.text.opacity(0.7))
            }

            Button(action: onGenerate) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isGenerating ? "Creating Plan…" : "Generate Study Plan")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(PlanTheme.deepClay, in: Capsule())
            }
            .disabled(availability != .available || isGenerating)
            .opacity(availability == .available ? 1 : 0.55)
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct GeneratedPlanDraftView: View {
    let draft: GeneratedStudyPlanDraft
    let didSave: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Generated Plan Draft", systemImage: "checklist")
                .font(.headline)
                .foregroundStyle(PlanTheme.text)

            Text(draft.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(PlanTheme.text)

            Text(draft.summary)
                .font(.subheadline)
                .foregroundStyle(PlanTheme.text.opacity(0.75))

            ForEach(Array(draft.tasks.enumerated()), id: \.offset) { index, task in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(PlanTheme.deepClay, in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.subheadline.weight(.semibold))
                        Text(task.concept)
                            .font(.caption)
                            .foregroundStyle(PlanTheme.text.opacity(0.65))
                        Text("\(task.estimatedMinutes) min")
                            .font(.caption2)
                            .foregroundStyle(PlanTheme.mauve)
                    }
                }
                .foregroundStyle(PlanTheme.text)
            }

            if didSave {
                Label("Added automatically to Tasks", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(PlanTheme.deepClay)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(PlanTheme.controlBackground, in: Capsule())
            }
        }
        .padding(18)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }
}

extension AIModelAvailability {
    var message: LocalizedStringKey {
        switch self {
        case .available:
            "On-device AI is ready"
        case .appleIntelligenceDisabled:
            "Apple Intelligence is disabled"
        case .deviceNotEligible:
            "This device does not support on-device AI"
        case .modelNotReady:
            "The on-device model is still preparing"
        case .unsupportedLanguage:
            "The current language is not supported"
        case .unavailable:
            "On-device AI is unavailable"
        }
    }
}

#Preview {
    ZStack {
        PlanTheme.background.ignoresSafeArea()
        StudyMaterialImportView(viewModel: AppDependencies().planViewModel)
    }
}
