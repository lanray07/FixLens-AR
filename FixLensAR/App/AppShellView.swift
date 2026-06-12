import SwiftData
import SwiftUI

struct AppShellView: View {
    @EnvironmentObject private var services: AppServices
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Query(sort: \HomeProfile.createdAt, order: .forward) private var profiles: [HomeProfile]
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        ZStack {
            PremiumBackground()

            if profiles.isEmpty {
                OnboardingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                TabView(selection: $selectedTab) {
                    ForEach(AppTab.allCases) { tab in
                        NavigationStack {
                            tab.rootView
                                .withAppRoutes()
                        }
                        .tabItem { tab.label }
                        .tag(tab)
                        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                        .toolbarBackground(.visible, for: .tabBar)
                    }
                }
                .tint(FixLensTheme.electricBlue)
                .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.35), value: profiles.isEmpty)
        .task {
            await subscriptionStore.loadProducts()
            await subscriptionStore.refreshPurchasedProducts()
            await services.notifications.requestAuthorization()
            await services.voiceRecording.requestPermissionIfNeeded()
        }
    }
}
