import SwiftData
import SwiftUI

struct ApplianceHealthDashboardView: View {
    @Query(sort: \Appliance.createdAt, order: .reverse) private var appliances: [Appliance]
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]

    private var healthData: [AnalyticsChartDatum] {
        appliances.map { AnalyticsChartDatum(label: $0.applianceType.displayName, value: $0.healthScore) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Appliance Health",
                    subtitle: "Maintenance frequency, service reminders, age, health score, and risk signals.",
                    icon: "waveform.path.ecg.rectangle"
                )

                if appliances.isEmpty {
                    EmptyStateView(title: "No health data", message: "Scan appliances to build a maintenance health profile.", systemImage: "heart.text.square")
                } else {
                    AnalyticsChartCard(data: healthData, title: "Health score by appliance")

                    ForEach(appliances) { appliance in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label(appliance.applianceType.displayName, systemImage: appliance.applianceType.symbolName)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    HealthScoreRing(score: appliance.healthScore, size: 64)
                                }

                                let relatedTasks = tasks.filter { $0.applianceId == appliance.id }
                                MetricPill(title: "Maintenance records", value: "\(relatedTasks.count)", icon: "folder.badge.gearshape", tint: FixLensTheme.emerald)

                                Text(SafetyPolicy.safeActionSummary(for: appliance.applianceType))
                                    .font(.caption)
                                    .foregroundStyle(FixLensTheme.secondaryText)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Health")
    }
}
