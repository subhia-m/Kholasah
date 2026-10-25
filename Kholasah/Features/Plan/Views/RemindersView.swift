import SwiftUI

// MARK: - Model (kept in this file so it can't clash with shared models)

struct PlanReminderItem: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var date: Date
    var isOn: Bool = true
}

// MARK: - Reminders tab

struct RemindersView: View {
    @Binding var reminders: [PlanReminderItem]
    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                PlanAddButton(label: "Add reminder") { showingAddSheet = true }
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 12)

            PlanCard {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundStyle(PlanTheme.text)
                        .padding(.horizontal, 18)
                        .padding(.top, 16)

                    if reminders.isEmpty {
                        emptyState
                    } else {
                        reminderList
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showingAddSheet) {
            PlanAddReminderSheet { title, date in
                withAnimation {
                    reminders.append(PlanReminderItem(title: title, date: date))
                    reminders.sort { $0.date < $1.date }
                }
            }
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Spacer()
            Text("No reminders yet")
                .font(.system(size: 16, weight: .medium))
            Text("Tap + to add one.")
                .font(.system(size: 13))
                .opacity(0.6)
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
        .frame(maxWidth: .infinity)
    }

    private var reminderList: some View {
        List {
            ForEach($reminders) { $reminder in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .font(.system(size: 18))
                        Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 12))
                            .opacity(0.6)
                    }
                    .foregroundStyle(PlanTheme.text)
                    .opacity(reminder.isOn ? 1 : 0.5)

                    Spacer()

                    Toggle("Reminder on", isOn: $reminder.isOn)
                        .labelsHidden()
                        .tint(PlanTheme.deepClay)
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(PlanTheme.text.opacity(0.12))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation { reminders.removeAll { $0.id == reminder.id } }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Add sheet

private struct PlanAddReminderSheet: View {
    let onAdd: (String, Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Date().addingTimeInterval(3600)
    @FocusState private var isFocused: Bool

    private var trimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Reminder")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(PlanTheme.text)

            TextField("Remind me to...", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            DatePicker("When", selection: $date,
                       displayedComponents: [.date, .hourAndMinute])
                .tint(PlanTheme.deepClay)
                .foregroundStyle(PlanTheme.text)

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .font(.system(size: 16))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button("Add") {
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed, date)
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(PlanTheme.deepClay))
                .opacity(trimmed.isEmpty ? 0.4 : 1)
                .disabled(trimmed.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .background(PlanTheme.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }
}

#Preview {
    ZStack {
        PlanTheme.background.ignoresSafeArea()
        RemindersView(reminders: .constant([
            PlanReminderItem(title: "practice", date: Date().addingTimeInterval(3600))
        ]))
    }
}
