import SwiftData
import SwiftUI

struct MaintenanceCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]

    private var upcoming: [MaintenanceTask] {
        tasks.filter { !$0.completed }
    }

    private var completed: [MaintenanceTask] {
        tasks.filter { $0.completed }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Maintenance Calendar",
                    subtitle: "Boiler checks, filter changes, seasonal tasks, inspections, and reminders.",
                    icon: "calendar"
                )

                if tasks.isEmpty {
                    EmptyStateView(title: "No scheduled tasks", message: "Scan an appliance or create a maintenance guide to seed reminders.", systemImage: "calendar.badge.plus")
                } else {
                    taskSection(title: "Upcoming", tasks: upcoming)
                    taskSection(title: "Completed", tasks: completed)
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Calendar")
    }

    private func taskSection(title: String, tasks: [MaintenanceTask]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            if tasks.isEmpty {
                EmptyStateView(title: "Nothing here", message: "Tasks will appear as your maintenance plan evolves.", systemImage: "checkmark.circle")
            } else {
                ForEach(tasks) { task in
                    MaintenanceTaskCard(task: task) {
                        toggle(task)
                    }
                }
            }
        }
    }

    private func toggle(_ task: MaintenanceTask) {
        task.completed.toggle()
        task.completedAt = task.completed ? .now : nil
        if !task.completed {
            Task { await services.notifications.scheduleReminder(for: task) }
        }
        try? modelContext.save()
    }
}
