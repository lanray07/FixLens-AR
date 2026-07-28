import Foundation
import StoreKit

@MainActor
final class SubscriptionStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var activePlan: SubscriptionPlan = .free
    @Published private(set) var isLoading = false
    @Published var lastErrorMessage: String?

    private let productIDs: [String: SubscriptionPlan] = [
        "fixlens.pro.monthly": .proMonthly,
        "fixlens.pro.yearly": .proYearly,
        "fixlens.property.monthly": .propertyProMonthly
    ]

    var isPro: Bool {
        activePlan != .free
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        products.first { productIDs[$0.id] == plan }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            lastErrorMessage = nil
            products = try await Product.products(for: Array(productIDs.keys))
            if products.isEmpty {
                lastErrorMessage = "Subscriptions are currently unavailable. Please try again later."
            }
        } catch {
            lastErrorMessage = "Subscriptions are currently unavailable. Please try again later."
            products = []
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            lastErrorMessage = nil
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    lastErrorMessage = "Purchase could not be verified."
                    return
                }
                activePlan = productIDs[transaction.productID] ?? .free
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            lastErrorMessage = nil
            try await AppStore.sync()
            await refreshPurchasedProducts()

            if activePlan == .free {
                lastErrorMessage = "No active subscription was found for this Apple ID."
            }
        } catch {
            lastErrorMessage = "Unable to restore purchases. \(error.localizedDescription)"
        }
    }

    func refreshPurchasedProducts() async {
        var detectedPlan: SubscriptionPlan = .free

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            detectedPlan = productIDs[transaction.productID] ?? detectedPlan
        }

        activePlan = detectedPlan
    }

    func resetLocalSubscriptionState() {
        activePlan = .free
    }

#if DEBUG
    func activatePreviewPlan(_ plan: SubscriptionPlan) {
        activePlan = plan
    }
#endif
}
