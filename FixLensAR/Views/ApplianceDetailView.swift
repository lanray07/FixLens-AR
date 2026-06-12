import SwiftData
import SwiftUI

struct ApplianceDetailView: View {
    let applianceID: UUID
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appliance.createdAt, order: .reverse) private var appliances: [Appliance]
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]
    @Query(sort: \ScanResult.createdAt, order: .reverse) private var scans: [ScanResult]

    private var appliance: Appliance? {
        appliances.first { $0.id == applianceID }
    }

    private var applianceTasks: [MaintenanceTask] {
        tasks.filter { $0.applianceId == applianceID }
    }

    private var applianceScans: [ScanResult] {
        scans.filter { $0.applianceId == applianceID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if let appliance {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label(appliance.applianceType.displayName, systemImage: appliance.applianceType.symbolName)
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                HealthScoreRing(score: appliance.healthScore, size: 76)
                            }

                            Text(appliance.modelPlaceholder)
                                .font(.subheadline)
                                .foregroundStyle(FixLensTheme.secondaryText)

                            NavigationLink(value: AppRoute.arGuide(appliance.applianceType)) {
                                Label("Visualize AR maintenance steps", systemImage: "arkit")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(FixLensTheme.emerald, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    SafetyBanner(title: "Appliance safety", warnings: SafetyPolicy.warnings(for: appliance.applianceType))

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Maintenance tasks", icon: "checklist")
                        if applianceTasks.isEmpty {
                            EmptyStateView(title: "No tasks", message: "Scanner recommendations and guides will create tasks here.", systemImage: "checklist")
                        } else {
                            ForEach(applianceTasks) { task in
                                MaintenanceTaskCard(task: task) {
                                    task.completed.toggle()
                                    task.completedAt = task.completed ? .now : nil
                                    try? modelContext.save()
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Recent scans", icon: "clock.arrow.circlepath")
                        ForEach(applianceScans.prefix(5)) { scan in
                            ReportPreviewView(title: scan.applianceType.displayName, rows: scan.identifiedComponents + [
                                "Confidence \(Int(scan.confidence * 100))%",
                                scan.createdAt.formatted(date: .abbreviated, time: .shortened)
                            ])
                        }
                    }
                } else {
                    EmptyStateView(title: "Appliance not found", message: "This appliance record may have been deleted.", systemImage: "exclamationmark.magnifyingglass")
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Appliance")
    }
}
