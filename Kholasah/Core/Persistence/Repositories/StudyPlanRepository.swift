import Foundation

@MainActor
protocol StudyPlanRepository: AnyObject {
    var plans: [StudyPlan] { get }
    func save(_ plan: StudyPlan)
    func remove(id: StudyPlan.ID)
}
