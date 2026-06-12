import SwiftData
import SwiftUI

@main
@MainActor
struct FixLensARApp: App {
    @StateObject private var services: AppServices
    @StateObject private var subscriptionStore: SubscriptionStore
    private let modelContainer: ModelContainer

    init() {
        let subscriptionStore = SubscriptionStore()
        _subscriptionStore = StateObject(wrappedValue: subscriptionStore)
        _services = StateObject(wrappedValue: AppServices.mock(subscriptionStore: subscriptionStore))

        do {
            modelContainer = try FixLensModelContainerFactory.makeContainer()
        } catch {
            fatalError("Unable to create FixLens AR model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(services)
                .environmentObject(subscriptionStore)
                .environmentObject(services.speechRecognition)
                .environmentObject(services.voiceRecording)
                .environmentObject(services.waveformAnimation)
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
        }
    }
}

enum FixLensModelContainerFactory {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            HomeProfile.self,
            Appliance.self,
            MaintenanceTask.self,
            ScanResult.self,
            ErrorCode.self,
            VoiceTranscript.self,
            MaintenanceReport.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
