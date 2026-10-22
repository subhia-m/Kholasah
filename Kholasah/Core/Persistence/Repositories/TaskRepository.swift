import Foundation

@MainActor
protocol TaskRepository: AnyObject {
    var tasks: [StudyTask] { get }
    func add(_ task: StudyTask)
    func update(_ task: StudyTask)
    func remove(id: StudyTask.ID)
}
