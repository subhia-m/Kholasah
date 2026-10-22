import SwiftUI

struct RemindersView: View {
    var body: some View {
        ContentUnavailableView(
            "No Reminders",
            systemImage: "bell",
            description: Text("Reminder scheduling will be connected through NotificationService later.")
        )
        .navigationTitle("Reminders")
    }
}
