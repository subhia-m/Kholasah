import Foundation
import Observation

@MainActor
@Observable
final class PlanViewModel {
    @ObservationIgnored
    private let service: StudyPlanService
    @ObservationIgnored
    private let fileImportService: any FileImportService
    @ObservationIgnored
    private let aiService: any AIService
    @ObservationIgnored
    private let notificationService: any NotificationService

    private(set) var importedMaterial: ImportedCourseMaterial?
    private(set) var isImportingMaterial = false
    var materialImportError: String?
    private(set) var generatedPlanDraft: GeneratedStudyPlanDraft?
    private(set) var isGeneratingPlan = false
    private(set) var didSaveGeneratedPlan = false
    var planGenerationError: String?
    var notificationError: String?
    private(set) var scheduledReminderCount = 0

    var aiAvailability: AIModelAvailability {
        aiService.availability
    }

    convenience init(service: StudyPlanService) {
        self.init(
            service: service,
            fileImportService: PDFFileImportService(),
            aiService: LocalFoundationModelsAIService(),
            notificationService: LocalNotificationService()
        )
    }

    init(
        service: StudyPlanService,
        fileImportService: any FileImportService,
        aiService: any AIService,
        notificationService: any NotificationService
    ) {
        self.service = service
        self.fileImportService = fileImportService
        self.aiService = aiService
        self.notificationService = notificationService
    }

    var courses: [Course] {
        service.courses
    }

    var tasks: [StudyTask] {
        service.tasks
    }

    var completionProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isCompleted).count) / Double(tasks.count)
    }

    func addTask(title: String, courseID: Course.ID?) {
        service.addTask(title: title, courseID: courseID)
    }

    func replaceTaskItems(_ items: [PlanTaskItem]) {
        service.replaceTaskItems(items)
    }

    func toggleTask(_ task: StudyTask) {
        service.toggleTask(task)
    }

    func importStudyMaterial(from url: URL) async {
        isImportingMaterial = true
        materialImportError = nil

        do {
            importedMaterial = try await fileImportService.importCourseMaterial(from: url)
        } catch {
            importedMaterial = nil
            materialImportError = error.localizedDescription
        }

        isImportingMaterial = false
    }

    func removeImportedMaterial() {
        importedMaterial = nil
        materialImportError = nil
        generatedPlanDraft = nil
        didSaveGeneratedPlan = false
    }

    func generateStudyPlan(
        durationDays: Int,
        dailyMinutes: Int,
        remindersEnabled: Bool,
        preferredStudyTime: Date
    ) async {
        guard let importedMaterial else { return }

        isGeneratingPlan = true
        didSaveGeneratedPlan = false
        planGenerationError = nil
        notificationError = nil
        scheduledReminderCount = 0

        do {
            let draft = try await aiService.generateStudyPlan(
                material: importedMaterial,
                durationDays: durationDays,
                dailyMinutes: dailyMinutes
            )
            generatedPlanDraft = draft
            let plan = service.saveGeneratedPlan(
                draft,
                courseID: nil,
                durationDays: durationDays,
                dailyMinutes: dailyMinutes,
                preferredStudyTime: preferredStudyTime
            )
            didSaveGeneratedPlan = true

            if remindersEnabled {
                await scheduleReminders(for: plan)
            } else {
                await notificationService.cancelStudyReminders()
            }
        } catch {
            generatedPlanDraft = nil
            planGenerationError = error.localizedDescription
        }

        isGeneratingPlan = false
    }

    private func scheduleReminders(for plan: StudyPlan) async {
        do {
            guard try await notificationService.requestAuthorization() else {
                throw NotificationServiceError.permissionDenied
            }

            await notificationService.cancelStudyReminders()
            let planTasks = tasks.filter { plan.taskIDs.contains($0.id) }
            for task in planTasks {
                try await notificationService.scheduleReminder(for: task)
            }
            scheduledReminderCount = planTasks.count
        } catch {
            notificationError = error.localizedDescription
        }
    }

    func saveGeneratedPlan(
        courseID: Course.ID?,
        durationDays: Int,
        dailyMinutes: Int
    ) {
        guard let generatedPlanDraft else { return }

        service.saveGeneratedPlan(
            generatedPlanDraft,
            courseID: courseID,
            durationDays: durationDays,
            dailyMinutes: dailyMinutes
        )
        didSaveGeneratedPlan = true
    }
}
