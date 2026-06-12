import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case scan
    case arGuide
    case voice
    case settings

    var id: String { rawValue }

    @ViewBuilder
    var rootView: some View {
        switch self {
        case .dashboard:
            DashboardView()
        case .scan:
            ApplianceScannerView()
        case .arGuide:
            ARGuideView()
        case .voice:
            VoiceAssistantView()
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .dashboard:
            Label("Home", systemImage: "house.and.flag")
        case .scan:
            Label("Scan", systemImage: "camera.viewfinder")
        case .arGuide:
            Label("AR", systemImage: "arkit")
        case .voice:
            Label("Voice", systemImage: "waveform")
        case .settings:
            Label("Settings", systemImage: "gearshape")
        }
    }
}

enum AppRoute: Hashable {
    case scanner
    case arGuide(ApplianceType)
    case appliance(UUID)
    case guides
    case troubleshooter
    case errorScanner
    case health
    case calendar
    case portfolio
    case reports
    case paywall
    case voice
}

extension View {
    func withAppRoutes() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .scanner:
                ApplianceScannerView()
            case .arGuide(let type):
                ARGuideView(applianceType: type)
            case .appliance(let applianceID):
                ApplianceDetailView(applianceID: applianceID)
            case .guides:
                MaintenanceGuidesView()
            case .troubleshooter:
                TroubleshooterView()
            case .errorScanner:
                ErrorCodeScannerView()
            case .health:
                ApplianceHealthDashboardView()
            case .calendar:
                MaintenanceCalendarView()
            case .portfolio:
                PropertyPortfolioView()
            case .reports:
                ReportsView()
            case .paywall:
                PaywallView()
            case .voice:
                VoiceAssistantView()
            }
        }
    }
}
