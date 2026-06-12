import Foundation
import WidgetKit

struct FixLensWidgetSnapshotData: Hashable {
    let title: String
    let subtitle: String
    let healthScore: Int
    let nextDueDate: Date
}

enum FixLensWidgetPlaceholder {
    static let supportedWidgets = [
        "Maintenance reminder",
        "Appliance health",
        "Upcoming task"
    ]

    static func reloadTimelinesWhenExtensionExists() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
