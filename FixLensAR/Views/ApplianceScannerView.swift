import SwiftData
import SwiftUI

struct ApplianceScannerView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ScannerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Appliance Scanner",
                    subtitle: "Computer-vision architecture with mock AI enabled by default.",
                    icon: "camera.viewfinder"
                )

                ScannerPortalView(isScanning: viewModel.isScanning)

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Scan context")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        TextField("e.g. dishwasher with E24 display", text: $viewModel.scanContext)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        PrimaryActionButton(title: "Identify Appliance", systemImage: "sparkles", isLoading: viewModel.isScanning) {
                            Task {
                                await viewModel.performScan(context: modelContext, service: services.applianceRecognition)
                            }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                }

                if let result = viewModel.result {
                    scanResult(result)
                } else {
                    EmptyStateView(title: "Ready to scan", message: "Point the camera at a visible model label, control area, filter area, or appliance front.", systemImage: "viewfinder")
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Scan")
    }

    private func scanResult(_ result: ApplianceRecognitionResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label(result.applianceType.displayName, systemImage: result.applianceType.symbolName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(result.confidence * 100))%")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(FixLensTheme.emerald)
                    }

                    Text(result.maintenanceStatus)
                        .font(.subheadline)
                        .foregroundStyle(FixLensTheme.secondaryText)

                    HealthScoreRing(score: result.healthScore, size: 92)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Identified components")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                        ForEach(result.identifiedComponents, id: \.self) { component in
                            Label(component, systemImage: "target")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.82))
                        }
                    }

                    NavigationLink(value: AppRoute.arGuide(result.applianceType)) {
                        Label("Open AR Guide", systemImage: "arkit")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(FixLensTheme.emerald, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            SafetyBanner(title: "Scan safety guidance", warnings: result.warnings)
        }
    }
}

private struct ScannerPortalView: View {
    let isScanning: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.black.opacity(0.45))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(FixLensTheme.electricBlue.opacity(0.42), lineWidth: 1.4)
                }

            VStack(spacing: 18) {
                Image(systemName: "camera.metering.matrix")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(FixLensTheme.electricBlue)
                Text(isScanning ? "Analyzing appliance surfaces" : "Camera scanner ready")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Live capture can be wired to AVCapture and Vision; mock recognition keeps the app runnable immediately.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(FixLensTheme.secondaryText)
                    .padding(.horizontal)
            }

            ReticleShape()
                .stroke(FixLensTheme.emerald.opacity(isScanning ? 0.9 : 0.55), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 220, height: 220)
                .scaleEffect(isScanning ? 1.08 : 1)
                .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isScanning)
        }
        .frame(height: 330)
    }
}

private struct ReticleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 42
        let corners = [
            (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX + length, y: rect.minY), CGPoint(x: rect.minX, y: rect.minY + length)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX - length, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY + length)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX + length, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY - length)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.maxX - length, y: rect.maxY), CGPoint(x: rect.maxX, y: rect.maxY - length))
        ]

        for corner in corners {
            path.move(to: corner.0)
            path.addLine(to: corner.1)
            path.move(to: corner.0)
            path.addLine(to: corner.2)
        }

        return path
    }
}
