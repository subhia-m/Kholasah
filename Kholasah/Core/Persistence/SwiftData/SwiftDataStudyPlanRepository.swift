import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SwiftDataStudyPlanRepository: StudyPlanRepository {
    private(set) var plans: [StudyPlan] = []
    @ObservationIgnored private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        reload()
    }

    func save(_ plan: StudyPlan) {
        if let entity = entities().first(where: { $0.id == plan.id }) {
            entity.update(from: plan)
        } else {
            modelContext.insert(StudyPlanEntity(plan: plan))
        }
        saveAndReload()
    }

    func remove(id: StudyPlan.ID) {
        guard let entity = entities().first(where: { $0.id == id }) else { return }
        modelContext.delete(entity)
        saveAndReload()
    }

    private func entities() -> [StudyPlanEntity] {
        (try? modelContext.fetch(FetchDescriptor<StudyPlanEntity>())) ?? []
    }

    private func reload() {
        plans = entities().map(\.domainModel)
    }

    private func saveAndReload() {
        try? modelContext.save()
        reload()
    }
}
