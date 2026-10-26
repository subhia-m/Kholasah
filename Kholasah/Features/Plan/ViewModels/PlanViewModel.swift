import Foundation
import Observation

@MainActor
@Observable
final class PlanViewModel {
    @ObservationIgnored
    private let service: StudyPlanService

    init(service: StudyPlanService) {
        self.service = service
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
}
