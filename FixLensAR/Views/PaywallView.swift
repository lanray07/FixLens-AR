import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore

    private let premiumPlans: [SubscriptionPlan] = [.proMonthly, .proYearly, .propertyProMonthly]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("FixLens Pro")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Unlimited scans, AR overlays, voice guidance, appliance history, maintenance calendar, and property reports.")
                        .font(.subheadline)
                        .foregroundStyle(FixLensTheme.secondaryText)
                }

                ForEach(premiumPlans) { plan in
                    PlanCard(plan: plan, product: subscriptionStore.product(for: plan)) {
                        if let product = subscriptionStore.product(for: plan) {
                            Task { await subscriptionStore.purchase(product) }
                        } else {
                            subscriptionStore.activatePreviewPlan(plan)
                        }
                    }
                }

                if let message = subscriptionStore.lastErrorMessage {
                    ErrorStateView(message: message)
                }

                SafetyBanner(title: "Subscription note", warnings: [
                    "Pricing is placeholder until App Store Connect products are configured.",
                    "The app uses StoreKit 2 scaffolding and preview activation for development builds."
                ])
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Upgrade")
        .task {
            await subscriptionStore.loadProducts()
        }
    }
}

private struct PlanCard: View {
    let plan: SubscriptionPlan
    let product: Product?
    let action: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.displayName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text(product?.displayPrice ?? plan.pricePlaceholder)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(FixLensTheme.emerald)
                    }
                    Spacer()
                    Image(systemName: plan == .propertyProMonthly ? "building.2.fill" : "sparkles")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(FixLensTheme.electricBlue)
                }

                ForEach(plan.features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Button(action: action) {
                    Text(product == nil ? "Activate Preview" : "Subscribe")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(FixLensTheme.emerald, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
