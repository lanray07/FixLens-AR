import SwiftData
import SwiftUI

struct PropertyPortfolioView: View {
    @Query(sort: \HomeProfile.createdAt, order: .forward) private var profiles: [HomeProfile]
    @Query(sort: \Appliance.createdAt, order: .reverse) private var appliances: [Appliance]
    @Query(sort: \MaintenanceReport.createdAt, order: .reverse) private var reports: [MaintenanceReport]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Property Portfolio",
                    subtitle: "Placeholder for landlords, Airbnb hosts, and property managers.",
                    icon: "building.2.crop.circle"
                )

                if let profile = profiles.first {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(profile.propertyType.rawValue)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                            Text(profile.homeownerRole.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(FixLensTheme.emerald)
                            Text(profile.goals.map(\.rawValue).joined(separator: " • "))
                                .font(.caption)
                                .foregroundStyle(FixLensTheme.secondaryText)
                        }
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricPill(title: "Properties", value: "1", icon: "house.lodge", tint: FixLensTheme.electricBlue)
                    MetricPill(title: "Appliances", value: "\(appliances.count)", icon: "shippingbox", tint: FixLensTheme.emerald)
                    MetricPill(title: "Reports", value: "\(reports.count)", icon: "doc.richtext", tint: FixLensTheme.warning)
                    MetricPill(title: "Portfolio", value: "Ready", icon: "folder", tint: .cyan)
                }

                SafetyBanner(title: "Portfolio safety", warnings: [
                    "Landlord and property records are informational only.",
                    "Regulatory inspections, gas safety checks, electrical certification, and professional servicing must be handled by qualified professionals."
                ])
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Portfolio")
    }
}
