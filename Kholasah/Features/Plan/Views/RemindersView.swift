// MARK:

import SwiftUI

// MARK: - Reminders page

struct RemindersView: View {
   
    var courseTitle: String = "Plan"
    
    @Binding var selection: PlanScreenTab
    var onBack: (() -> Void)? = nil
   
    var reminders: [PlanReminderItem]
    
    var onAdd: (String, Date) -> Void
   
    var onSetEnabled: (PlanReminderItem, Bool) -> Void
   
    var onDelete: (PlanReminderItem) -> Void

    @State private var showingAddSheet = false

    var body: some View {
        PlanPageScaffold(title: courseTitle, selection: $selection, onBack: onBack) {
            content
        }
    }

  
    private var content: some View {
        
        VStack(spacing: 0) {
            
            PlanCard {
                HStack {
                    Spacer()
                    PlanAddButton(label: "Add reminder") { showingAddSheet = true }
                }
               
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 17)
                
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
            .padding(.top, 16)

        }
        .sheet(isPresented: $showingAddSheet) {
            PlanAddReminderSheet { title, date in
                withAnimation { onAdd(title, date) }
            }
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }

    
    private var emptyState: some View {
        VStack(spacing: 6) {
            Spacer()
            Text("No reminders yet")
                .font(AppTypography.headline)
            Text("Tap + to add one.")
                .font(AppTypography.caption)
                .opacity(0.6)
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
       
        .frame(maxWidth: .infinity)
    }
    private var reminderList: some View {
        List {
            
            ForEach(reminders) { reminder in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .font(AppTypography.headline)
                        Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTypography.caption)
                            .opacity(0.6)
                    }
                    .foregroundStyle(PlanTheme.text)
                    .opacity(reminder.isOn ? 1 : 0.5)

                    Spacer()

                    Toggle("Reminder on", isOn: Binding(
                        get: { reminder.isOn },
                        set: { onSetEnabled(reminder, $0) }
                    ))
                    .labelsHidden()
                    .tint(PlanTheme.deepClay)
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(PlanTheme.text.opacity(0.12))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    
                    Button(role: .destructive) {
                        withAnimation { onDelete(reminder) }
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
                .font(AppTypography.title)
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
                    .font(AppTypography.body)
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button("Add") {
                    
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed, date)
                    dismiss()
                }
                .font(AppTypography.button)
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
    NavigationStack {
        CourseFlowView(course: Course(title: "Plan"), showsBackButton: true, startingAt: .reminders)
    }
}
