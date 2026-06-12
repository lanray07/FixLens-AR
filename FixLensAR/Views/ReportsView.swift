import SwiftData
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appliance.createdAt, order: .reverse) private var appliances: [Appliance]
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]
    @Query(sort: \MaintenanceReport.createdAt, order: .reverse) private var reports: [MaintenanceReport]
    @StateObject private var viewModel = ReportsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "PDF Reports",
                    subtitle: "Export appliance reports, maintenance history, property summaries, and service logs.",
                    icon: "doc.richtext"
                )

                ReportPreviewView(title: "Preview", rows: [
                    "\(appliances.count) appliances",
                    "\(tasks.filter { !$0.completed }.count) open tasks",
                    "\(reports.count) generated reports",
                    SafetyPolicy.educationalDisclaimer
                ])

                PrimaryActionButton(title: "Export Property Report", systemImage: "square.and.arrow.up", isLoading: viewModel.isExporting) {
                    viewModel.export(appliances: appliances, tasks: tasks, context: modelContext, pdfService: services.pdfReports)
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Recent reports")
                    if reports.isEmpty {
                        EmptyStateView(title: "No reports yet", message: "Export a report to create your first service log.", systemImage: "doc.badge.plus")
                    } else {
                        ForEach(reports) { report in
                            ReportPreviewView(title: report.reportType, rows: [
                                report.createdAt.formatted(date: .abbreviated, time: .shortened),
                                report.generatedFilePath ?? "Stored in FixLens AR"
                            ])
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Reports")
        .sheet(item: $viewModel.sharePayload) { payload in
            ShareSheet(activityItems: [payload.url])
        }
    }
}
