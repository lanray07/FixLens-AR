import Foundation
import SwiftUI

@MainActor
final class AppServices: ObservableObject {
    let applianceRecognition: any ApplianceRecognitionService
    let troubleshooting: any TroubleshootingService
    let maintenanceGuides: any MaintenanceGuideService
    let errorCodes: any ErrorCodeService
    let applianceHealth: any ApplianceHealthService
    let voiceAssistant: any VoiceAssistantService
    let remoteAI: RemoteAIService
    let speechRecognition: SpeechRecognitionService
    let voiceRecording: VoiceRecordingService
    let waveformAnimation: WaveformAnimationManager
    let notifications: NotificationScheduler
    let pdfReports: PDFReportService
    let subscriptionStore: SubscriptionStore

    init(
        applianceRecognition: any ApplianceRecognitionService,
        troubleshooting: any TroubleshootingService,
        maintenanceGuides: any MaintenanceGuideService,
        errorCodes: any ErrorCodeService,
        applianceHealth: any ApplianceHealthService,
        voiceAssistant: any VoiceAssistantService,
        remoteAI: RemoteAIService,
        speechRecognition: SpeechRecognitionService,
        voiceRecording: VoiceRecordingService,
        waveformAnimation: WaveformAnimationManager,
        notifications: NotificationScheduler,
        pdfReports: PDFReportService,
        subscriptionStore: SubscriptionStore
    ) {
        self.applianceRecognition = applianceRecognition
        self.troubleshooting = troubleshooting
        self.maintenanceGuides = maintenanceGuides
        self.errorCodes = errorCodes
        self.applianceHealth = applianceHealth
        self.voiceAssistant = voiceAssistant
        self.remoteAI = remoteAI
        self.speechRecognition = speechRecognition
        self.voiceRecording = voiceRecording
        self.waveformAnimation = waveformAnimation
        self.notifications = notifications
        self.pdfReports = pdfReports
        self.subscriptionStore = subscriptionStore
    }

    static func mock(subscriptionStore: SubscriptionStore) -> AppServices {
        let mockAI = MockAIService()
        return AppServices(
            applianceRecognition: mockAI,
            troubleshooting: mockAI,
            maintenanceGuides: mockAI,
            errorCodes: mockAI,
            applianceHealth: mockAI,
            voiceAssistant: mockAI,
            remoteAI: RemoteAIService(),
            speechRecognition: SpeechRecognitionService(),
            voiceRecording: VoiceRecordingService(),
            waveformAnimation: WaveformAnimationManager(),
            notifications: NotificationScheduler(),
            pdfReports: PDFReportService(),
            subscriptionStore: subscriptionStore
        )
    }
}
