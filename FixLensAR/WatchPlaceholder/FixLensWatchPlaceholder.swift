import Foundation

struct WatchMaintenanceAlertPayload: Hashable {
    let applianceName: String
    let taskTitle: String
    let dueDate: Date
}

enum FixLensWatchPlaceholder {
    static let plannedCapabilities = [
        "Maintenance alerts",
        "Task reminders",
        "Quick inspections"
    ]
}
