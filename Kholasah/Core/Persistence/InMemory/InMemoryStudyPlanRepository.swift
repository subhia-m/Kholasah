import Foundation
import Observation

@MainActor
@Observable
final class InMemoryStudyPlanRepository: StudyPlanRepository {
    private(set) var plans: [StudyPlan]

    init(plans: [StudyPlan] = []) {
        self.plans = plans
    }

    func save(_ plan: StudyPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
        } else {
            plans.append(plan)
        }
    }

    func remove(id: StudyPlan.ID) {
        plans.removeAll { $0.id == id }
    }
}
