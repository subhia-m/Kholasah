import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @State private var dependencies: AppDependencies
    private let modelContainer: ModelContainer

    init() {
        do {
            let container = try ModelContainer(
                for: CourseEntity.self,
                StudyTaskEntity.self,
                StudyPlanEntity.self,
                PlanReminderEntity.self
            )
            modelContainer = container
            _dependencies = State(initialValue: AppDependencies(modelContainer: container))
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
                .modelContainer(modelContainer)
        }
    }
}
