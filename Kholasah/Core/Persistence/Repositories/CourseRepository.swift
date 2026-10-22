import Foundation

@MainActor
protocol CourseRepository: AnyObject {
    var courses: [Course] { get }
    func add(_ course: Course)
    func update(_ course: Course)
    func remove(id: Course.ID)
}
