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

                if subscriptionStore.isLoading && subscriptionStore.products.isEmpty {
                    LoadingStateView(title: "Loading subscriptions")
                }

                ForEach(premiumPlans) { plan in
                    PlanCard(plan: plan, product: subscriptionStore.product(for: plan), isLoading: subscriptionStore.isLoading) {
                        subscribe(to: plan)
                    }
                }

                Button {
                    Task { await subscriptionStore.restorePurchases() }
                } label: {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(subscriptionStore.isLoading)

                if let message = subscriptionStore.lastErrorMessage {
                    ErrorStateView(message: message)
                }

                SubscriptionLegalCard()
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Upgrade")
        .task {
            await subscriptionStore.loadProducts()
        }
    }

    private func subscribe(to plan: SubscriptionPlan) {
        if let product = subscriptionStore.product(for: plan) {
            Task { await subscriptionStore.purchase(product) }
            return
        }

#if DEBUG
        subscriptionStore.activatePreviewPlan(plan)
#endif
    }
}

private struct PlanCard: View {
    let plan: SubscriptionPlan
    let product: Product?
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.displayName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text(priceText)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(product == nil ? FixLensTheme.secondaryText : FixLensTheme.emerald)
                        Text(subscriptionLengthText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FixLensTheme.secondaryText)
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
                    Text(buttonTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(FixLensTheme.emerald, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isLoading || !canSubscribe)
                .opacity(isLoading || !canSubscribe ? 0.55 : 1)
            }
        }
    }

    private var priceText: String {
        product?.displayPrice ?? plan.pricePlaceholder
    }

    private var subscriptionLengthText: String {
        if let period = product?.subscription?.subscriptionPeriod {
            return period.displayText
        }
        return plan.subscriptionLength
    }

    private var buttonTitle: String {
        if product != nil {
            return "Subscribe"
        }
#if DEBUG
        return "Activate Preview"
#else
        return "Unavailable"
#endif
    }

    private var canSubscribe: Bool {
#if DEBUG
        true
#else
        product != nil
#endif
    }
}

private struct SubscriptionLegalCard: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Subscription terms")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text("Subscriptions renew automatically until canceled. You can manage or cancel a subscription in your App Store account settings.")
                    .font(.caption)
                    .foregroundStyle(FixLensTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 14) {
                    Link("Privacy Policy", destination: LegalLinks.privacyPolicyURL)
                    Link("Terms of Use (EULA)", destination: LegalLinks.termsOfUseURL)
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(FixLensTheme.emerald)
            }
        }
    }
}

private extension Product.SubscriptionPeriod {
    var displayText: String {
        let unitName: String
        switch unit {
        case .day:
            unitName = "day"
        case .week:
            unitName = "week"
        case .month:
            unitName = "month"
        case .year:
            unitName = "year"
        @unknown default:
            unitName = "period"
        }

        if value == 1 {
            return "\(unitName.capitalized) subscription"
        }
        return "\(value) \(unitName)s subscription"
    }
}
