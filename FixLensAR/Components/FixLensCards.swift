import Charts
import SwiftUI
import UIKit

struct ApplianceCard: View {
    let appliance: Appliance

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(FixLensTheme.electricBlue.opacity(0.18))
                Image(systemName: appliance.applianceType.symbolName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(FixLensTheme.electricBlue)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 6) {
                Text(appliance.applianceType.displayName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(appliance.modelPlaceholder)
                    .font(.caption)
                    .foregroundStyle(FixLensTheme.secondaryText)
                Text("Added \(appliance.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer(minLength: 0)
            HealthScoreRing(score: appliance.healthScore, size: 58)
        }
        .padding(16)
        .glassPanel(cornerRadius: 20)
    }
}

struct ARGuideCard: View {
    let step: ARInstructionStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step.number)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .background(step.isWarningZone ? FixLensTheme.warning : FixLensTheme.emerald, in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(step.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(step.detail)
                    .font(.caption)
                    .foregroundStyle(FixLensTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(FixLensTheme.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct HealthScoreRing: View {
    let score: Int
    var size: CGFloat = 72

    private var progress: Double {
        min(1, max(0, Double(score) / 100))
    }

    private var color: Color {
        if score >= 80 { return FixLensTheme.emerald }
        if score >= 60 { return FixLensTheme.warning }
        return FixLensTheme.danger
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("%")
                    .font(.system(size: size * 0.14, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Health score \(score) percent")
    }
}

struct MaintenanceTaskCard: View {
    let task: MaintenanceTask
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(task.completed ? FixLensTheme.emerald : FixLensTheme.electricBlue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .strikethrough(task.completed)
                    Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(FixLensTheme.secondaryText)
                }

                Spacer(minLength: 0)

                Text(task.safetyLevel.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(task.safetyLevel == .professionalOnly ? FixLensTheme.warning : FixLensTheme.emerald)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08), in: Capsule())
            }
            .padding(14)
            .background(FixLensTheme.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ErrorCodeCard: View {
    let result: ErrorCodeResult

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(result.code, systemImage: "text.viewfinder")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("OCR")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FixLensTheme.electricBlue)
            }

            Text(result.explanation)
                .font(.subheadline)
                .foregroundStyle(FixLensTheme.secondaryText)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(result.troubleshootingSteps, id: \.self) { step in
                    Label(step, systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
        }
        .padding(16)
        .glassPanel(cornerRadius: 20)
    }
}

struct VoiceWaveformView: View {
    let samples: [CGFloat]
    var tint: Color = FixLensTheme.electricBlue

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(samples.indices, id: \.self) { index in
                Capsule()
                    .fill(index.isMultiple(of: 5) ? FixLensTheme.emerald : tint)
                    .frame(width: 4, height: max(8, samples[index] * 76))
                    .animation(.smooth(duration: 0.18), value: samples[index])
            }
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .padding(.horizontal, 8)
    }
}

struct AnalyticsChartDatum: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Int
}

struct AnalyticsChartCard: View {
    let data: [AnalyticsChartDatum]
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Chart(data) { item in
                BarMark(
                    x: .value("Item", item.label),
                    y: .value("Score", item.value)
                )
                .foregroundStyle(
                    LinearGradient(colors: [FixLensTheme.electricBlue, FixLensTheme.emerald], startPoint: .bottom, endPoint: .top)
                )
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 190)
        }
        .padding(16)
        .glassPanel(cornerRadius: 20)
    }
}

struct ReportPreviewView: View {
    let title: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "doc.richtext")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            ForEach(rows, id: \.self) { row in
                Text(row)
                    .font(.caption)
                    .foregroundStyle(FixLensTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassPanel(cornerRadius: 20)
    }
}

struct UpgradeBanner: View {
    let plan: SubscriptionPlan

    var body: some View {
        NavigationLink(value: AppRoute.paywall) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FixLensTheme.emerald)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock \(plan.displayName)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(plan.features.prefix(3).joined(separator: " • "))
                        .font(.caption)
                        .foregroundStyle(FixLensTheme.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(16)
            .background(FixLensTheme.electricBlue.opacity(0.14), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(FixLensTheme.electricBlue.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
