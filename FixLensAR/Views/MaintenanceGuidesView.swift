import SwiftUI

struct MaintenanceGuidesView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = MaintenanceGuidesViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Maintenance Guides",
                    subtitle: "Step-by-step guidance stays routine, cautious, and homeowner-friendly.",
                    icon: "list.clipboard"
                )

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Appliance")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Picker("Appliance", selection: $viewModel.selectedType) {
                            ForEach(ApplianceType.allCases.filter { $0 != .unknown }) { type in
                                Label(type.displayName, systemImage: type.symbolName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }
                }

                if viewModel.isLoading {
                    LoadingStateView(title: "Generating maintenance guides")
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                }

                ForEach(viewModel.guides) { guide in
                    MaintenanceGuideDetailCard(guide: guide)
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Guides")
        .task(id: viewModel.selectedType) {
            await viewModel.load(service: services.maintenanceGuides)
        }
    }
}

private struct MaintenanceGuideDetailCard: View {
    let guide: MaintenanceGuide

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(guide.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(guide.estimatedTimeMinutes) min • \(guide.difficulty.rawValue)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FixLensTheme.emerald)
                    }
                    Spacer()
                    Image(systemName: guide.applianceType.symbolName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(FixLensTheme.electricBlue)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Required tools")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(guide.requiredTools.joined(separator: " • "))
                        .font(.caption)
                        .foregroundStyle(FixLensTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.black)
                                .frame(width: 24, height: 24)
                                .background(FixLensTheme.emerald, in: Circle())
                            Text(step)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.86))
                        }
                    }
                }

                SafetyBanner(title: "Guide safety notes", warnings: guide.safetyWarnings)
            }
        }
    }
}
