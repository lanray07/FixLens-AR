import SwiftUI

struct ARGuideView: View {
    let applianceType: ApplianceType
    @StateObject private var engine = AROverlayEngine()

    init(applianceType: ApplianceType = .washingMachine) {
        self.applianceType = applianceType
    }

    var body: some View {
        ZStack {
            ARMaintenanceView(engine: engine, applianceType: applianceType)
                .ignoresSafeArea()

            LinearGradient(colors: [.black.opacity(0.72), .clear, .black.opacity(0.78)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                topOverlay
                Spacer()
                bottomOverlay
            }
            .padding(18)
        }
        .navigationTitle("AR Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var topOverlay: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label(applianceType.displayName, systemImage: applianceType.symbolName)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(engine.trackingState)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FixLensTheme.emerald)
                }

                Text(ApplianceTrackingEngine().trackingHint(for: applianceType))
                    .font(.caption)
                    .foregroundStyle(FixLensTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var bottomOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            if applianceType.isHighRisk {
                SafetyBanner(title: "Stop before unsafe work", warnings: SafetyPolicy.warnings(for: applianceType))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(engine.instructionSteps) { step in
                        ARGuideCard(step: step)
                            .frame(width: 290)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
