import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var services: AppServices
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Query(sort: \Appliance.createdAt, order: .reverse) private var appliances: [Appliance]
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]
    @Query(sort: \ScanResult.createdAt, order: .reverse) private var scans: [ScanResult]
    @StateObject private var viewModel = DashboardViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var averageHealth: Int {
        guard !appliances.isEmpty else { return 0 }
        return appliances.map(\.healthScore).reduce(0, +) / appliances.count
    }

    private var openTasks: [MaintenanceTask] {
        tasks.filter { !$0.completed }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                if !subscriptionStore.isPro {
                    UpgradeBanner(plan: .proMonthly)
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    MetricPill(title: "Appliances", value: "\(appliances.count)", icon: "shippingbox", tint: FixLensTheme.electricBlue)
                    MetricPill(title: "Health", value: "\(averageHealth)%", icon: "waveform.path.ecg", tint: FixLensTheme.emerald)
                    MetricPill(title: "Open Tasks", value: "\(openTasks.count)", icon: "calendar.badge.clock", tint: FixLensTheme.warning)
                    MetricPill(title: "Recent Scans", value: "\(scans.prefix(7).count)", icon: "viewfinder", tint: .cyan)
                }

                quickActions

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Appliances", subtitle: "Health, reminders, and recent scan intelligence.", icon: "sensor.tag.radiowaves.forward")
                    if appliances.isEmpty {
                        EmptyStateView(title: "No appliances yet", message: "Scan an appliance to create your first maintenance profile.", systemImage: "camera.viewfinder")
                    } else {
                        ForEach(appliances.prefix(4)) { appliance in
                            NavigationLink(value: AppRoute.appliance(appliance.id)) {
                                ApplianceCard(appliance: appliance)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "AI Insights", subtitle: "Mock AI is enabled by default for offline-friendly guidance.", icon: "brain.head.profile")
                    if viewModel.isLoadingInsights {
                        LoadingStateView(title: "Analyzing appliance health")
                    } else if viewModel.insights.isEmpty {
                        EmptyStateView(title: "Insights are warming up", message: "Add appliances and maintenance tasks to generate risk signals.", systemImage: "sparkles")
                    } else {
                        ForEach(Array(viewModel.insights.prefix(3))) { insight in
                            InsightRow(insight: insight)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("FixLens AR")
        .task(id: appliances.count + tasks.count) {
            await viewModel.refresh(appliances: appliances, tasks: tasks, service: services.applianceHealth)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Home Maintenance Intelligence")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Scan appliances, visualize safe maintenance steps, and keep your property records clean.")
                .font(.subheadline)
                .foregroundStyle(FixLensTheme.secondaryText)
            Text("Subscription: \(subscriptionStore.activePlan.displayName)")
                .font(.caption.weight(.bold))
                .foregroundStyle(subscriptionStore.isPro ? FixLensTheme.emerald : FixLensTheme.warning)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick actions", icon: "bolt.circle")
            LazyVGrid(columns: columns, spacing: 12) {
                QuickActionTile(title: "Scan Appliance", icon: "camera.viewfinder", route: .scanner)
                QuickActionTile(title: "AR Guide", icon: "arkit", route: .arGuide(.washingMachine))
                QuickActionTile(title: "Maintenance Check", icon: "checklist", route: .guides)
                QuickActionTile(title: "Appliance History", icon: "clock.arrow.circlepath", route: .health)
                QuickActionTile(title: "Troubleshoot", icon: "wrench.and.screwdriver", route: .troubleshooter)
                QuickActionTile(title: "Voice Assistant", icon: "waveform", route: .voice)
            }
        }
    }
}

private struct QuickActionTile: View {
    let title: String
    let icon: String
    let route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(FixLensTheme.electricBlue)
                    .frame(width: 36, height: 36)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct InsightRow: View {
    let insight: HealthInsight

    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                HealthScoreRing(score: insight.healthScore, size: 58)
                VStack(alignment: .leading, spacing: 6) {
                    Text(insight.applianceName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(insight.insight)
                        .font(.caption)
                        .foregroundStyle(FixLensTheme.secondaryText)
                    Text(insight.nextAction)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FixLensTheme.emerald)
                }
                Spacer()
            }
        }
    }
}
